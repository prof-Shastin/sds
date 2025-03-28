import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';

const widthItem = 50.0;

class ToolItem extends StatefulWidget {
  final DataToolItem item;
  final bool isDown;
  final void Function(DataToolItem, bool) onTap;
  final void Function(DataToolItem?) onOver;
  const ToolItem({
    super.key,
    required this.item,
    required this.isDown,
    required this.onTap,
    required this.onOver,
  });
  @override
  State<ToolItem> createState() => _ToolItemState();
}

class _ToolItemState extends State<ToolItem> {
  late final Model model;
  final over = ValueNotifier(false);

  @override
  void initState() {
    model = context.read<Model>();
    super.initState();
  }

  @override
  void dispose() {
    over.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onTap(widget.item, !widget.isDown),
      child: MouseRegion(
        onEnter: (_) {
          over.value = true;
          widget.onOver(widget.item);
        },
        onExit: (_) {
          over.value = false;
          widget.onOver(null);
        },
        child: ValueListenableBuilder(
          valueListenable: over,
          builder: (context, isOver, child) => Container(
            width: widthItem,
            height: widthItem,
            color: Color(widget.isDown
                ? isOver
                    ? 0xffc6e0f2
                    : 0xffcfe3e8
                : isOver
                    ? 0xffdeeefe
                    : 0xffffffff),
            padding: const EdgeInsets.all(5),
            child:
                Image.network(model.getApiImgUri('/tool/${widget.item.image}')),
          ),
        ),
      ),
    );
  }
}

class DataToolItem {
  final int id;
  final int groupId;
  final int sort;
  final String image;
  final String name;
  final int numberId;
  final int switchId;
  final Color switchColor;
  final int sortView;
  final bool defaultOn;
  final String reportShort;
  final String reportFull;

  const DataToolItem(
    this.id,
    this.groupId,
    this.sort,
    this.image,
    this.name,
    this.numberId,
    this.switchId,
    this.switchColor,
    this.sortView,
    this.defaultOn,
    this.reportShort,
    this.reportFull,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'sort': sort,
        'image': image,
        'name': name,
        'numberId': numberId,
        'switchId': switchId,
        'switchColor': switchColor.value.toRadixString(16),
        'sortView': sortView,
        'defaultOn': defaultOn,
        'reportShort': reportShort,
        'reportFull': reportFull,
      };

  factory DataToolItem.fromJson(Map json) {
    final c = json['switchColor'] as String?;
    final hex = c == null ? null : int.tryParse(c, radix: 16);
    return DataToolItem(
      (json['id'] as int?) ?? 0,
      (json['groupId'] as int?) ?? 0,
      (json['sort'] as int?) ?? 0,
      (json['image'] as String?) ?? '',
      (json['name'] as String?) ?? '',
      (json['numberId'] as int?) ?? 0,
      (json['switchId'] as int?) ?? 0,
      hex == null ? Colors.white : Color(0xff000000 + hex),
      (json['sortView'] as int?) ?? 0,
      ((json['defaultOn'] as int?) ?? 0) == 1,
      (json['reportShort'] as String?) ?? '',
      (json['reportFull'] as String?) ?? '',
    );
  }
}
