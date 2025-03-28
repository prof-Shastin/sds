import 'package:flutter/material.dart';
import 'package:sds_web/model/model.dart';
import 'dental_item.dart';
import 'dental_view.dart';

class ExamItem {
  final _sel = ValueNotifier(DentalItemSelect.none);
  final int id;
  final String dt;
  late final void Function(int, DentalData) _onSelect;
  late final void Function(int) _onRemove;
  late final bool Function() _canRemove;
  late final DentalView _dentalView;
  late final Model _model;
  DentalData get data => _dentalView.data;

  ExamItem({
    required Model model,
    required this.id,
    required this.dt,
    required void Function(int, DentalData) onSelect,
    required void Function(int) onRemove,
    required bool Function() canRemove,
    required bool load,
  }) {
    _model = model;
    _onSelect = onSelect;
    _onRemove = onRemove;
    _canRemove = canRemove;
    _dentalView = DentalView(
      model: model,
      onImageLoad: (dd) {
        if (_isSelect) _onSelect(id, dd);
      },
    );
    _dentalView.setImage(id);
    if (load) _dentalView.load();
  }

  bool get _isSelect =>
      _sel.value == DentalItemSelect.select ||
      _sel.value == DentalItemSelect.overSelect;

  bool get _isOver =>
      _sel.value == DentalItemSelect.over ||
      _sel.value == DentalItemSelect.overSelect;

  void _setSel(bool s, bool o) {
    _sel.value = s
        ? o
            ? DentalItemSelect.overSelect
            : DentalItemSelect.select
        : o
            ? DentalItemSelect.over
            : DentalItemSelect.none;
  }

  void _select(bool s) => _setSel(s, _isOver);

  void _over(bool o) => _setSel(_isSelect, o);

  void select(int selId) => _select(selId == id);

  void change(DentalData dd) {
    _dentalView.setImage(id, dd);
  }

  void dispose() {
    _dentalView.dispose();
    _sel.dispose();
  }

  void _remove(BuildContext context) {
    confirm(
      context,
      'Удалить осмотр от $dt',
      'Нет',
      'Удалить',
    ).then((isCancel) {
      if (isCancel != true) return;
      final post = {
        'patient_id': _model.patient.value.id,
        'type': 'exam',
        'id': id,
      };
      _model.post('/formula/remove', post).then((d) {
        _onRemove(id);
      });
    });
  }

  Widget build() {
    return GestureDetector(
      onTap: () => _onSelect(id, _dentalView.data),
      child: MouseRegion(
        onEnter: (e) => _over(true),
        onExit: (e) => _over(false),
        child: ValueListenableBuilder(
          valueListenable: _sel,
          builder: (context, sel, child) {
            final rem = _isSelect && _canRemove();
            return Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              height: 250,
              color: Color(_isOver
                  ? _isSelect
                      ? 0xFFCFE3E8
                      : 0x80BDDDFC
                  : _isSelect
                      ? 0xFFCFE3E8
                      : 0xffffffff),
              child: Column(
                children: [
                  SizedBox(
                    height: 45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 40,
                          child: rem
                              ? IconButton(
                                  padding: EdgeInsets.zero,
                                  color: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  icon: Icon(Icons.close,
                                      size: 30, color: Colors.red),
                                  onPressed: () => _remove(context),
                                )
                              : null,
                        ),
                        Text(
                          dt,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff002C52),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Expanded(child: _dentalView.build()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
