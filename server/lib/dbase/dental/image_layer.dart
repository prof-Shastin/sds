import 'image_item.dart';
import 'package:collection/collection.dart';

enum ImageLayerType { front, back, leftFront, rightFront, leftBack, rightBack }

class ImageLayer {
  final int id;
  final int buildToolId;
  final int numberId;
  final int switchDataId;
  final ImageLayerType type;
  final int sort;
  final ImageItem? image;
  final int color;
  final ImageItem? mask;
  final bool maskOnAll;

  ImageLayer(
    this.id,
    this.buildToolId,
    this.numberId,
    this.switchDataId,
    this.type,
    this.sort,
    this.image,
    this.color,
    this.mask,
    this.maskOnAll,
  );

  factory ImageLayer.fromJson(Map json, List<ImageItem> images) {
    final c = json['color'] as String?;
    final hex = c == null ? null : int.tryParse(c, radix: 16);
    final imageId = json['imageId'] as int?;
    final image = imageId == null
        ? null
        : images.firstWhereOrNull((e) => e.id == imageId);
    final maskImageId = json['maskImageId'] as int?;
    final mask = maskImageId == null
        ? null
        : images.firstWhereOrNull((e) => e.id == maskImageId);
    return ImageLayer(
      (json['id'] as int?) ?? 0,
      (json['buildToolId'] as int?) ?? 0,
      (json['numberId'] as int?) ?? 0,
      (json['switchDataId'] as int?) ?? 0,
      ImageLayerType.values[((json['type'] as int?) ?? 1) - 1],
      (json['sort'] as int?) ?? 0,
      image,
      hex ?? 0,
      mask,
      ((json['maskOnAll'] as int?) ?? 0) == 1,
    );
  }
}
