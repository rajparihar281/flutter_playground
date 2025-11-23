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

  // Stores properties like 'padding', 'color'
  Map<String, dynamic> _currentValues = {};

  // Stores the view mode: 'single' or 'grid'
  String _layoutMode = 'single';

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    await _server.start();
    _server.updateStream.listen((data) {
      setState(() {
        // Handle Layout switching
        if (data['type'] == 'layout') {
          _layoutMode = data['layout'];
        }
        // Handle Property updates
        else {
          _currentValues = {..._currentValues, ...data};
        }
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
    // 1. Build the user's widget with current values
    final userWidget = widget.builder(context, _currentValues);

    // 2. Check which mode we are in
    if (_layoutMode == 'grid') {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: ResponsiveViewer(child: userWidget),
      );
    }

    // Default: Single View
    return userWidget;
  }
}

/// A helper widget that displays the child in 3 different sizes (Phone, Tablet, Desktop)
class ResponsiveViewer extends StatelessWidget {
  final Widget child;
  const ResponsiveViewer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Mobile (375px)'),
          _previewContainer(width: 375, height: 600, child: child),

          _label('Tablet (800px)'),
          _previewContainer(width: 800, height: 600, child: child),

          _label('Desktop (1200px)'),
          _previewContainer(width: 1200, height: 800, child: child),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 20),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
    ),
  );

  Widget _previewContainer({
    required double width,
    required double height,
    required Widget child,
  }) {
    // We use FittedBox to scale the large screens down to fit on the phone screen
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.white,
      ),
      child: AspectRatio(
        aspectRatio: width / height, // Keep original aspect ratio
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            height: height,
            child: child, // The actual widget running in simulated size
          ),
        ),
      ),
    );
  }
}
