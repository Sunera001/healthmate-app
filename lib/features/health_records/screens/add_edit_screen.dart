import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/health_record.dart';
import '../providers/health_provider.dart';

class AddEditScreen extends StatefulWidget {
  final HealthRecord? existing;
  const AddEditScreen({super.key, this.existing});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateCtl;
  final _stepsCtl = TextEditingController();
  final _calCtl = TextEditingController();
  final _waterCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateCtl = TextEditingController(
      text: widget.existing?.date ?? DateFormat('yyyy-MM-dd').format(now),
    );
    _stepsCtl.text = widget.existing?.steps.toString() ?? '';
    _calCtl.text = widget.existing?.calories.toString() ?? '';
    _waterCtl.text = widget.existing?.water.toString() ?? '';
  }

  @override
  void dispose() {
    _dateCtl.dispose();
    _stepsCtl.dispose();
    _calCtl.dispose();
    _waterCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_dateCtl.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateCtl.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final rec = HealthRecord(
      id: widget.existing?.id,
      date: _dateCtl.text,
      steps: int.parse(_stepsCtl.text),
      calories: int.parse(_calCtl.text),
      water: int.parse(_waterCtl.text),
    );
    final provider = Provider.of<HealthProvider>(context, listen: false);
    if (widget.existing == null) {
      await provider.addRecord(rec);
    } else {
      await provider.updateRecord(rec);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
      Navigator.of(context).pop();
    }
  }

  String? _numValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final parsed = int.tryParse(v);
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0) return 'Must be >= 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Add Record' : 'Edit Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateCtl,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: _pickDate,
                validator: (v) => (v == null || v.isEmpty) ? 'Select a date' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _stepsCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Steps'),
                validator: _numValidator,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _calCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories'),
                validator: _numValidator,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _waterCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Water (ml)'),
                validator: _numValidator,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
