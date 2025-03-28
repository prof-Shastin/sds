class ImageItem {
  final int id;
  final String name;
  late final List<ImagePosition> items;

  ImageItem(this.id, this.name, int dentalCount) {
    items = List<ImagePosition>.filled(dentalCount, ImagePosition());
    for (var i = 0; i < items.length; i++) items[i] = ImagePosition();
  }

  factory ImageItem.fromJson(Map json, int dentalCount) => ImageItem(
        (json['id'] as int?) ?? 0,
        (json['name'] as String?) ?? '',
        dentalCount,
      );
}

class Offset {
  double x;
  double y;
  Offset(this.x, this.y);
}

class ImagePart {
  final double scale;
  final Offset offset;
  final String image;

  const ImagePart(
    this.scale,
    this.offset,
    this.image,
  );
}

class ImagePosition {
  ImagePart? top;
  ImagePart? middle;
  ImagePart? bottom;
  ImagePart? total;
}
