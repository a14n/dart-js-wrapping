import 'package:build/build.dart';
import 'package:js_wrapping_generator/js_wrapping_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder jsWrapping(BuilderOptions options) => PartBuilder([
      JsWrappingGenerator(),
    ]);
