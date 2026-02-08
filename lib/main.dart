import 'package:flutter/material.dart';
import 'package:groceryapp/navigation/router-map.dart';
import 'package:signals/signals_flutter.dart';

import 'screens/browse_screen.dart';
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
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: appRouterMap,
    );
  }
}
