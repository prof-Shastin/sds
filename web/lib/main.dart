import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/pages/panel.dart';
import 'model/model.dart';
import 'pages/login/login_hard.dart';
import 'pages/pages.dart';
import 'dart:html';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final model = Model();

  @override
  void initState() {
    super.initState();
    document.body!.addEventListener('contextmenu', (event) {
      event.preventDefault();
    });
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Model>.value(value: model),
      ],
      child: MaterialApp(
        //scrollBehavior: MyCustomScrollBehavior(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale('en'), const Locale('ru')],
        theme: ThemeData(
          fontFamily: 'Arial',
        ),
        home: Pages(
          initPage: 'panel',
          items: {
            'loginHard': const LoginHard(),
            'panel': const Panel(),
          },
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
