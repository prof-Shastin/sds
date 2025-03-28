import 'dart:async';

class QueueDental {
  final String path;
  final List<DentalItem> items;
  var isCompleted = false;
  var expired = DateTime.now();
  QueueDental(this.path, this.items);
}

class QueueItem {
  final DentalItem data;
  final completer = Completer<void>();
  QueueItem(this.data);
}

enum SelectType { none, one, left, right, all }

class SelectTool {
  final int toolId;
  final SelectType select;
  final Set<int> buttins;
  const SelectTool(this.toolId, this.select, this.buttins);
  factory SelectTool.fromJson(Map json) => SelectTool(
        (json['toolId'] as int?) ?? 0,
        SelectType.values[((json['select'] as int?) ?? 1) - 1],
        List<int>.from(json['buttons']).toSet(),
      );
}

class DentalItem {
  final int index;
  final String path;
  final List<SelectTool> list;
  var numberId = 0;
  DentalItem(this.index, this.numberId, this.path, this.list);
}

class DBDentalItem {
  final int id;
  final int index;
  final int toolId;
  final int btnId;
  final SelectType select;
  var sort = 0;
  var numberId = 0;
  var del = false;
  DBDentalItem(this.id, this.index, this.toolId, this.btnId, this.select);
  factory DBDentalItem.fromJson(Map json) => DBDentalItem(
        json['id'] as int,
        json['index'] as int,
        json['tool_id'] as int,
        json['btn_id'] as int,
        SelectType.values[json['select'] as int],
      );
  @override
  String toString() =>
      'DBDentalItem {\nid: $id,\nindex: $index,\ntoolId: $toolId,\nbtnId: $btnId,\nselect: $select\n}';
}
