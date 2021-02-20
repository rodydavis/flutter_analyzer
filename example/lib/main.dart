import 'package:flutter/material.dart';
import 'package:flutter_analyzer/flutter_analyzer.dart';

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
            icon: Icon(Icons.style),
            onPressed: ready ? this.format : null,
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

  Widget _buildClassSettings(BuildContext context, ClassVisitor kclass) {
    final alphaNumeric = RegExp(r'^[a-zA-Z0-9]+$');
    final numbers = RegExp(r'^[0-9]+$');
    final letters = RegExp(r'^[a-zA-Z]+$');
    final symbols = RegExp(r"[^\s\w]");
    return ExpansionTile(
      title: Text(kclass.name),
      children: [
        PropertyField(
          label: 'Class Name',
          name: kclass.name,
          onChange: (val) {
            this._controller.parser!.renameClass(kclass.name, val);
          },
          validator: (val) {
            if (val == null) return 'must contain a value';
            if (val.contains(' ')) return 'cannot contain spaces';
            if (val.isEmpty) return 'cannot be empty';
            final _index = val.lastIndexOf('_');
            if (_index == val.length) return 'must contain letter';
            if (val.contains(symbols, _index == -1 ? 0 : _index))
              return 'must contain letters and numbers';
            if (val.startsWith(RegExp('[0-9]')))
              return 'cannot start with number';
            return null;
          },
        ),
        for (final field in kclass.fields)
          for (final variable in field.variables)
            PropertyField(
              label: 'Field Name',
              name: variable.name,
              onChange: (val) {
                this
                    ._controller
                    .parser!
                    .renameVariable(kclass.name, variable.name, val);
              },
              validator: (val) {
                if (val == null) return 'must contain a value';
                if (val.contains(' ')) return 'cannot contain spaces';
                if (val.isEmpty) return 'cannot be empty';
                final _index = val.lastIndexOf('_');
                if (_index == val.length) return 'must contain letter';
                if (val.contains(symbols, _index == -1 ? 0 : _index))
                  return 'must contain letters and numbers';
                if (val.startsWith(RegExp('[0-9]')))
                  return 'cannot start with number';
                return null;
              },
            ),
      ],
    );
  }

  void _update() {
    if (_controller.text != _controller.parser?.code) {
      if (mounted) setState(() {});
    }
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

  void format() {
    _controller.text = Formatter(_controller.text).format();
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}

class PropertyField extends StatefulWidget {
  const PropertyField({
    Key? key,
    required this.label,
    required this.name,
    required this.onChange,
    this.validator,
  }) : super(key: key);

  final String name, label;
  final ValueChanged<String> onChange;
  final String? Function(String?)? validator;

  @override
  _PropertyFieldState createState() => _PropertyFieldState();
}

class _PropertyFieldState extends State<PropertyField> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.name;
  }

  @override
  void didUpdateWidget(covariant PropertyField oldWidget) {
    if (_controller.text != widget.name) _controller.text = widget.name;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
      ),
      validator: widget.validator,
      onSaved: (val) => widget.onChange(val!),
    );
  }
}
