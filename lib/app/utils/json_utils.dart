int parseInt(dynamic val, [int defaultValue = 0]) {
  if (val == null) return defaultValue;
  if (val is int) return val;
  if (val is double) return val.toInt();
  if (val is String) return int.tryParse(val) ?? defaultValue;
  return defaultValue;
}

int? parseNullableInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is double) return val.toInt();
  if (val is String) return int.tryParse(val);
  return null;
}

double parseDouble(dynamic val, [double defaultValue = 0.0]) {
  if (val == null) return defaultValue;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? defaultValue;
  return defaultValue;
}

double? parseNullableDouble(dynamic val) {
  if (val == null) return null;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  if (val is String) return double.tryParse(val);
  return null;
}
