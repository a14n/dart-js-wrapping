// Copyright (c) 2016, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

/// A generator that will try to generate recursively until 2 consecutive
/// generations output the same result.
abstract class IncrementalGenerator extends Generator {
  final int maxIterations;

  const IncrementalGenerator({this.maxIterations = 1000});

  Future<String> generateForLibraryElement(
      LibraryReader library, BuildStep buildStep);

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final element = library.element;
    final generatedPart = getGeneratedPart(element);

    if (generatedPart == null) return null;

    // back up the initial content of the part to restore at the end
    String genContent, initialContent;
    try {
      final initialContent = element.context.getContents(generatedPart.source).data;
      genContent = initialContent;
    } on StateError { // ignore: avoid_catching_errors
      genContent = '';
    }

    // generate content several times until 2 consecutive contents are equals
    var iterationsLeft = maxIterations;
    while (true) { // ignore: literal_only_boolean_expressions
      if (iterationsLeft-- < 0)
        throw StateError('No stable content after $maxIterations generations');

      final nextGenContent =
          await generateForLibraryElement(library, buildStep);

      // exit if stable
      if (nextGenContent == genContent) break;

      genContent = nextGenContent;

      // next increment : add current genContent to initial content
      element.context.applyChanges(
          ChangeSet()..changedContent(generatedPart.source, genContent));
    }

    // reset part to its initial content
    element.context.applyChanges(initialContent == null
        ? (ChangeSet()..removedSource(generatedPart.source))
        : (ChangeSet()..changedContent(generatedPart.source, initialContent)));

    return genContent;
  }

  CompilationUnitElement getGeneratedPart(LibraryElement lib) {
    final genPartName = _getGeneratedPartName(lib);
    final genPartPath = path
        .normalize(path.join(path.dirname(lib.source.uri.path), genPartName));
    return lib.units.firstWhere((u) => u.source.uri.path == genPartPath,
        orElse: () => null);
  }

  /// Returns the file name of the generated part
  String _getGeneratedPartName(LibraryElement lib) {
    final name = lib.source.shortName;
    return '${name.substring(0, name.length - '.dart'.length)}.g.dart';
  }
}
