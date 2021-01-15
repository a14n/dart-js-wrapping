import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator.dart';

Builder jsWrappingBuilder(BuilderOptions options) =>
    LibraryBuilder(JsWrappingGenerator(),
        generatedExtension: '.js.g.dart');
