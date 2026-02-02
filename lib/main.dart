import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'screens/products_screen.dart';
import 'services/di_container.dart';

void main() {
  addServices();
  SignalsObserver.instance = null;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.only(top: 20, bottom: 0),
          child: ProductScreen(),
        ),
      ),
    );
  }
}
