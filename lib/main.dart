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
  final _controller = DartController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller.text = DEFAULT_CODE;
    _controller.addListener(_update);
    this._update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: ready ? this.refresh : null,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: ready ? this.save : null,
          ),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: NotificationListener<CodeSelection<String>>(
              onNotification: (message) {
                final ctx = ScaffoldMessenger.of(context);
                ctx.hideCurrentSnackBar();
                ctx.showSnackBar(SnackBar(content: Text(message.value)));
                return true;
              },
              child: TextField(
                expands: true,
                maxLength: null,
                maxLines: null,
                controller: _controller,
                onEditingComplete: this.save,
                onChanged: (val) {
                  _controller.analyze();
                },
              ),
            ),
          ),
          Container(
            width: 400,
            child: !ready
                ? CircularProgressIndicator()
                : Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: ListView(
                      children: [
                        for (final item in _controller.parser!.visitor.classes)
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
        ClassField(
          name: visitor.name,
          onChange: (val) {
            this._controller.parser!.renameClass(visitor.name, val);
          },
        ),
      ],
    );
  }

  void _update() {
    if (mounted) setState(() {});
  }

  bool get ready => _controller.parser != null;
  void save() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final src = _controller.parser!.toSource();
      // print(src);
      _controller.text = Formatter(src).format();
    }
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}

class ClassField extends StatefulWidget {
  const ClassField({
    Key? key,
    required this.name,
    required this.onChange,
  }) : super(key: key);

  final String name;
  final ValueChanged<String> onChange;

  @override
  _ClassFieldState createState() => _ClassFieldState();
}

class _ClassFieldState extends State<ClassField> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.name;
  }

  @override
  void didUpdateWidget(covariant ClassField oldWidget) {
    if (_controller.text != widget.name) _controller.text = widget.name;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      validator: (val) {
        if (val == null) return 'must contain a value';
        if (val.contains(' ')) return 'cannot contain spaces';
        if (!val.startsWith(RegExp(r'[A-Z][a-z]')))
          return 'must start with a letter';
        return null;
      },
      onSaved: (val) => widget.onChange(val!),
    );
  }
}
