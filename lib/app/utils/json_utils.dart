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

/// Safely parse an ID which can be either an int (e.g. 1) or a UUID String ("f47ac10b-58cc...").
dynamic parseId(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is double) return val.toInt();
  if (val is String) {
    final asInt = int.tryParse(val);
    return asInt ?? val;
  }
  return val;
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

/// Safely extract an ID (int or String UUID) from Get.arguments or Get.parameters.
dynamic extractIdParam([dynamic arguments, Map<String, dynamic>? parameters]) {
  if (arguments != null) {
    if (arguments is Map && arguments.containsKey('id')) {
     return parseId(arguments['id']);
   }
    return parseId(arguments);
  }
  if (parameters != null && parameters.containsKey('id')) {
   return parseId(parameters['id']);
  }
  return null;
}
