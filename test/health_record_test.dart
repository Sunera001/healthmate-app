import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/features/health_records/models/health_record.dart';

void main() {
  group('HealthRecord Model Tests', () {
    test('should create a valid HealthRecord object', () {
      final record = HealthRecord(
        date: '2025-12-07',
        steps: 5000,
        calories: 200,
        water: 1500,
      );

      expect(record.date, '2025-12-07');
      expect(record.steps, 5000);
      expect(record.calories, 200);
      expect(record.water, 1500);
    });

    test('should convert HealthRecord to Map correctly', () {
      final record = HealthRecord(
        id: 1,
        date: '2025-12-07',
        steps: 10000,
        calories: 400,
        water: 2000,
      );

      final map = record.toMap();

      expect(map['id'], 1);
      expect(map['date'], '2025-12-07');
      expect(map['steps'], 10000);
      expect(map['calories'], 400);
      expect(map['water'], 2000);
    });

    test('should create HealthRecord from Map correctly', () {
      final map = {
        'id': 2,
        'date': '2025-12-08',
        'steps': 7500,
        'calories': 300,
        'water': 1800,
      };

      final record = HealthRecord.fromMap(map);

      expect(record.id, 2);
      expect(record.date, '2025-12-08');
      expect(record.steps, 7500);
      expect(record.calories, 300);
      expect(record.water, 1800);
    });
  });
}
