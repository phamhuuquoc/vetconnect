import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pet.dart';
import 'app_data_repository.dart';
import 'pet_repository.dart';

/// Every write is acknowledged by the server before the UI reports success.
class CareRepository {
  CareRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : db = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  String get uid => auth.currentUser?.uid ?? (throw StateError('signed-out'));

  Future<void> savePet(Pet pet) async {
    final owner = uid;
    await db.doc('users/$owner/pets/${pet.id}').set(pet.toMap());
    if (auth.currentUser?.uid != owner) return;
    if (PetRepository.byId(pet.id) == null) {
      PetRepository.addPet(pet);
    } else {
      PetRepository.updatePet(pet);
    }
    AppDataRepository.changed();
  }

  Future<void> deletePet(String id) async {
    final owner = uid;
    await db.doc('users/$owner/pets/$id').delete();
    if (auth.currentUser?.uid != owner) return;
    PetRepository.removePet(id);
    AppDataRepository.changed();
  }

  Future<String> book({required String petId, required String slotId}) async {
    final owner = uid;
    final ref = db.collection('appointments').doc();
    await db.runTransaction((tx) async {
      final slot = await tx.get(db.doc('timeSlots/$slotId'));
      final s = slot.data();
      if (s == null || s['status'] != 'available') {
        throw StateError('slot-taken');
      }
      final startsAt = DateTime.parse(s['startsAt'] as String);
      if (!startsAt.isAfter(DateTime.now())) throw StateError('slot-expired');
      final pet = await tx.get(db.doc('users/$owner/pets/$petId'));
      final service = await tx.get(db.doc('services/${s['serviceId']}'));
      final doctor = await tx.get(db.doc('doctors/${s['doctorId']}'));
      if (!pet.exists || !service.exists || !doctor.exists) {
        throw StateError('missing-data');
      }
      tx.set(ref, {
        'ownerId': owner,
        'petId': petId,
        'petName': pet.data()!['name'],
        'petSummary': pet.data(),
        'clinicId': s['clinicId'],
        'serviceId': s['serviceId'],
        'serviceName': service.data()!['name'],
        'priceVnd': service.data()!['priceVnd'],
        'doctorId': s['doctorId'],
        'doctorUid': doctor.data()!['userId'],
        'slotId': slotId,
        'startsAt': s['startsAt'],
        'startsAtTime': Timestamp.fromDate(startsAt),
        'status': 'pending',
        'medicalNotes': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(
          slot.reference, {'status': 'reserved', 'appointmentId': ref.id});
    });
    return ref.id;
  }

  Future<void> updateAppointment(AppRecord record, String status,
      {String notes = ''}) async {
    await db.runTransaction((tx) async {
      final ref = db.doc('appointments/${record.id}');
      final snapshot = await tx.get(ref);
      final data = snapshot.data();
      if (data == null) throw StateError('missing-appointment');
      final current = data['status'];
      if (!['pending', 'confirmed'].contains(current)) {
        throw StateError('finished');
      }
      if (status == 'completed' && current != 'confirmed') {
        throw StateError('confirm-first');
      }
      final slotRef = db.doc('timeSlots/${data['slotId']}');
      final slot = await tx.get(slotRef);
      tx.update(ref, {
        'status': status,
        if (status == 'completed') 'medicalNotes': notes.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (status == 'cancelled' && slot.data()?['appointmentId'] == record.id) {
        tx.update(slotRef, {'status': 'available', 'appointmentId': ''});
      }
    });
  }

  DocumentReference<Map<String, dynamic>> get settings =>
      db.doc('users/$uid/settings/preferences');
  Future<void> saveSettings(Map<String, dynamic> values) =>
      settings.set(values, SetOptions(merge: true));
}
