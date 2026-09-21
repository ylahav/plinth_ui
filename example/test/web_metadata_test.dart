/// The landing page's metadata, held to what the app actually contains.
///
/// Flutter web renders to canvas, so a crawler and a link preview see
/// nothing but these tags — they are the entire public description of
/// this project on every surface that is not GitHub. That makes a
/// number in them exactly as load-bearing as one in the README, and
/// exactly as prone to drift: `index.html` is not a file anybody opens
/// while adding a block.
///
/// Until this test existed the description read "A new Flutter
/// project." for the whole life of the repository.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_example/src/showcase/showcase_data.dart';

String _read(String path) {
  final file = File(path);
  if (file.existsSync()) return file.readAsStringSync();
  // `flutter test` runs from the package root; be forgiving if a
  // runner starts elsewhere rather than failing with a path error
  // that says nothing about the actual assertion.
  final alt = File('example/$path');
  expect(alt.existsSync(), isTrue, reason: 'cannot find $path');
  return alt.readAsStringSync();
}

void main() {
  final html = _read('web/index.html');

  final blockCount = showcaseCategories
      .expand((c) => c.subcategories)
      .expand((s) => s.examples)
      .length;

  test('the placeholder description is gone', () {
    expect(
      html,
      isNot(contains('A new Flutter project')),
      reason: 'index.html still ships the flutter create placeholder',
    );
    expect(
        _read('web/manifest.json'), isNot(contains('A new Flutter project')));
  });

  test('the block count in the description is the real one', () {
    // The one number in the description that is derivable from source,
    // so the one that can be held. If this fails, the showcase grew or
    // shrank and index.html was not updated with it.
    expect(
      html,
      contains('$blockCount composed blocks'),
      reason: 'index.html quotes a block count that is not $blockCount',
    );
  });

  test('every tag a link preview needs is present', () {
    for (final tag in const [
      'og:title',
      'og:description',
      'og:image',
      'og:url',
      'twitter:card',
      'twitter:title',
      'twitter:description',
    ]) {
      expect(html, contains(tag), reason: 'missing $tag');
    }
  });

  test('preview URLs are absolute', () {
    // A crawler does not resolve a relative URL against `<base href>`,
    // and this app is served from a project sub-path, so a relative
    // og:image would resolve against the wrong root even if it did.
    final urls = RegExp(r'(?:og:image|og:url)" content="([^"]+)"')
        .allMatches(html)
        .map((m) => m.group(1)!);

    expect(urls, isNotEmpty);
    for (final url in urls) {
      expect(url, startsWith('https://'), reason: '$url is not absolute');
    }
  });

  test('the title is not the package name', () {
    expect(html, isNot(contains('<title>plinth_example</title>')));
  });
}
