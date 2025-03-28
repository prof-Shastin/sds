import 'package:flutter/material.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/exam/exam_item.dart';
import 'dental_item.dart';

const width = 300.0;

class ExamList {
  late final Model _model;
  late final void Function(int, bool, DentalData) _onSelect;
  ExamList({
    required Model model,
    required final void Function(int, bool, DentalData) onSelect,
  }) {
    _model = model;
    _onSelect = onSelect;
    _load();
  }

  final _list = <ExamItem>[];
  final _loaded = ValueNotifier(false);

  ExamItem _create(int id, String dt, bool load) {
    return ExamItem(
      model: _model,
      id: id,
      dt: dt,
      onSelect: (id, dd) {
        _list.forEach((i) => i.select(id));
        final isEdit =
            _list.first.id == id && _list.first.dt == _dtStr(DateTime.now());
        _onSelect(id, isEdit, dd);
      },
      onRemove: (removeId) {
        _loaded.value = false;
        _list.removeWhere((e) => e.id == removeId);
        final selId = _list.first.id;
        final items = _list.first.data;
        _list.forEach((i) => i.select(selId));
        final isEdit =
            _list.first.id == selId && _list.first.dt == _dtStr(DateTime.now());
        _onSelect(selId, isEdit, items);
        _loaded.value = true;
      },
      canRemove: () => _list.length > 1,
      load: load,
    );
  }

  void change(DentalData dd) {
    _list.first.change(dd);
  }

  void dispose() {
    _list.forEach((e) => e.dispose());
    _loaded.dispose();
  }

  String _dtStr(DateTime dt) {
    final mon = [
      '',
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${dt.day} ${mon[dt.month]} ${dt.year}';
  }

  void _load() {
    _loaded.value = false;
    final post = {'patient_id': _model.patient.value.id};
    _model.post('/formula/list', post).then((d) {
      final l = d as List;
      l.forEach((e) {
        final d = e as Map;
        final dt = d['dt'] as DateTime;
        _list.add(_create(d['id'], _dtStr(dt), true));
      });
      _list.first.select(_list.first.id);
      _loaded.value = true;
    });
  }

  void _add() {
    _loaded.value = false;
    final post = {
      'patient_id': _model.patient.value.id,
      'id': _list.first.id,
      'type': 'exam',
    };
    _model.post('/formula/add', post).then((d) {
      final m = d as Map;
      final newId = m['id'] as int;
      final dd = _list.first.data;
      _list.insert(0, _create(newId, _dtStr(DateTime.now()), false));
      _list.first.change(dd);
      _list.forEach((i) => i.select(newId));
      _onSelect(newId, _list.first.id == newId, dd);
      _loaded.value = true;
    });
  }

  Widget build() {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: RawMaterialButton(
              onPressed: _add,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xff002C52)),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Center(
                  child: Text(
                    'Создать осмотр',
                    style: TextStyle(fontSize: 14, color: Color(0xff002C52)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _loaded,
              builder: (context, isLoaded, child) {
                if (!isLoaded) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _list[index].build();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
