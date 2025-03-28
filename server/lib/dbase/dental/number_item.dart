class NumberItem {
  final int numberId;
  final int index;
  final String title;
  final String family;
  final num size;
  final int color;
  final bool bold;
  final bool italic;
  final num borderWidth;
  final int borderColor;

  const NumberItem(
    this.numberId,
    this.index,
    this.title,
    this.family,
    this.size,
    this.color,
    this.bold,
    this.italic,
    this.borderWidth,
    this.borderColor,
  );

  Map<String, dynamic> toJson() => {
        'numberId': numberId,
        'index': index,
        'title': title,
        'family': family,
        'size': size,
        'color': color,
        'bold': bold,
        'italic': italic,
        'borderWidth': borderWidth,
        'borderColor': borderColor,
      };

  factory NumberItem.fromJson(Map json) {
    final c1 = json['color'] as String?;
    final hex1 = c1 == null ? null : int.tryParse(c1, radix: 16);
    final c2 = json['colorBorder'] as String?;
    final hex2 = c2 == null ? null : int.tryParse(c2, radix: 16);
    var styleIndex = (json['fontStyle'] as int?) ?? 0;
    if (styleIndex < 0 || styleIndex >= 4) styleIndex = 0;
    return NumberItem(
      (json['numberId'] as int?) ?? 0,
      ((json['position'] as int?) ?? 1) - 1,
      (json['name'] as String?) ?? '',
      json['fontFamily'] ?? 'Arial',
      (json['fontSize'] as num?) ?? 15,
      0xff000000 + (hex1 ?? 0),
      (styleIndex & 1) != 0,
      (styleIndex & 2) != 0,
      ((json['widthBorder'] as num?) ?? 0) * 1,
      0xff000000 + (hex2 ?? 0),
    );
  }
}
