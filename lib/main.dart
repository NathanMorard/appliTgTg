import 'package:flutter/material.dart';
import 'global_variable.dart' as globals;

// Importation des différentes pages
import 'pages/Home/home_page.dart';
import 'pages/tgtg/find_tgtg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String initialRoute = globals.savedClientId.isEmpty ? '/' : '/find';

    return MaterialApp(
      title: 'TgTg Notifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => HomePage(),
        '/find': (context) => FindTgTg(),
      },
    );
  }
}
