import 'dart:convert';

class Artwork {
  final String id;
  final String title;
  final String? artist;
  final int? yearCreated;
  final String? medium;
  final double? widthCm;
  final double? heightCm;
  final double? depthCm;
  final double? weightKg;
  final int? editionNumber;
  final int? editionSize;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? purchaseCurrency;
  final String? seller;
  final double? estimatedValue;
  final String? location;
  final String? condition; // mint, excellent, good, fair, poor
  final String? conditionNotes;
  final String? provenance;
  final String? notes;
  final bool isFavorite;
  final String? coverPhotoPath;
  final List<String> photoPaths;
  final List<String> tags;
  final List<String> collectionIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Artwork({
    required this.id,
    required this.title,
    this.artist,
    this.yearCreated,
    this.medium,
    this.widthCm,
    this.heightCm,
    this.depthCm,
    this.weightKg,
    this.editionNumber,
    this.editionSize,
    this.purchaseDate,
    this.purchasePrice,
    this.purchaseCurrency = 'USD',
    this.seller,
    this.estimatedValue,
    this.location,
    this.condition,
    this.conditionNotes,
    this.provenance,
    this.notes,
    this.isFavorite = false,
    this.coverPhotoPath,
    this.photoPaths = const [],
    this.tags = const [],
    this.collectionIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Artwork copyWith({
    String? id,
    String? title,
    String? artist,
    int? yearCreated,
    String? medium,
    double? widthCm,
    double? heightCm,
    double? depthCm,
    double? weightKg,
    int? editionNumber,
    int? editionSize,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? purchaseCurrency,
    String? seller,
    double? estimatedValue,
    String? location,
    String? condition,
    String? conditionNotes,
    String? provenance,
    String? notes,
    bool? isFavorite,
    String? coverPhotoPath,
    List<String>? photoPaths,
    List<String>? tags,
    List<String>? collectionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Artwork(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      yearCreated: yearCreated ?? this.yearCreated,
      medium: medium ?? this.medium,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      depthCm: depthCm ?? this.depthCm,
      weightKg: weightKg ?? this.weightKg,
      editionNumber: editionNumber ?? this.editionNumber,
      editionSize: editionSize ?? this.editionSize,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseCurrency: purchaseCurrency ?? this.purchaseCurrency,
      seller: seller ?? this.seller,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      location: location ?? this.location,
      condition: condition ?? this.condition,
      conditionNotes: conditionNotes ?? this.conditionNotes,
      provenance: provenance ?? this.provenance,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      photoPaths: photoPaths ?? this.photoPaths,
      tags: tags ?? this.tags,
      collectionIds: collectionIds ?? this.collectionIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'yearCreated': yearCreated,
      'medium': medium,
      'widthCm': widthCm,
      'heightCm': heightCm,
      'depthCm': depthCm,
      'weightKg': weightKg,
      'editionNumber': editionNumber,
      'editionSize': editionSize,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'purchasePrice': purchasePrice,
      'purchaseCurrency': purchaseCurrency,
      'seller': seller,
      'estimatedValue': estimatedValue,
      'location': location,
      'condition': condition,
      'conditionNotes': conditionNotes,
      'provenance': provenance,
      'notes': notes,
      'isFavorite': isFavorite ? 1 : 0,
      'coverPhotoPath': coverPhotoPath,
      'photoPathsJson': jsonEncode(photoPaths),
      'tagsJson': jsonEncode(tags),
      'collectionIdsJson': jsonEncode(collectionIds),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Artwork.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      try {
        final decoded = jsonDecode(raw as String);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    return Artwork(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String?,
      yearCreated: map['yearCreated'] as int?,
      medium: map['medium'] as String?,
      widthCm: (map['widthCm'] as num?)?.toDouble(),
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      depthCm: (map['depthCm'] as num?)?.toDouble(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      editionNumber: map['editionNumber'] as int?,
      editionSize: map['editionSize'] as int?,
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.tryParse(map['purchaseDate'] as String)
          : null,
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble(),
      purchaseCurrency: map['purchaseCurrency'] as String? ?? 'USD',
      seller: map['seller'] as String?,
      estimatedValue: (map['estimatedValue'] as num?)?.toDouble(),
      location: map['location'] as String?,
      condition: map['condition'] as String?,
      conditionNotes: map['conditionNotes'] as String?,
      provenance: map['provenance'] as String?,
      notes: map['notes'] as String?,
      isFavorite: (map['isFavorite'] == 1 || map['isFavorite'] == true),
      coverPhotoPath: map['coverPhotoPath'] as String?,
      photoPaths: parseList(map['photoPathsJson']),
      tags: parseList(map['tagsJson']),
      collectionIds: parseList(map['collectionIdsJson']),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
