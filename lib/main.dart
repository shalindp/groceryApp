import 'package:flutter/material.dart';
import 'package:groceryapp/widgets/ProductCard.dart';

void main() {
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
          padding: EdgeInsets.only(top: 40),
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              ProductCard(),
              SizedBox(height: 20),
              ProductCard(),
              SizedBox(height: 8),
              ProductCard(),
              SizedBox(height: 8),
              ProductCard(),
            ],
          ),
        ),
      ),
    );
  }
}
