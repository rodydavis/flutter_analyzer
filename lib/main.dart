import 'package:flutter/material.dart';

import 'src/controller.dart';
import 'src/default.dart';
import 'src/formatter.dart';
import 'src/parser/parser.dart';

void main() {
  runApp(MyApp());
}

// ignore: slash_for_doc_comments
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
      theme: ThemeData.dark(),
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
  FlutterParser? parser;
  final _controller = DartController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller.text = DEFAULT_CODE;
    _controller.addListener(_update);
    this._update();
  }

  void _update() {
    parser = _controller.parser;
    if (mounted && parser != null) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: ready ? this.save : null,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: TextField(
              maxLength: null,
              maxLines: null,
              controller: _controller,
              onEditingComplete: this.save,
            ),
          ),
          Container(
            width: 400,
            child: !ready
                ? CircularProgressIndicator()
                : Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        for (final item in parser!.visitor.classes)
                          _buildClassSettings(context, item),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSettings(BuildContext context, ClassVisitor visitor) {
    return Column(
      children: [
        TextFormField(
          initialValue: visitor.name,
          validator: (val) {
            if (val == null) return 'must contain a value';
            return null;
          },
          onSaved: (val) {
            this.parser!.renameClass(visitor.name, val!);
          },
        ),
      ],
    );
  }

  bool get ready => parser != null;
  void save() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final src = parser!.toSource();
      print(src);
      _controller.text = Formatter(src).format();
    }
  }
}

/// Multiline Comment
/// Doc2 Comment
class Temp {}
