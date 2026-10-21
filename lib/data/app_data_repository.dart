import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/pet.dart';
import 'pet_repository.dart';

class AppRecord {
  const AppRecord(this.id, this.data);
  final String id;
  final Map<String, dynamic> data;
  String text(String key) => data[key] is String ? data[key] as String : '';
  num number(String key) =>
      data[key] is num && (data[key] as num).isFinite ? data[key] as num : 0;
  DateTime? date(String key) {
    final value = data[key];
    if (value is Timestamp) return value.toDate().toLocal();
    if (value is DateTime) return value.toLocal();
    return DateTime.tryParse(text(key))?.toLocal();
  }
}

/// Only records returned by Firestore are stored here; no fallback fixtures.
class AppDataRepository {
  static List<AppRecord> clinics = [];
  static List<AppRecord> services = [];
  static List<AppRecord> timeSlots = [];
  static List<AppRecord> doctors = [];
  static List<AppRecord> appointments = [];
  static List<AppRecord> _legacyAppointments = [];
  static bool remindersEnabled = true;
  static int _version = 0;
  static final revision = ValueNotifier<int>(0);
  static final syncError = ValueNotifier<String?>(null);
  static final List<StreamSubscription<dynamic>> _subscriptions = [];
  static void changed() => revision.value++;
  static void clearSession() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    _version++;
    clinics = [];
    services = [];
    timeSlots = [];
    doctors = [];
    appointments = [];
    _legacyAppointments = [];
    remindersEnabled = true;
  }

  static void watchForUser(AppUser user) {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    final version = ++_version;
    appointments = List<AppRecord>.of(_legacyAppointments);
    final db = FirebaseFirestore.instance;
    void watch(Query<Map<String, dynamic>> query,
        void Function(List<AppRecord>) assign) {
      _subscriptions.add(query.snapshots().listen((snapshot) {
        if (version != _version) return;
        assign(snapshot.docs.map((d) => AppRecord(d.id, d.data())).toList());
        syncError.value = null;
        changed();
      }, onError: (Object error) {
        if (version == _version) {
          syncError.value =
              'Không thể đồng bộ dữ liệu. Kiểm tra kết nối và thử lại.';
        }
      }));
    }

    watch(db.collection('clinics'), (v) => clinics = v);
    watch(db.collection('services'), (v) => services = v);
    watch(db.collection('doctors'), (v) => doctors = v);
    watch(db.collection('timeSlots'), (v) => timeSlots = v);
    Query<Map<String, dynamic>> query = db.collection('appointments');
    if (user.role != UserRole.admin) {
      query = query.where(
          user.role == UserRole.doctor ? 'doctorUid' : 'ownerId',
          isEqualTo: user.uid);
    }
    final legacy = List<AppRecord>.of(_legacyAppointments);
    watch(query, (v) {
      appointments = [...legacy.where((a) => !v.any((b) => b.id == a.id)), ...v]
        ..sort((a, b) => b.text('startsAt').compareTo(a.text('startsAt')));
    });
    _subscriptions.add(
        db.collection('users/${user.uid}/pets').snapshots().listen((snapshot) {
      if (version != _version) return;
      PetRepository.replace(
          snapshot.docs.map((d) => Pet.fromMap(d.id, d.data())).toList());
      changed();
    }, onError: (Object error) {
      if (version == _version) {
        syncError.value =
            'Không thể đồng bộ dữ liệu. Kiểm tra kết nối và thử lại.';
      }
    }));
    _subscriptions.add(db
        .doc('users/${user.uid}/settings/preferences')
        .snapshots()
        .listen((snapshot) {
      if (version != _version) return;
      remindersEnabled = snapshot.data()?['remindersEnabled'] as bool? ?? true;
      changed();
    }, onError: (Object error) {
      if (version == _version) {
        syncError.value =
            'Không thể đồng bộ dữ liệu. Kiểm tra kết nối và thử lại.';
      }
    }));
  }

  static Future<void> loadForUser(String uid) async {
    clearSession();
    final version = _version;
    final db = FirebaseFirestore.instance;
    final paths = [
      'clinics',
      'services',
      'timeSlots',
      'doctors',
      'users/$uid/appointments'
    ];
    final results = await Future.wait(paths.map((path) =>
            db.collection(path).get(const GetOptions(source: Source.server))))
        .timeout(const Duration(seconds: 20));
    if (version != _version) return;
    final records = results
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppRecord(doc.id, doc.data())).toList())
        .toList();
    clinics = records[0];
    services = records[1];
    timeSlots = records[2];
    doctors = records[3];
    appointments = records[4];
    _legacyAppointments = List<AppRecord>.of(appointments);
    appointments
        .sort((a, b) => a.text('startsAt').compareTo(b.text('startsAt')));
  }

  static String clinicName(String id) =>
      clinics.where((c) => c.id == id).map((c) => c.text('name')).firstOrNull ??
      '';
  static String doctorName(String id) =>
      doctors.where((c) => c.id == id).map((c) => c.text('name')).firstOrNull ??
      '';
  static List<AppRecord> get upcoming => appointments
      .where((a) =>
          ['confirmed', 'pending'].contains(a.text('status')) &&
          (a.date('startsAt')?.isAfter(DateTime.now()) ?? false))
      .toList();
}
