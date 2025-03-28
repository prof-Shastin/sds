import 'package:flutter/material.dart';

class Pages extends StatefulWidget {
  final page = ValueNotifier<String>('');
  final Map<String, Widget> items;
  final String initPage;
  Pages({
    super.key,
    required this.items,
    required this.initPage,
  });
  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  @override
  void initState() {
    widget.page.value = widget.initPage;
    super.initState();
  }

  @override
  void dispose() {
    widget.page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: ValueListenableBuilder(
          valueListenable: widget.page,
          builder: (context, pageName, child) =>
              widget.items[pageName] ?? const SizedBox(),
        ),
      ),
    );
  }
}
