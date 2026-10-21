import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet.dart';

/// Account-owned records; cloud writes are handled by CareRepository.
class PetRepository {
  static int _sessionVersion = 0;

  static Future<void> loadForUser(String uid) async {
    final version = ++_sessionVersion;
    _pets.clear();
    final result = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets')
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 20));
    final pets =
        result.docs.map((doc) => Pet.fromMap(doc.id, doc.data())).toList();
    if (version != _sessionVersion) return;
    _pets
      ..clear()
      ..addAll(pets);
  }

  static final List<Pet> _pets = <Pet>[];

  static List<Pet> get pets => _pets;
  static void replace(List<Pet> pets) {
    _pets
      ..clear()
      ..addAll(pets);
  }

  static void clearSession() {
    _sessionVersion++;
    _pets.clear();
  }

  static Pet? byId(String id) {
    for (final Pet pet in _pets) {
      if (pet.id == id) {
        return pet;
      }
    }
    return null;
  }

  static void addPet(Pet pet) {
    _pets.add(pet);
  }

  static void updatePet(Pet updated) {
    for (int i = 0; i < _pets.length; i++) {
      if (_pets[i].id == updated.id) {
        _pets[i] = updated;
        return;
      }
    }
  }

  static void removePet(String id) {
    _pets.removeWhere((Pet pet) => pet.id == id);
  }

  static void addWeightRecord(String id, double kg) {
    final Pet? pet = byId(id);
    if (pet == null) {
      return;
    }
    final List<WeightRecord> updated = <WeightRecord>[
      ...pet.weights,
      WeightRecord(date: DateTime.now(), kg: kg),
    ];
    updatePet(
      Pet(
        id: pet.id,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        ageYears: pet.ageYears,
        weightKg: kg,
        gender: pet.gender,
        neutered: pet.neutered,
        allergies: pet.allergies,
        vaccines: pet.vaccines,
        weights: updated,
        visits: pet.visits,
      ),
    );
  }

  static void markVaccineDone(String id, int index) {
    final Pet? pet = byId(id);
    if (pet == null || index >= pet.vaccines.length) {
      return;
    }
    final List<VaccineRecord> updated = <VaccineRecord>[];
    for (int i = 0; i < pet.vaccines.length; i++) {
      final VaccineRecord v = pet.vaccines[i];
      updated.add(
        i == index
            ? VaccineRecord(
                name: v.name,
                date: DateTime.now(),
                done: true,
                nextDate: DateTime.now().add(const Duration(days: 365)),
              )
            : v,
      );
    }
    updatePet(
      Pet(
        id: pet.id,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        ageYears: pet.ageYears,
        weightKg: pet.weightKg,
        gender: pet.gender,
        neutered: pet.neutered,
        allergies: pet.allergies,
        vaccines: updated,
        weights: pet.weights,
        visits: pet.visits,
      ),
    );
  }

  static String nextId() => 'pet_${DateTime.now().microsecondsSinceEpoch}';
}
