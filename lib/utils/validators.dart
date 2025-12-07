String? requiredValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'Required';
  return null;
}

String? numberValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'Required';
  final parsed = int.tryParse(v);
  if (parsed == null) return 'Enter a valid number';
  if (parsed < 0) return 'Must be >= 0';
  return null;
}
