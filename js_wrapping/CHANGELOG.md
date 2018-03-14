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
