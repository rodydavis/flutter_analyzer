import 'package:flutter/material.dart';

import 'src/parser.dart';

void main() {
  runApp(MyApp());
}

/**
 * Block Comment
 * 
 * Another line
 */
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Analyzer',
      theme: ThemeData.light(),
      home: FlutterExample(),
    );
  }
}

/// Doc Comment
class FlutterExample extends StatefulWidget {
  const FlutterExample();
  const FlutterExample.icon();
  @override
  _FlutterExampleState createState() => _FlutterExampleState();
}

// Simple Comment
class _FlutterExampleState extends State<FlutterExample> {
  late FlutterParser _parser;
  String? _value;

  /// Comment on a field
  String? value;

  /// Comment on field 2
  bool? a, b = true;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: this.save,
          ),
        ],
      ),
      body: TextField(
        maxLength: null,
        maxLines: null,
        controller: _controller,
        onEditingComplete: this.save,
      ),
    );
  }

  void save() {
    this._parser = FlutterParser.fromString(_controller.text);
    this._parser.debug();
    this._controller.text = this._parser.formatted;
  }
}

/// Multiline Comment
/// Doc2 Comment
class Temp {}
