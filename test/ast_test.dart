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
    expect(parser.visitor.classes[0].constructors.length == 0, equals(true));
    expect(parser.visitor.classes[0].fields.length == 0, equals(true));
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

class MyApp extends StatelessWidget with You implements Me {
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

abstract class Me {

}

mixin You {

}
''';
    final parser = FlutterParser.fromString(SOURCE_CODE);
    expect(parser.result.errors.length == 0, equals(true));
    expect(parser.visitor.classes[0].name, equals('MyApp'));
    expect(parser.visitor.classes[0].extendsClause, equals('StatelessWidget'));
    expect(parser.visitor.classes[0].implementsClause, equals(['Me']));
    expect(parser.visitor.classes[0].withClause, equals(['You']));
    expect(parser.visitor.classes[1].name, equals('MyWidget'));
    parser.debug();
  });

  test('modify multiple properties', () {
    const SOURCE_CODE = r'''
class MyClass {
  MyClass(this.value);
  MyClass.info(this.value);
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
    expect(obj.constructors[0].name, equals(null));
    expect(obj.constructors[1].name, equals('info'));
    expect(fieldA.name, equals('a'));
    expect(fieldB.name, equals('b'));
    obj.name = 'MyClass1';
    fieldA.name = 'a1';
    fieldB.name = 'b1';
    obj.constructors[1].name = 'about';
    expect(obj.name, equals('MyClass1'));
    expect(obj.constructors[1].name, equals('about'));
    expect(fieldA.name, equals('a1'));
    expect(fieldB.name, equals('b1'));
  });

  test('test enums', () {
    const SOURCE_CODE = r'''
enum MyEnum {one, two, three}
''';
    final parser = FlutterParser.fromString(SOURCE_CODE);
    expect(parser.result.errors.length == 0, equals(true));
    final obj = parser.visitor.enums[0];
    expect(obj.name, equals('MyEnum'));
    expect(obj.values[1].name, equals('two'));
    obj.name = 'MyEnum1';
    obj.values[1].name = 'two1';
    expect(obj.name, equals('MyEnum1'));
    expect(obj.values[1].name, equals('two1'));
  });
}
