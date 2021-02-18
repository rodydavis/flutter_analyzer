import 'package:flutter_analyzer/src/parser/parser.dart';

import 'package:test/test.dart';

void main() {
  test('validate setup', () {
    const SOURCE_CODE = r'''
class MyClass {}
''';
    final parser = FlutterParser.fromString(SOURCE_CODE);
    expect(parser.result.errors.length == 0, equals(true));
    expect(parser.visitor.classes[0].name, equals('MyClass'));
  });

  test('check for errors', () {
    const SOURCE_CODE = r'''
class 1MyClass {}
''';
    final parser = FlutterParser.fromString(SOURCE_CODE);
    expect(parser.result.errors.length > 0, equals(true));
  });

  test('check flutter source', () {
    const SOURCE_CODE = r'''
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData.light(),
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Flutter Example'),
        ),
      );
  }
}
''';
    final parser = FlutterParser.fromString(SOURCE_CODE);
    expect(parser.result.errors.length == 0, equals(true));
    expect(parser.visitor.classes[0].name, equals('MyApp'));
    expect(parser.visitor.classes[1].name, equals('MyWidget'));
  });

  test('modify class name', () {
    const SOURCE_CODE = r'''
class MyClass {}
''';
    final parser = FlutterParser.fromString(SOURCE_CODE);
    expect(parser.result.errors.length == 0, equals(true));
    final obj = parser.visitor.classes[0];
    expect(obj.name, equals('MyClass'));
    obj.name = 'MyClass1';
    expect(obj.name, equals('MyClass1'));
  });

  test('modify class field', () {
    const SOURCE_CODE = r'''
class MyClass {
  int value = 0;
}
''';
    final parser = FlutterParser.fromString(SOURCE_CODE);
    expect(parser.result.errors.length == 0, equals(true));
    final obj = parser.visitor.classes[0].fields[0].variables[0];
    expect(obj.name, equals('value'));
    obj.name = 'value1';
    expect(obj.name, equals('value1'));
  });

  test('modify multiple properties', () {
    const SOURCE_CODE = r'''
class MyClass {
  int a = 0;
  int b = 0;
}
''';
    final parser = FlutterParser.fromString(SOURCE_CODE);
    expect(parser.result.errors.length == 0, equals(true));
    final obj = parser.visitor.classes[0];
    final fieldA = obj.fields[0].variables[0];
    final fieldB = obj.fields[1].variables[0];
    expect(obj.name, equals('MyClass'));
    expect(fieldA.name, equals('a'));
    expect(fieldB.name, equals('b'));
    obj.name = 'MyClass1';
    fieldA.name = 'a1';
    fieldB.name = 'b1';
    expect(obj.name, equals('MyClass1'));
    expect(fieldA.name, equals('a1'));
    expect(fieldB.name, equals('b1'));
  });

  test('modify class field and constructor', () {
    const SOURCE_CODE = r'''
class MyClass {
  MyClass(this.value);

  int value = 0;
}
''';
    final parser = FlutterParser.fromString(SOURCE_CODE);
    expect(parser.result.errors.length == 0, equals(true));
    final obj = parser.visitor.classes[0].fields[0].variables[0];
    expect(obj.name, equals('value'));
    obj.name = 'value1';
    expect(obj.name, equals('value1'));
    parser.debug();
  });
}
