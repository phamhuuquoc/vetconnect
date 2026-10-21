import { readFile } from 'node:fs/promises';
import { before, beforeEach, after, test } from 'node:test';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, getDocs, collection, setDoc, updateDoc, deleteDoc, serverTimestamp, Timestamp, writeBatch, query, where, runTransaction } from 'firebase/firestore';

let env;
const [emulatorHost, emulatorPort] = (process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:18087').split(':');
const db = (uid, email = `${uid}@example.com`) => env.authenticatedContext(uid, { email }).firestore();
const profile = (role, email) => ({ role, email, createdAt: serverTimestamp(), updatedAt: serverTimestamp() });

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-vetconnect',
    firestore: { host: emulatorHost, port: Number(emulatorPort), rules: await readFile(new URL('../../firestore.rules', import.meta.url), 'utf8') },
  });
});
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    for (const [uid, role] of [['owner', 'user'], ['doctor', 'doctor'], ['admin', 'admin'], ['other', 'user']]) {
      await setDoc(doc(context.firestore(), 'users', uid), profile(role, `${uid}@example.com`));
    }
  });
});
after(async () => { if (env) await env.cleanup(); });

test('signed-out callers cannot read, list, or create profiles', async () => {
  const guest = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(guest, 'users', 'owner')));
  await assertFails(getDocs(collection(guest, 'users')));
  await assertFails(setDoc(doc(guest, 'users', 'new'), profile('user', 'new@example.com')));
});

test('new accounts can only create their own regular-user profile', async () => {
  const account = db('new');
  await assertSucceeds(getDoc(doc(account, 'users', 'new')));
  await assertFails(setDoc(doc(account, 'users', 'new'), profile('admin', 'new@example.com')));
  await assertFails(setDoc(doc(account, 'users', 'new'), profile('doctor', 'new@example.com')));
  await assertFails(setDoc(doc(account, 'users', 'other-new'), profile('user', 'new@example.com')));
  await assertFails(setDoc(doc(account, 'users', 'new'), profile('user', 'spoof@example.com')));
  await assertFails(setDoc(doc(account, 'users', 'new'), { ...profile('user', 'new@example.com'), privileged: true }));
  await assertSucceeds(setDoc(doc(account, 'users', 'new'), profile('user', 'new@example.com')));
});

test('client-supplied admin claims do not override the stored role', async () => {
  const spoofed = env.authenticatedContext('owner', { email: 'owner@example.com', role: 'admin', admin: true }).firestore();
  await assertFails(getDocs(collection(spoofed, 'users')));
  await assertFails(updateDoc(doc(spoofed, 'users', 'owner'), { role: 'admin', updatedAt: serverTimestamp() }));
});

test('users and doctors can read themselves but cannot list or read other accounts', async () => {
  for (const uid of ['owner', 'doctor']) {
    await assertSucceeds(getDoc(doc(db(uid), 'users', uid)));
    await assertFails(getDoc(doc(db(uid), 'users', 'other')));
    await assertFails(getDocs(collection(db(uid), 'users')));
  }
});

test('users and doctors cannot promote themselves or other accounts', async () => {
  for (const uid of ['owner', 'doctor']) {
    for (const target of [uid, 'other']) {
      await assertFails(updateDoc(doc(db(uid), 'users', target), { role: 'admin', updatedAt: serverTimestamp() }));
    }
  }
});

test('admins can list accounts and assign each supported role', async () => {
  await assertSucceeds(getDocs(collection(db('admin'), 'users')));
  for (const role of ['doctor', 'admin', 'user']) {
    await assertSucceeds(updateDoc(doc(db('admin'), 'users', 'other'), { role, updatedAt: serverTimestamp() }));
  }
});

test('admins cannot alter identity, write arbitrary roles, delete accounts or change themselves', async () => {
  const admin = db('admin');
  await assertFails(updateDoc(doc(admin, 'users', 'other'), { role: 'root', updatedAt: serverTimestamp() }));
  await assertFails(updateDoc(doc(admin, 'users', 'other'), { email: 'changed@example.com', updatedAt: serverTimestamp() }));
  await assertFails(updateDoc(doc(admin, 'users', 'other'), { role: 'doctor', updatedAt: Timestamp.fromMillis(0) }));
  await assertFails(updateDoc(doc(admin, 'users', 'admin'), { role: 'user', updatedAt: serverTimestamp() }));
  await assertFails(deleteDoc(doc(admin, 'users', 'other')));
});

test('revoked admins immediately lose backend management permissions', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users', 'second-admin'), profile('admin', 'second-admin@example.com'));
  });
  const formerAdmin = db('second-admin');
  await assertSucceeds(getDocs(collection(formerAdmin, 'users')));
  await assertSucceeds(updateDoc(doc(db('admin'), 'users', 'second-admin'), { role: 'user', updatedAt: serverTimestamp() }));
  await assertFails(getDocs(collection(formerAdmin, 'users')));
  await assertFails(updateDoc(doc(formerAdmin, 'users', 'other'), { role: 'doctor', updatedAt: serverTimestamp() }));
});

test('unconfigured data collections stay private even for admins', async () => {
  for (const uid of ['owner', 'doctor', 'admin']) {
    await assertFails(setDoc(doc(db(uid), 'pets', 'private-pet'), { name: 'Miu' }));
    await assertFails(getDocs(collection(db(uid), 'pets')));
  }
});

test('pet records are private and valid owner edits persist', async () => {
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'users', 'owner', 'pets', 'miu'), {name: 'Miu'});
  });
  await assertSucceeds(getDocs(collection(db('owner'), 'users', 'owner', 'pets')));
  for (const uid of ['other', 'doctor', 'admin']) {
    await assertFails(getDoc(doc(db(uid), 'users', 'owner', 'pets', 'miu')));
    await assertFails(getDocs(collection(db(uid), 'users', 'owner', 'pets')));
  }
  await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'users', 'owner', 'pets', 'miu')));
  await assertFails(setDoc(doc(db('owner'), 'users', 'owner', 'pets', 'new'), {name: 'new'}));
  await assertFails(updateDoc(doc(db('owner'), 'users', 'owner', 'pets', 'miu'), {name: 'changed'}));
  const pet = {name:'Luna',species:'Mèo',breed:'',ageYears:2,weightKg:4,gender:'Cái',neutered:false,allergies:[],vaccines:[],weights:[],visits:[]};
  await assertSucceeds(setDoc(doc(db('owner'), 'users', 'owner', 'pets', 'new'), pet));
  await assertFails(updateDoc(doc(db('owner'), 'users', 'owner', 'pets', 'new'), {weightKg: -1}));
  await assertFails(updateDoc(doc(db('other'), 'users', 'owner', 'pets', 'new'), {name:'stolen'}));
  await assertSucceeds(updateDoc(doc(db('owner'), 'users', 'owner', 'pets', 'new'), {weightKg:4.5}));
  await assertSucceeds(deleteDoc(doc(db('owner'), 'users', 'owner', 'pets', 'new')));
});

test('catalog records require sign-in and cannot be changed by clients', async () => {
  for (const name of ['clinics', 'services', 'timeSlots', 'doctors']) {
    await assertFails(getDocs(collection(env.unauthenticatedContext().firestore(), name)));
    for (const uid of ['owner', 'doctor', 'admin']) {
      await assertSucceeds(getDocs(collection(db(uid), name)));
      await assertFails(setDoc(doc(db(uid), name, 'injected'), {name: 'fake'}));
    }
  }
});
test('appointment views are private per account, including assigned doctor views', async () => {
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'users', 'owner', 'appointments', 'visit'), {petName: 'Miu'});
    await setDoc(doc(context.firestore(), 'users', 'doctor', 'appointments', 'visit'), {petName: 'Miu'});
  });
  for (const uid of ['owner', 'doctor']) {
    await assertSucceeds(getDocs(collection(db(uid), 'users', uid, 'appointments')));
    await assertFails(setDoc(doc(db(uid), 'users', uid, 'appointments', 'fake'), {status: 'confirmed'}));
    await assertFails(deleteDoc(doc(db(uid), 'users', uid, 'appointments', 'visit')));
  }
  for (const uid of ['other', 'doctor', 'admin']) {
    await assertFails(getDocs(collection(db(uid), 'users', 'owner', 'appointments')));
  }
  await assertFails(getDocs(collection(db('owner'), 'users', 'doctor', 'appointments')));
  await assertFails(getDocs(collection(env.unauthenticatedContext().firestore(), 'users', 'owner', 'appointments')));
});

const petData = {name:'Luna',species:'Mèo',breed:'Mèo ta',ageYears:2,weightKg:4,gender:'Cái',neutered:false,allergies:['fish'],vaccines:[],weights:[],visits:[]};
const future = new Date(Date.now() + 86400000);
const slotData = {clinicId:'clinic',serviceId:'service',doctorId:'doc',startsAt:future.toISOString(),startsAtTime:Timestamp.fromDate(future),status:'available',appointmentId:''};
async function seedCare() {
  await env.withSecurityRulesDisabled(async context => {
    const f = context.firestore();
    await setDoc(doc(f,'clinics','clinic'), {name:'Clinic',address:'Address',openingHours:'08–18'});
    await setDoc(doc(f,'services','service'), {name:'Exam',clinicId:'clinic',priceVnd:200000,durationMinutes:30});
    await setDoc(doc(f,'doctors','doc'), {name:'Doctor',userId:'doctor',clinicId:'clinic',specialty:'General'});
    await setDoc(doc(f,'timeSlots','slot'), slotData);
    for(const uid of ['owner','other']) await setDoc(doc(f,'users',uid,'pets','pet'), petData);
  });
}
function appointment(owner='owner') {
  return {ownerId:owner,petId:'pet',petName:petData.name,petSummary:petData,clinicId:'clinic',serviceId:'service',serviceName:'Exam',priceVnd:200000,doctorId:'doc',doctorUid:'doctor',slotId:'slot',startsAt:slotData.startsAt,startsAtTime:slotData.startsAtTime,status:'pending',medicalNotes:'',createdAt:serverTimestamp(),updatedAt:serverTimestamp()};
}
function bookingBatch(f,id,values=appointment()) {
  const batch=writeBatch(f);
  batch.set(doc(f,'appointments',id),values);
  batch.update(doc(f,'timeSlots','slot'),{status:'reserved',appointmentId:id});
  return batch.commit();
}
function cancelBatch(f,id) {
  const batch=writeBatch(f);
  batch.update(doc(f,'appointments',id),{status:'cancelled',updatedAt:serverTimestamp()});
  batch.update(doc(f,'timeSlots','slot'),{status:'available',appointmentId:''});
  return batch.commit();
}

test('catalog management is admin-only with valid clinic and doctor references',async()=>{
  await seedCare();
  for(const uid of ['owner','doctor']) {
    await assertFails(setDoc(doc(db(uid),'clinics','new'),{name:'Clinic',address:'Address',openingHours:'08–18'}));
  }
  await assertSucceeds(setDoc(doc(db('admin'),'clinics','new'),{name:'Clinic',address:'Address',openingHours:'08–18'}));
  await assertSucceeds(setDoc(doc(db('admin'),'services','new'),{name:'Exam',clinicId:'new',priceVnd:1,durationMinutes:30}));
  await assertFails(setDoc(doc(db('admin'),'doctors','wrong'),{name:'Doctor',userId:'owner',clinicId:'clinic',specialty:'General'}));
  await assertSucceeds(setDoc(doc(db('admin'),'doctors','new'),{name:'Doctor',userId:'doctor',clinicId:'clinic',specialty:'General'}));
  await assertSucceeds(setDoc(doc(db('admin'),'timeSlots','new'),slotData));
});
test('booking reserves its slot atomically and forbids spoofed prices or identities',async()=>{
  await seedCare();
  const f=db('owner');
  await assertFails(setDoc(doc(f,'appointments','alone'),appointment()));
  await assertFails(updateDoc(doc(f,'timeSlots','slot'),{status:'reserved',appointmentId:'fake'}));
  for(const overrides of [{ownerId:'other'},{priceVnd:1},{doctorUid:'other'},{serviceName:'Fake'},{petSummary:{...petData,name:'spoof'}},{status:'confirmed'}]) {
    await assertFails(bookingBatch(f,'spoof',{...appointment(),...overrides}));
  }
  await assertSucceeds(bookingBatch(f,'valid'));
  await assertFails(bookingBatch(db('other'),'double',appointment('other')));
  await assertFails(updateDoc(doc(db('admin'),'timeSlots','slot'),{status:'available'}));
  await assertFails(deleteDoc(doc(db('admin'),'timeSlots','slot')));
});
test('users see their own appointments and assigned doctors can query only their assignments',async()=>{
  await seedCare(); await bookingBatch(db('owner'),'valid');
  await assertSucceeds(getDocs(query(collection(db('owner'),'appointments'),where('ownerId','==','owner'))));
  await assertSucceeds(getDocs(query(collection(db('doctor'),'appointments'),where('doctorUid','==','doctor'))));
  await assertSucceeds(getDocs(collection(db('admin'),'appointments')));
  await assertFails(getDocs(collection(db('owner'),'appointments')));
  await assertFails(getDoc(doc(db('other'),'appointments','valid')));
  await assertFails(getDocs(query(collection(db('other'),'appointments'),where('doctorUid','==','doctor'))));
  await assertSucceeds(updateDoc(doc(db('doctor'),'appointments','valid'),{status:'confirmed',updatedAt:serverTimestamp()}));
  await assertFails(updateDoc(doc(db('owner'),'appointments','valid'),{status:'completed',medicalNotes:'forged',updatedAt:serverTimestamp()}));
  await assertFails(updateDoc(doc(db('doctor'),'appointments','valid'),{status:'completed',medicalNotes:'too early',updatedAt:serverTimestamp()}));
  await assertFails(updateDoc(doc(db('doctor'),'appointments','valid'),{doctorUid:'other',updatedAt:serverTimestamp()}));
});
test('cancellation releases the reservation and cannot be performed by another user',async()=>{
  await seedCare(); await bookingBatch(db('owner'),'valid');
  await assertFails(cancelBatch(db('other'),'valid'));
  await assertFails(updateDoc(doc(db('owner'),'appointments','valid'),{status:'cancelled',updatedAt:serverTimestamp()}));
  await assertSucceeds(cancelBatch(db('owner'),'valid'));
  await assertSucceeds(bookingBatch(db('other'),'replacement',appointment('other')));
  await assertFails(cancelBatch(db('owner'),'valid'));
});
test('assigned doctor completes a confirmed visit with immutable results and loses rights when revoked',async()=>{
  await seedCare(); await bookingBatch(db('owner'),'valid');
  await env.withSecurityRulesDisabled(async context => {
    await updateDoc(doc(context.firestore(),'appointments','valid'), {status:'confirmed',startsAtTime:Timestamp.fromMillis(Date.now()-60000)});
  });
  await assertFails(updateDoc(doc(db('doctor'),'appointments','valid'),{status:'completed',medicalNotes:'',updatedAt:serverTimestamp()}));
  await assertSucceeds(updateDoc(doc(db('doctor'),'appointments','valid'),{status:'completed',medicalNotes:'Follow up in one week',updatedAt:serverTimestamp()}));
  await assertFails(updateDoc(doc(db('doctor'),'appointments','valid'),{medicalNotes:'overwrite',updatedAt:serverTimestamp()}));
  await assertSucceeds(updateDoc(doc(db('admin'),'users','doctor'),{role:'user',updatedAt:serverTimestamp()}));
  await assertFails(getDoc(doc(db('doctor'),'appointments','valid')));
});
test('two simultaneous reservation transactions have exactly one winner',async()=>{
  await seedCare();
  const reserve = (owner) => {
    const f=db(owner);
    return runTransaction(f,async tx=>{
      const slot=await tx.get(doc(f,'timeSlots','slot'));
      if(slot.data().status!=='available') throw new Error('already reserved');
      tx.set(doc(f,'appointments',owner),appointment(owner));
      tx.update(slot.ref,{status:'reserved',appointmentId:owner});
    });
  };
  const result=await Promise.allSettled([reserve('owner'),reserve('other')]);
  if(result.filter(r=>r.status==='fulfilled').length!==1) throw new Error(JSON.stringify(result));
});
test('settings are private and cannot grant privileges',async()=>{
  const ref=doc(db('owner'),'users','owner','settings','preferences');
  await assertSucceeds(setDoc(ref,{address:'My address',remindersEnabled:false,favoriteClinicIds:['clinic']}));
  await assertFails(updateDoc(ref,{role:'admin'}));
  await assertFails(getDoc(doc(db('other'),'users','owner','settings','preferences')));
  await assertFails(setDoc(doc(db('other'),'users','owner','settings','preferences'),{address:'wrong'}));
});
