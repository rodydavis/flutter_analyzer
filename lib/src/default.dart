const DEFAULT_CODE = r'''
import 'package:flutter/material.dart';
import 'dart:html';

bool test() => true;
bool isDebug = true;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget with You implements Me {
  MyApp({this.value = 0});
  final int value;
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
      // const callback = () {};
      // callback();
      return Scaffold(
        appBar: AppBar(
          title: Text('Flutter Example'),
        ),
      );
  }
}

abstract class Me {
  bool get isTrue => true;
  set isTrue(bool val) {

  }
}

mixin You {

}
''';
