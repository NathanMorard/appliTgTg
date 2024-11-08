import 'package:flutter/material.dart';

// Importation des différentes pages
import 'pages/Home/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TgTg Notifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: '/', 
      routes: {
        // La route pour la page d'accueil
        '/': (context) => HomePage(),
      },
    );
  }
}
