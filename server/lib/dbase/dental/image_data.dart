class ImageData {
  final int id;
  final String image;
  final String checksum;

  const ImageData(this.id, this.image, this.checksum);

  factory ImageData.fromJson(Map json) => ImageData(
        (json['id'] as int?) ?? 0,
        (json['image'] as String?) ?? '',
        (json['checksum'] as String?) ?? '',
      );
}

class ImageLink {
  final int id;
  final int imageId;
  final int dataImageId;
  final num scale;
  final num offsetX;
  final num offsetY;
  final int position;
  final int view;

  const ImageLink(
    this.id,
    this.imageId,
    this.dataImageId,
    this.scale,
    this.offsetX,
    this.offsetY,
    this.position,
    this.view,
  );

  factory ImageLink.fromJson(Map json) => ImageLink(
        (json['id'] as int?) ?? 0,
        (json['imageId'] as int?) ?? 0,
        (json['dataImageId'] as int?) ?? 0,
        (json['scale'] as num?) ?? 0,
        (json['offsetX'] as num?) ?? 0,
        (json['offsetY'] as num?) ?? 0,
        (json['position'] as int?) ?? 0,
        (json['view'] as int?) ?? 0,
      );
}
