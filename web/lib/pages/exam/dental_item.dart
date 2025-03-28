import 'dart:typed_data';
import 'package:flutter/material.dart';

class SelectTool {
  final int toolId;
  final int btnId;
  const SelectTool(this.toolId, this.btnId);
}

class DentalData {
  final num ratioSize;
  final num ratioTextSize;
  final List<DentalDataItem> items;
  DentalData(this.ratioSize, this.ratioTextSize, this.items);
}

class DentalDataItem {
  Uint8List? image;
  var numberText = '';
  var numberStyle = TextStyle();
}

enum DentalItemSelect { none, over, select, overSelect }

class DentalItem {
  final int index;
  final sel = ValueNotifier(DentalItemSelect.none);
  final tools = <SelectTool>[];
  var data = DentalDataItem();
  var isSelectOld = false;

  DentalItem(this.index);

  bool get isSelect =>
      sel.value == DentalItemSelect.select ||
      sel.value == DentalItemSelect.overSelect;

  bool get isOver =>
      sel.value == DentalItemSelect.over ||
      sel.value == DentalItemSelect.overSelect;

  void setSel(bool s, bool o) {
    sel.value = s
        ? o
            ? DentalItemSelect.overSelect
            : DentalItemSelect.select
        : o
            ? DentalItemSelect.over
            : DentalItemSelect.none;
  }

  void select(bool s) => setSel(s, isOver);

  void over(bool o) => setSel(isSelect, o);
}
