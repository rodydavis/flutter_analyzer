import 'package:flutter/material.dart';

import 'src/controller.dart';
import 'src/default.dart';
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
  String? _value;

  /// Comment on a field
  String? value;

  /// Comment on field 2
  bool? a, b = true;
  final _controller = DartController();
  final _selection = ValueNotifier<CodeSelection?>(null);

  @override
  void initState() {
    super.initState();
    _controller.text = DEFAULT_CODE;
    final _parser = FlutterParser.fromString(DEFAULT_CODE);
    // print(_parser.formatted());
  }

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
      body: NotificationListener<CodeSelection>(
        onNotification: (selection) {
          print('selection: ${selection.value}');
          final controller = ScaffoldMessenger.of(context);
          controller.hideCurrentSnackBar();
          controller.showSnackBar(SnackBar(content: Text(selection.value())));
          _selection.value = selection;
          return true;
        },
        child: Row(
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
              child: ValueListenableBuilder<CodeSelection?>(
                valueListenable: _selection,
                builder: (context, selection, child) {
                  return selection == null
                      ? CircularProgressIndicator()
                      : Form(
                          key: UniqueKey(),
                          child: Column(
                            children: [
                              if (selection is CodeSelection<String>)
                                TextFormField(
                                  initialValue: selection.value(),
                                  onChanged: (val) {
                                    if (val.isEmpty) return;
                                    selection.onChanged(val);
                                  },
                                ),
                            ],
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void save() {
    _controller.update();
  }
}

/// Multiline Comment
/// Doc2 Comment
class Temp {}
