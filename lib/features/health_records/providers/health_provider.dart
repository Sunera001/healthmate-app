import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/health_record.dart';

class HealthProvider extends ChangeNotifier {
  List<HealthRecord> _records = [];
  List<HealthRecord> get records => _records;

  final DBHelper _db = DBHelper.instance;

  Future<void> loadRecords() async {
    _records = await _db.getAllRecords();
    notifyListeners();
  }

  Future<void> addRecord(HealthRecord r) async {
    await _db.insertRecord(r);
    await loadRecords();
  }

  Future<void> updateRecord(HealthRecord r) async {
    await _db.updateRecord(r);
    await loadRecords();
  }

  Future<void> deleteRecord(int id) async {
    await _db.deleteRecord(id);
    await loadRecords();
  }

  Future<void> deleteAllRecords() async {
    await _db.deleteAllRecords();
    await loadRecords();
  }

  Future<void> searchByDate(String date) async {
    _records = await _db.getRecordsByDate(date);
    notifyListeners();
  }

  // Utility: compute totals for a specific date
  Map<String, int> totalsForDate(String date) {
    final list = _records.where((r) => r.date == date);
    final steps = list.fold<int>(0, (a, b) => a + b.steps);
    final calories = list.fold<int>(0, (a, b) => a + b.calories);
    final water = list.fold<int>(0, (a, b) => a + b.water);
    return {'steps': steps, 'calories': calories, 'water': water};
  }
}
