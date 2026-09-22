import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';

void main() {
  test('what a self-export loses', () {
    final r = PlinthDtcg.parse(PlinthDtcg.export(PlinthTheme.defaultTheme));
    final kinds = <String>{};
    for (final p in r.ignored.keys) {
      kinds.add(p.split('.').first);
    }
    // ignore: avoid_print
    print('DBG applied=${r.applied.length} ignored=${r.ignored.length}');
    // ignore: avoid_print
    print('DBG kinds dropped: ${(kinds.toList()..sort()).join(", ")}');
  });
}
