class HealthRecord {
  int? id;
  String date; // yyyy-MM-dd
  int steps;
  int calories;
  int water; // ml

  HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'date': date,
      'steps': steps,
      'calories': calories,
      'water': water,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory HealthRecord.fromMap(Map<String, dynamic> m) {
    return HealthRecord(
      id: m['id'] as int?,
      date: m['date'] as String,
      steps: (m['steps'] as num).toInt(),
      calories: (m['calories'] as num).toInt(),
      water: (m['water'] as num).toInt(),
    );
  }
}
