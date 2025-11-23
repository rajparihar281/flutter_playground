import 'package:flutter/material.dart';
import '../server/playground_server.dart';

/// A widget that wraps your component and enables live editing via a web dashboard.
class Playground extends StatefulWidget {
  final Widget Function(BuildContext context, Map<String, dynamic> values)
  builder;

  const Playground({super.key, required this.builder});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  final PlaygroundServer _server = PlaygroundServer();
  Map<String, dynamic> _currentValues = {};

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    await _server.start();
    // Listen to updates from the web dashboard
    _server.updateStream.listen((data) {
      setState(() {
        // Merge new values with existing ones
        _currentValues = {..._currentValues, ...data};
      });
    });
  }

  @override
  void dispose() {
    _server.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValues);
  }
}
