class WishlistItem {
  final String id;
  final String title;
  final String? artist;
  final double? targetPrice;
  final String? currency;
  final String? whereSeen;
  final String? url;
  final String? notes;
  final String? imagePath;
  final int priority; // 1 (High), 2 (Medium), 3 (Low)
  final DateTime createdAt;
  final String? convertedArtworkId;

  WishlistItem({
    required this.id,
    required this.title,
    this.artist,
    this.targetPrice,
    this.currency = 'USD',
    this.whereSeen,
    this.url,
    this.notes,
    this.imagePath,
    this.priority = 2,
    required this.createdAt,
    this.convertedArtworkId,
  });

  WishlistItem copyWith({
    String? id,
    String? title,
    String? artist,
    double? targetPrice,
    String? currency,
    String? whereSeen,
    String? url,
    String? notes,
    String? imagePath,
    int? priority,
    DateTime? createdAt,
    String? convertedArtworkId,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      targetPrice: targetPrice ?? this.targetPrice,
      currency: currency ?? this.currency,
      whereSeen: whereSeen ?? this.whereSeen,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      convertedArtworkId: convertedArtworkId ?? this.convertedArtworkId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'targetPrice': targetPrice,
      'currency': currency,
      'whereSeen': whereSeen,
      'url': url,
      'notes': notes,
      'imagePath': imagePath,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'convertedArtworkId': convertedArtworkId,
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String?,
      targetPrice: (map['targetPrice'] as num?)?.toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      whereSeen: map['whereSeen'] as String?,
      url: map['url'] as String?,
      notes: map['notes'] as String?,
      imagePath: map['imagePath'] as String?,
      priority: (map['priority'] as num?)?.toInt() ?? 2,
      createdAt: DateTime.parse(map['createdAt'] as String),
      convertedArtworkId: map['convertedArtworkId'] as String?,
    );
  }
}
