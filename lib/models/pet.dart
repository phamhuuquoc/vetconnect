class VaccineRecord {
  const VaccineRecord({
    required this.name,
    required this.date,
    required this.done,
    this.nextDate,
  });

  final String name;
  final DateTime date;
  final bool done;
  final DateTime? nextDate;
}

class WeightRecord {
  const WeightRecord({required this.date, required this.kg});

  final DateTime date;
  final double kg;
}

class VisitRecord {
  const VisitRecord({
    required this.date,
    required this.clinic,
    required this.service,
    required this.priceVnd,
  });

  final DateTime date;
  final String clinic;
  final String service;
  final int priceVnd;
}

class Pet {
  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.ageYears,
    required this.weightKg,
    required this.gender,
    this.neutered = false,
    this.allergies = const <String>[],
    this.vaccines = const <VaccineRecord>[],
    this.weights = const <WeightRecord>[],
    this.visits = const <VisitRecord>[],
  });

  final String id;
  final String name;
  final String species;
  final String breed;
  final int ageYears;
  final double weightKg;
  final String gender;
  final bool neutered;
  final List<String> allergies;
  final List<VaccineRecord> vaccines;
  final List<WeightRecord> weights;
  final List<VisitRecord> visits;

  String get subtitle => '$breed - $ageYears tuổi';

  bool get vaccineUpToDate {
    return vaccines.every((VaccineRecord v) => v.done);
  }

  int get pendingVaccineCount {
    return vaccines.where((VaccineRecord v) => !v.done).length;
  }

  int get totalSpent {
    int sum = 0;
    for (final VisitRecord v in visits) {
      sum += v.priceVnd;
    }
    return sum;
  }

  Pet copyWith({
    String? name,
    String? species,
    String? breed,
    int? ageYears,
    double? weightKg,
    String? gender,
    bool? neutered,
    List<String>? allergies,
  }) {
    return Pet(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      ageYears: ageYears ?? this.ageYears,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      neutered: neutered ?? this.neutered,
      allergies: allergies ?? this.allergies,
      vaccines: vaccines,
      weights: weights,
      visits: visits,
    );
  }
}
