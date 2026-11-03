import 'package:flutter_test/flutter_test.dart';
import 'package:handcollect/data/models/artwork.dart';

void main() {
  test('Artwork model serialization and copyWith works properly', () {
    final now = DateTime.now();
    final artwork = Artwork(
      id: 'test-1',
      title: 'Handmade Ceramic Vase',
      artist: 'Studio Potter',
      yearCreated: 2024,
      medium: 'Stoneware & Ash Glaze',
      estimatedValue: 450.0,
      purchasePrice: 320.0,
      condition: 'Mint',
      createdAt: now,
      updatedAt: now,
    );

    expect(artwork.title, 'Handmade Ceramic Vase');
    expect(artwork.estimatedValue, 450.0);

    final map = artwork.toMap();
    final fromMap = Artwork.fromMap(map);
    expect(fromMap.id, 'test-1');
    expect(fromMap.title, 'Handmade Ceramic Vase');
    expect(fromMap.artist, 'Studio Potter');

    final fav = artwork.copyWith(isFavorite: true);
    expect(fav.isFavorite, true);
  });
}
