class CollectionFolder {
  final String id;
  final String name;
  final String? iconName;
  final String? colorHex;
  final int sortOrder;
  final DateTime createdAt;

  CollectionFolder({
    required this.id,
    required this.name,
    this.iconName,
    this.colorHex,
    this.sortOrder = 0,
    required this.createdAt,
  });

  CollectionFolder copyWith({
    String? id,
    String? name,
    String? iconName,
    String? colorHex,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CollectionFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorHex': colorHex,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CollectionFolder.fromMap(Map<String, dynamic> map) {
    return CollectionFolder(
      id: map['id'] as String,
      name: map['name'] as String,
      iconName: map['iconName'] as String?,
      colorHex: map['colorHex'] as String?,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
