import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator.dart';

Builder jsWrappingBuilder(BuilderOptions options) =>
    SharedPartBuilder([JsWrappingGenerator()], 'js_wrapping_generator');
