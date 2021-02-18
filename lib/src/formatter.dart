import 'package:dart_style/dart_style.dart';
import 'package:dart_style/src/source_visitor.dart';

class Formatter {
  Formatter(this.source);

  final String source;

  static final formatter = DartFormatter();

  String format() => formatter.format(source);
}
