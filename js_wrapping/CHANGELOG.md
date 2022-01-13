# v0.7.4 (2022-01-13)

- handle list cast in closures.

# v0.7.3 (2021-08-30)

- handle enum to avoid cast issue in closures.

# v0.7.2 (2021-08-12)

- Bind functions for Function returned by getters.

# v0.7.1 (2021-08-10)

- Bind functions for Function fields

# v0.7.0 (2021-03-09)

- migrate to null-safety

# v0.6.0 (2018-07-27)

- migration from `dart:js` to `package:js`.

# v0.5.0 (2018-07-27)

- migration to Dart 2.

# v0.4.9 (2018-07-06)

- Bump dependencies.

# v0.4.8 (2018-06-26)

- Fix issue in `JsList` and `JsMap` without codec.

# v0.4.7 (2018-04-13)

- Revert changes introduce in 0.4.6.

# v0.4.6 (2018-04-13)

- Fix `IdentityConverter` for dart2.

# v0.4.5 (2018-04-07)

- Remove unused codec in generated code.

# v0.4.4 (2018-04-06)

- Migrate to new build_runner system.

# v0.4.3 (2018-03-14)

- Fix runtime cast failure in `JsObjectAsMap.keys` for dart2.

# v0.4.2 (2017-06-30)

- Fix issue with js function unwrapping.

# v0.4.1 (2017-08-28)

- upgrade dependencies

# v0.4.0 (2017-06-20)

- Fix issue with [dart-lang/sdk#28371](https://github.com/dart-lang/sdk/issues/28371).

  **Breaking change**: use `factory _MyClass() => null;` instead of
  `external factory _MyClass()` for your construtor templates.
- remove comment generics syntax

# v0.2.0+1 (2015-06-01)

Fix issue with callback returning `void`.

# v0.2.0 (2015-05-28)

Total rewrite on top of the [source_gen](https://pub.dartlang.org/packages/source_gen)
package.

# Semantic Version Conventions

http://semver.org/

- *Stable*:  All even numbered minor versions are considered API stable:
  i.e.: v1.0.x, v1.2.x, and so on.
- *Development*: All odd numbered minor versions are considered API unstable:
  i.e.: v0.9.x, v1.1.x, and so on.
