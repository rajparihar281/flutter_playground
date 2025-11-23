import 'package:flutter/material.dart';
import 'package:flutter_playground/flutter_playground.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Playground Demo')),
        body: Center(
          // 1. Wrap your widget with Playground
          child: Playground(
            builder: (context, values) {
              // 2. Use the 'values' map to control properties
              // Default to 10.0 if no value is sent yet
              final double paddingVal =
                  (values['padding'] as num?)?.toDouble() ?? 10.0;

              return Container(
                color: Colors.blueAccent,
                padding: EdgeInsets.all(paddingVal), // <--- LIVE PROPERTY
                child: const Text(
                  'Edit my padding!',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
