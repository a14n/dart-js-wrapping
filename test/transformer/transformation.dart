// Copyright (c) 2014, Alexandre Ardhuin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:quiver/async.dart';
import 'package:unittest/unittest.dart';

import 'package:js_wrapping/transformer.dart';

void testTransformation(String spec, String source, String
    expectedContent, {solo: false}) {
  final t = solo ? solo_test : test;
  t(spec, () => transformContent(source).then((content) {
    expect(content, expectedContent);
  }));
}

Future<String> transformContent(String content) => transformAssets(
    [new Asset.fromString(new AssetId('foo', 'a/b/c.dart'), content)]).then(
    (outAsserts) {
  expect(outAsserts, hasLength(1));
  final asset = outAsserts.first;
  return asset.readAsString();
});

final resolvers = new Resolvers(dartSdkDirectory);

Future<List<Asset>> transformAssets(List<Asset> assets) {
  final transformerGroup = new JsWrappingTransformer(resolvers);
  final phases = transformerGroup.phases.map((e) => e.toList()).toList();
  List<Asset> outs = assets;
  return forEachAsync(phases, (phase) {
    return forEachAsync(phase, (transformer) {
      final newOuts = [];
      return forEachAsync(outs, (asset) {
        return transformer.isPrimary(asset.id).then((isPrimary) {
          final transform = new _MockTransform()
              ..ins = outs
              ..primaryInput = asset
              ..output = asset;
          return transformer.apply(transform).then((_) {
            newOuts.add(transform.output);
          });
        });
      }).then((_) {
        outs = newOuts;
      });
    });
  }).then((_) => outs);
}

class _MockTransform implements Transform {
  bool shouldConsumePrimary = false;
  Asset primaryInput;
  List<Asset> ins = [];
  Asset output;
  TransformLogger logger = new TransformLogger(_mockLogFn);

  _MockTransform();

  Future<Asset> getInput(AssetId id) => new Future.value(ins.firstWhere((a) =>
      a.id == id));

  void addOutput(Asset output) {
    if (output.id != primaryInput.id) throw new Error();
    this.output = output;
  }

  void consumePrimary() {
    shouldConsumePrimary = true;
  }

  readInput(id) => throw new UnimplementedError();
  Future<String> readInputAsString(AssetId id, {encoding}) {
    return ins.firstWhere((a) => a.id == id, orElse: () {
      final libAssetId = new AssetId(id.package, id.path.substring('lib/'.length
          ));
      return ins.firstWhere((a) => a.id == libAssetId, orElse: () =>
          new Asset.fromPath(libAssetId,
          'packages/${libAssetId.package}/${libAssetId.path}'));
    }).readAsString();
  }
  Future<bool> hasInput(id) => new Future.value(ins.any((a) => a.id == id));

  static void _mockLogFn(AssetId asset, LogLevel level, String message, span) {
    // Do nothing.
  }
}
