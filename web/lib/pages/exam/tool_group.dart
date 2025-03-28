import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'tool_item.dart';

class ToolGroup extends StatefulWidget {
  final DataToolGroup group;
  final Set<int> selected;
  final void Function(DataToolItem, bool) onTap;
  final void Function(DataToolItem?) onOver;
  final bool Function() canOpen;
  const ToolGroup({
    super.key,
    required this.group,
    required this.selected,
    required this.onTap,
    required this.onOver,
    required this.canOpen,
  });
  @override
  State<ToolGroup> createState() => _ToolGroupState();
}

class _ToolGroupState extends State<ToolGroup> {
  final open = ValueNotifier(true);
  final over = ValueNotifier(false);
  late final Model model;

  @override
  void initState() {
    model = context.read<Model>();
    super.initState();
  }

  @override
  void dispose() {
    open.dispose();
    over.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.group.items.length;
    final w = ((model.leftWitch - 1) / widthItem).floor();
    final h = (l / w).ceil();
    return ValueListenableBuilder(
      valueListenable: open,
      builder: (context, isOpen, child) => Column(
        children: [
          MouseRegion(
            onEnter: (_) => over.value = true,
            onExit: (_) => over.value = false,
            child: InkWell(
              onTap: () {
                if (widget.canOpen()) open.value = !open.value;
              },
              child: ValueListenableBuilder(
                valueListenable: over,
                builder: (context, isOver, child) => Container(
                  height: 34,
                  color: Color(isOver ? 0xffcfe3e8 : 0xffEBEFF3),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  margin: const EdgeInsets.only(top: 1, bottom: 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.group.name,
                        style:
                            TextStyle(color: Color(0xff002C52), fontSize: 16),
                      ),
                      Icon(
                        isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 34,
                        color: Color(0x80002C52),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isOpen)
            Column(
              children: List.generate(h, (row) {
                return Row(
                  children: List.generate(w, (col) {
                    final i = row * w + col;
                    if (i >= l) return const SizedBox();
                    return ToolItem(
                      item: widget.group.items[i],
                      isDown:
                          widget.selected.contains(widget.group.items[i].id),
                      onTap: widget.onTap,
                      onOver: widget.onOver,
                    );
                  }),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class DataToolGroup {
  final int id;
  final int sort;
  final String name;
  final String reportTitle;
  final String reportText;
  final List<DataToolItem> items;

  const DataToolGroup(
    this.id,
    this.sort,
    this.name,
    this.reportTitle,
    this.reportText,
    this.items,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sort': sort,
        'name': name,
        'reportTitle': reportTitle,
        'reportText': reportText,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory DataToolGroup.fromJson(Map json) => DataToolGroup(
        (json['id'] as int?) ?? 0,
        (json['sort'] as int?) ?? 0,
        (json['name'] as String?) ?? '',
        (json['reportTitle'] as String?) ?? '',
        (json['reportText'] as String?) ?? '',
        List<Map>.from((json['items'] as List?) ?? [])
            .map((e) => DataToolItem.fromJson(e))
            .toList(),
      );
}
