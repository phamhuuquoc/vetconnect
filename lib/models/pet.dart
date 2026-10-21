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

  Map<String, dynamic> toMap() => {
        'name': name,
        'species': species,
        'breed': breed,
        'ageYears': ageYears,
        'weightKg': weightKg,
        'gender': gender,
        'neutered': neutered,
        'allergies': allergies,
        'vaccines': vaccines
            .map((v) => {
                  'name': v.name,
                  'date': v.date.toUtc().toIso8601String(),
                  'done': v.done,
                  'nextDate': v.nextDate?.toUtc().toIso8601String(),
                })
            .toList(),
        'weights': weights
            .map((w) => {
                  'date': w.date.toUtc().toIso8601String(),
                  'kg': w.kg,
                })
            .toList(),
        'visits': visits
            .map((v) => {
                  'date': v.date.toUtc().toIso8601String(),
                  'clinic': v.clinic,
                  'service': v.service,
                  'priceVnd': v.priceVnd,
                })
            .toList(),
      };

  factory Pet.fromMap(String id, Map<String, dynamic> data) {
    DateTime date(dynamic value) => DateTime.parse(value as String);
    List<Map<String, dynamic>> records(String key) =>
        (data[key] as List<dynamic>? ?? [])
            .map((v) => Map<String, dynamic>.from(v as Map))
            .toList();
    return Pet(
      id: id,
      name: data['name'] as String,
      species: data['species'] as String,
      breed: data['breed'] as String,
      ageYears: (data['ageYears'] as num).toInt(),
      weightKg: (data['weightKg'] as num).toDouble(),
      gender: data['gender'] as String,
      neutered: data['neutered'] as bool? ?? false,
      allergies: List<String>.from(data['allergies'] as List? ?? []),
      vaccines: records('vaccines')
          .map((v) => VaccineRecord(
                name: v['name'] as String,
                date: date(v['date']),
                done: v['done'] as bool,
                nextDate: v['nextDate'] == null ? null : date(v['nextDate']),
              ))
          .toList(),
      weights: records('weights')
          .map((v) => WeightRecord(
              date: date(v['date']), kg: (v['kg'] as num).toDouble()))
          .toList(),
      visits: records('visits')
          .map((v) => VisitRecord(
              date: date(v['date']),
              clinic: v['clinic'] as String,
              service: v['service'] as String,
              priceVnd: (v['priceVnd'] as num).toInt()))
          .toList(),
    );
  }

  String get subtitle => '$breed - $ageYears tuổi';

  bool get vaccineUpToDate {
    return vaccines.isNotEmpty &&
        vaccines.every((VaccineRecord v) =>
            v.done &&
            (v.nextDate == null || v.nextDate!.isAfter(DateTime.now())));
  }

  int get pendingVaccineCount {
    return vaccines
        .where((VaccineRecord v) =>
            !v.done ||
            (v.nextDate != null && !v.nextDate!.isAfter(DateTime.now())))
        .length;
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
    List<VaccineRecord>? vaccines,
    List<WeightRecord>? weights,
    List<VisitRecord>? visits,
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
      vaccines: vaccines ?? this.vaccines,
      weights: weights ?? this.weights,
      visits: visits ?? this.visits,
    );
  }
}
