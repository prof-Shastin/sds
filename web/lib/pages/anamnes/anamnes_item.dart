import 'package:flutter/material.dart';

class AnamnesItem {
  final int item_id;
  final int parent_id;
  final dynamic data;
  final EdgeInsets? padding;
  final TextStyle? titleStyle;
  final String imgCheckUrl;
  final void Function() onTap;
  final void Function(bool)? onInputEnd;

  final check = ValueNotifier(false);
  final answer = TextEditingController();
  final hidden = ValueNotifier(false);
  final input = ValueNotifier(false);
  final bg = ValueNotifier(false);

  final _over = ValueNotifier(false);
  final _btnEnabled = ValueNotifier(false);
  final _title = <TextSpan>[];
  final _info = <TextSpan>[];

  var enabled = true;

  AnamnesItem({
    required this.item_id,
    this.parent_id = 0,
    this.data,
    this.padding,
    required String title,
    this.titleStyle,
    required String info,
    required this.imgCheckUrl,
    required this.onTap,
    this.onInputEnd,
  }) {
    if (title.isNotEmpty) {
      '#0${title}'.split('#1').where((e) => e.isNotEmpty).forEach((ee) {
        final l = ee.split('#0').toList();
        _title.add(TextSpan(
            text: l.first, style: TextStyle(fontWeight: FontWeight.bold)));
        l.sublist(1).forEach((e) => _title.add(TextSpan(text: e)));
      });
    }
    if (info.isNotEmpty) {
      '#0${info}'.split('#1').where((e) => e.isNotEmpty).forEach((ee) {
        final l = ee.split('#0').toList();
        _info.add(TextSpan(
            text: l.first, style: TextStyle(fontWeight: FontWeight.bold)));
        l.sublist(1).forEach((e) => _info.add(TextSpan(text: e)));
      });
    }
    answer.addListener(ansverListener);
  }

  void ansverListener() => _btnEnabled.value = answer.text.isNotEmpty;

  void dispose() {
    answer.removeListener(ansverListener);
    check.dispose();
    answer.dispose();
    hidden.dispose();
    input.dispose();
    bg.dispose();
    _over.dispose();
    _btnEnabled.dispose();
  }

  Widget build() {
    return ValueListenableBuilder(
      valueListenable: hidden,
      builder: (context, isHidden, child) {
        if (isHidden) return SizedBox();
        return MouseRegion(
          onEnter: (_) {
            if (enabled) _over.value = true;
          },
          onExit: (_) {
            if (enabled) _over.value = false;
          },
          child: GestureDetector(
            onTap: () {
              if (!enabled) return;
              onTap();
            },
            child: ValueListenableBuilder(
              valueListenable: _over,
              builder: (context, isOver, child) => ValueListenableBuilder(
                valueListenable: bg,
                builder: (context, isBG, child) => Container(
                  key: UniqueKey(),
                  padding: padding ?? EdgeInsets.all(8),
                  decoration: isOver
                      ? const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Color(0xfff3f7fb),
                        )
                      : BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Color(isBG ? 0xffEBEFF3 : 0xffffffff),
                        ),
                  child: ValueListenableBuilder(
                    valueListenable: check,
                    builder: (context, ch, child) => ValueListenableBuilder(
                      valueListenable: input,
                      builder: (context, inp, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (ch) Image.network(imgCheckUrl, width: 25),
                              if (!ch) SizedBox(width: 25),
                              SizedBox(width: 20),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: RichText(
                                    text: TextSpan(
                                      style:
                                          (titleStyle ?? TextStyle()).copyWith(
                                        fontFamily:
                                            titleStyle?.fontFamily ?? 'Arial',
                                        fontSize: titleStyle?.fontSize ?? 18,
                                        height: titleStyle?.height ?? 1.5,
                                        color: titleStyle?.color ??
                                            Color(0xff002C52),
                                      ),
                                      children: _title,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_info.isNotEmpty && ch) SizedBox(height: 8),
                          if (_info.isNotEmpty && ch)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  margin: EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: Color(0xff408ca0),
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff408ca0),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 18,
                                        height: 1.5,
                                        color: Color(0xff408CA0),
                                      ),
                                      children: _info,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (ch && onInputEnd != null)
                            Padding(
                              padding: EdgeInsets.fromLTRB(44, 4, 0, 4),
                              child: Text(
                                'Ответ пациента:',
                                style: TextStyle(
                                    fontSize: 18, color: Color(0xff002C52)),
                              ),
                            ),
                          if (ch && onInputEnd != null && !inp)
                            Padding(
                              padding: EdgeInsets.only(left: 44),
                              child: Text(
                                answer.text,
                                style: TextStyle(
                                    fontSize: 18, color: Color(0xff408CA0)),
                              ),
                            ),
                          if (ch && inp)
                            Container(
                              width: 500,
                              margin: EdgeInsets.fromLTRB(44, 0, 0, 4),
                              decoration: BoxDecoration(
                                color: Color(0xffdbdfe3),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                              ),
                              child: TextField(
                                autofocus: true,
                                controller: answer,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xff002c52)),
                              ),
                            ),
                          if (ch && inp)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 44),
                                ValueListenableBuilder(
                                  valueListenable: _btnEnabled,
                                  builder: (context, enabled, child) =>
                                      ElevatedButton(
                                    onPressed: enabled
                                        ? () => onInputEnd?.call(true)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0xff002C52),
                                      shadowColor: Color(0xffd0e3e9),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.all(20),
                                    ),
                                    child: Text(
                                      'Принять',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () => onInputEnd?.call(false),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Color(0xffE84A4A),
                                    shadowColor: Color(0xffd0e3e9),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.all(20),
                                  ),
                                  child: Text(
                                    'Отменить',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
