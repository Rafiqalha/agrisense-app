typedef JsonMap = Map<String, dynamic>;

class FarmerProfile {
  const FarmerProfile({
    required this.userId,
    required this.name,
    required this.phone,
    required this.status,
  });

  final String userId;
  final String name;
  final String phone;
  final String status;

  factory FarmerProfile.fromJson(JsonMap json) => FarmerProfile(
    userId: _text(json, 'user_id'),
    name: _text(json, 'name'),
    phone: _text(json, 'phone'),
    status: _text(json, 'status'),
  );

  JsonMap toJson() => {
    'user_id': userId,
    'name': name,
    'phone': phone,
    'status': status,
  };
}

class Farm {
  const Farm({
    required this.id,
    required this.name,
    required this.areaHectares,
    required this.soilType,
    required this.irrigationType,
    required this.activeCropCount,
  });

  final String id;
  final String name;
  final String? areaHectares;
  final String? soilType;
  final String? irrigationType;
  final int activeCropCount;

  factory Farm.fromJson(JsonMap json) => Farm(
    id: _text(json, 'id'),
    name: _text(json, 'name'),
    areaHectares: _optionalText(json, 'area_hectares'),
    soilType: _optionalText(json, 'soil_type'),
    irrigationType: _optionalText(json, 'irrigation_type'),
    activeCropCount: _integer(json, 'active_crop_count'),
  );
}

class Crop {
  const Crop({
    required this.id,
    required this.farmId,
    required this.cropType,
    required this.seedVariety,
    required this.plantedAt,
    required this.ageDays,
    required this.status,
    required this.cultivationSystem,
    required this.cultivationUnitCount,
    required this.areaHectares,
    required this.expectedHarvestAt,
  });

  final String id;
  final String farmId;
  final String cropType;
  final String? seedVariety;
  final DateTime plantedAt;
  final int ageDays;
  final String status;
  final String? cultivationSystem;
  final int? cultivationUnitCount;
  final String? areaHectares;
  final DateTime? expectedHarvestAt;

  factory Crop.fromJson(JsonMap json) => Crop(
    id: _text(json, 'id'),
    farmId: _text(json, 'farm_id'),
    cropType: _text(json, 'crop_type'),
    seedVariety: _optionalText(json, 'seed_variety'),
    plantedAt: _date(json, 'planted_at'),
    ageDays: _integer(json, 'age_days'),
    status: _text(json, 'status'),
    cultivationSystem: _optionalText(json, 'cultivation_system'),
    cultivationUnitCount: _optionalInteger(json, 'cultivation_unit_count'),
    areaHectares: _optionalText(json, 'area_hectares'),
    expectedHarvestAt: _optionalDate(json, 'expected_harvest_at'),
  );
}

class Harvest {
  const Harvest({
    required this.id,
    required this.farmId,
    required this.cropId,
    required this.yieldKg,
    required this.qualityGrade,
    required this.pricePerKg,
    required this.harvestedAt,
  });

  final String id;
  final String farmId;
  final String cropId;
  final String yieldKg;
  final String? qualityGrade;
  final String? pricePerKg;
  final DateTime harvestedAt;

  factory Harvest.fromJson(JsonMap json) => Harvest(
    id: _text(json, 'id'),
    farmId: _text(json, 'farm_id'),
    cropId: _text(json, 'crop_id'),
    yieldKg: _text(json, 'yield_kg'),
    qualityGrade: _optionalText(json, 'quality_grade'),
    pricePerKg: _optionalText(json, 'price_per_kg'),
    harvestedAt: _date(json, 'harvested_at'),
  );
}

class FarmActivity {
  const FarmActivity({
    required this.id,
    required this.activityType,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.performedAt,
  });

  final String id;
  final String activityType;
  final String description;
  final String? quantity;
  final String? unit;
  final DateTime performedAt;

  factory FarmActivity.fromJson(JsonMap json) => FarmActivity(
    id: _text(json, 'id'),
    activityType: _text(json, 'activity_type'),
    description: _text(json, 'description'),
    quantity: _optionalText(json, 'quantity'),
    unit: _optionalText(json, 'unit'),
    performedAt: _date(json, 'performed_at'),
  );
}

class CreditScore {
  const CreditScore({
    required this.status,
    required this.score,
    required this.calculatedAt,
    required this.validUntil,
  });

  final String status;
  final String? score;
  final DateTime? calculatedAt;
  final DateTime? validUntil;

  factory CreditScore.fromJson(JsonMap json) => CreditScore(
    status: _text(json, 'status'),
    score: _optionalText(json, 'score'),
    calculatedAt: _optionalDate(json, 'calculated_at'),
    validUntil: _optionalDate(json, 'valid_until'),
  );
}

class ReadSection<T> {
  const ReadSection({required this.status, required this.data, this.reason});

  final String status;
  final T? data;
  final String? reason;
  bool get isAvailable => status == 'available' && data != null;

  factory ReadSection.fromJson(
    dynamic value,
    T Function(dynamic value) readData,
  ) {
    final json = _map(value);
    final status = _text(json, 'status');
    if (!['available', 'unavailable', 'error'].contains(status)) {
      throw const FormatException('Status bagian dashboard tidak valid.');
    }
    final raw = json['data'];
    return ReadSection(
      status: status,
      data: raw == null ? null : readData(raw),
      reason: _optionalText(json, 'reason'),
    );
  }
}

class FarmerDashboard {
  const FarmerDashboard({
    required this.profile,
    required this.generatedAt,
    required this.dataEnvironment,
    required this.farms,
    required this.crops,
    required this.harvests,
    required this.activities,
    required this.creditScore,
  });

  final FarmerProfile profile;
  final DateTime generatedAt;
  final String dataEnvironment;
  final ReadSection<List<Farm>> farms;
  final ReadSection<List<Crop>> crops;
  final ReadSection<List<Harvest>> harvests;
  final ReadSection<List<FarmActivity>> activities;
  final ReadSection<CreditScore> creditScore;

  bool get hasPartialFailure => [
    farms.status,
    crops.status,
    harvests.status,
    activities.status,
  ].any((status) => status != 'available');

  factory FarmerDashboard.fromJson(JsonMap json) => FarmerDashboard(
    profile: FarmerProfile.fromJson(_map(json['profile'])),
    generatedAt: _date(json, 'generated_at'),
    dataEnvironment: _text(json, 'data_environment'),
    farms: ReadSection.fromJson(
      json['farms'],
      (value) => _list(value).map((row) => Farm.fromJson(_map(row))).toList(),
    ),
    crops: ReadSection.fromJson(
      json['crops'],
      (value) => _list(value).map((row) => Crop.fromJson(_map(row))).toList(),
    ),
    harvests: ReadSection.fromJson(
      json['harvests'],
      (value) =>
          _list(value).map((row) => Harvest.fromJson(_map(row))).toList(),
    ),
    activities: ReadSection.fromJson(
      json['activities'],
      (value) =>
          _list(value).map((row) => FarmActivity.fromJson(_map(row))).toList(),
    ),
    creditScore: ReadSection.fromJson(
      json['credit_score'],
      (value) => CreditScore.fromJson(_map(value)),
    ),
  );
}

JsonMap _map(dynamic value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Objek API tidak valid.');
  }
  return value;
}

List<dynamic> _list(dynamic value) {
  if (value is! List<dynamic> || value.length > 25) {
    throw const FormatException('Daftar API tidak valid.');
  }
  return value;
}

String _text(JsonMap json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key tidak valid.');
  }
  return value;
}

String? _optionalText(JsonMap json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key tidak valid.');
  }
  return value;
}

int _integer(JsonMap json, String key) {
  final value = json[key];
  if (value is! int || value < 0) throw FormatException('$key tidak valid.');
  return value;
}

int? _optionalInteger(JsonMap json, String key) {
  if (json[key] == null) return null;
  return _integer(json, key);
}

DateTime _date(JsonMap json, String key) {
  final value = _text(json, key);
  final parsed = DateTime.tryParse(value);
  if (parsed == null) throw FormatException('$key tidak valid.');
  return parsed;
}

DateTime? _optionalDate(JsonMap json, String key) {
  if (json[key] == null) return null;
  return _date(json, key);
}
