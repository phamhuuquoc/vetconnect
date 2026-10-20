import '../models/pet.dart';

/// Kho lưu tạm trong bộ nhớ. Chưa nối Firestore — khi cần chỉ việc
/// thay thân các hàm này bằng truy vấn Firestore.
class PetRepository {
  static final List<Pet> _pets = <Pet>[
    Pet(
      id: 'pet_1',
      name: 'Miu',
      species: 'Mèo',
      breed: 'Mèo Anh lông ngắn',
      ageYears: 2,
      weightKg: 4.2,
      gender: 'Cái',
      neutered: true,
      allergies: const <String>['Dị ứng thịt gà'],
      vaccines: <VaccineRecord>[
        VaccineRecord(
          name: 'Vaccine dại',
          date: DateTime(2026, 3, 12),
          done: true,
          nextDate: DateTime(2027, 3, 12),
        ),
        VaccineRecord(
          name: 'Vaccine 4 bệnh',
          date: DateTime(2026, 4, 2),
          done: true,
          nextDate: DateTime(2027, 4, 2),
        ),
        VaccineRecord(
          name: 'Tẩy giun định kỳ',
          date: DateTime(2026, 11, 1),
          done: false,
        ),
      ],
      weights: <WeightRecord>[
        WeightRecord(date: DateTime(2026, 5, 1), kg: 3.8),
        WeightRecord(date: DateTime(2026, 7, 1), kg: 4.0),
        WeightRecord(date: DateTime(2026, 9, 1), kg: 4.2),
      ],
      visits: <VisitRecord>[
        VisitRecord(
          date: DateTime(2026, 9, 12),
          clinic: 'Phòng khám Thú y An Phú',
          service: 'Khám tổng quát',
          priceVnd: 320000,
        ),
        VisitRecord(
          date: DateTime(2026, 4, 2),
          clinic: 'Phòng khám Thú y An Phú',
          service: 'Tiêm vaccine 4 bệnh',
          priceVnd: 150000,
        ),
      ],
    ),
    Pet(
      id: 'pet_2',
      name: 'Béo',
      species: 'Chó',
      breed: 'Pug',
      ageYears: 4,
      weightKg: 8.5,
      gender: 'Đực',
      neutered: false,
      vaccines: <VaccineRecord>[
        VaccineRecord(
          name: 'Vaccine dại',
          date: DateTime(2026, 10, 25),
          done: false,
        ),
        VaccineRecord(
          name: 'Vaccine 7 bệnh',
          date: DateTime(2025, 8, 10),
          done: true,
          nextDate: DateTime(2026, 8, 10),
        ),
      ],
      weights: <WeightRecord>[
        WeightRecord(date: DateTime(2026, 5, 1), kg: 9.2),
        WeightRecord(date: DateTime(2026, 7, 1), kg: 8.9),
        WeightRecord(date: DateTime(2026, 9, 1), kg: 8.5),
      ],
      visits: <VisitRecord>[
        VisitRecord(
          date: DateTime(2026, 8, 10),
          clinic: 'Bệnh viện Thú y Sài Gòn',
          service: 'Tiêm vaccine 7 bệnh',
          priceVnd: 180000,
        ),
      ],
    ),
  ];

  static List<Pet> get pets => _pets;

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

  static String nextId() => 'pet_${_pets.length + 1}';
}
