/// The token hierarchy, and DTCG in both directions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';

void main() {
  final theme = PlinthTheme.defaultTheme;

  group('the hierarchy', () {
    test('every token is in a tier and has a type', () {
      expect(theme.tokens, isNotEmpty);
      for (final t in theme.tokens) {
        expect(t.path, isNotEmpty);
        expect(t.value, isNotNull);
      }
    });

    test('paths are unique, because an explorer links to them', () {
      final paths = theme.tokens.map((t) => t.path).toList();
      expect(paths.toSet().length, paths.length);
    });

    test('primitives come before semantics', () {
      final tiers = theme.tokens.map((t) => t.tier).toList();
      final firstSemantic = tiers.indexOf(PlinthTier.semantic);
      expect(firstSemantic, greaterThan(0));
      expect(
        tiers.sublist(0, firstSemantic).every((t) => t == PlinthTier.primitive),
        isTrue,
      );
    });

    test('a ramp is primitive and a role is semantic', () {
      expect(theme.token('color.blue.6')?.tier, PlinthTier.primitive);
      expect(theme.token('surface')?.tier, PlinthTier.semantic);
      expect(theme.token('spacing.md')?.tier, PlinthTier.primitive);
    });

    test('a rebranded theme reports its own values', () {
      final branded = theme.copyWith(colors: {
        ...theme.colors,
        'blue': PlinthTheme.generateShades(const Color(0xFFFF0000)),
      });
      expect(branded.token('color.blue.6')!.value, const Color(0xFFFF0000));
    });
  });

  group('export', () {
    test('nests by path and carries DTCG type and value', () {
      final json = PlinthDtcg.export(theme);
      final blue = (((json['color']! as Map)['blue']! as Map)['6']!) as Map;
      expect(blue[r'$type'], 'color');
      expect(blue[r'$value'], startsWith('#'));
    });

    test('dimensions carry a unit and durations carry ms', () {
      final json = PlinthDtcg.export(theme);
      expect(
          ((json['spacing']! as Map)['md']! as Map)[r'$value'], endsWith('px'));
      expect(((json['duration']! as Map)['md']! as Map)[r'$value'],
          endsWith('ms'));
    });

    test('a font weight is a number, as DTCG requires', () {
      final json = PlinthDtcg.export(theme);
      final bold = (json['fontWeight']! as Map)['bold']! as Map;
      expect(bold[r'$type'], 'fontWeight');
      expect(bold[r'$value'], isA<int>());
    });
  });

  group('import', () {
    test('reads a ramp', () {
      final result = PlinthDtcg.parse({
        'color': {
          'brand': {
            for (var i = 0; i < 10; i++)
              '$i': {r'$type': 'color', r'$value': '#11223344'},
          },
        },
      });

      expect(result.ignored, isEmpty);
      expect(result.applied, hasLength(10));
      expect(result.theme.colors['brand']![6].r, closeTo(0x11 / 255, 0.01));
    });

    test('resolves references, so a file that uses them round-trips', () {
      final result = PlinthDtcg.parse({
        'palette': {
          'red': {r'$type': 'color', r'$value': '#ff0000'},
        },
        'color': {
          'brand': {
            '6': {r'$type': 'color', r'$value': '{palette.red}'},
          },
        },
      });

      expect(result.theme.colors['brand']![6], const Color(0xFFFF0000));
    });

    test('a dangling reference is reported, not dropped', () {
      final result = PlinthDtcg.parse({
        'color': {
          'brand': {
            '6': {r'$type': 'color', r'$value': '{nowhere.at.all}'},
          },
        },
      });

      expect(result.applied, isEmpty);
      expect(result.ignored['color.brand.6'], contains('not in this document'));
    });

    test('a reference cycle fails loudly rather than overflowing', () {
      final result = PlinthDtcg.parse({
        'a': {r'$type': 'color', r'$value': '{b}'},
        'b': {r'$type': 'color', r'$value': '{a}'},
      });
      expect(result.ignored.values.any((v) => v.contains('cycle')), isTrue);
    });

    test('an unknown path is reported rather than silently lost', () {
      // The failure this return type exists to prevent: a theme that
      // looks right and quietly lost half its input.
      final result = PlinthDtcg.parse({
        'typography': {
          'heading': {r'$type': 'fontFamily', r'$value': 'Inter'},
        },
      });

      expect(result.applied, isEmpty);
      expect(result.ignored, contains('typography.heading'));
    });

    test('reads a dimension however it is written', () {
      for (final written in <Object>['16px', '16', 16]) {
        final result = PlinthDtcg.parse({
          'spacing': {
            'md': {r'$type': 'dimension', r'$value': written},
          },
        });
        expect(result.theme.spacing[PlinthSize.md], 16,
            reason: 'failed on "$written"');
      }
    });

    test('what it does not touch keeps the base theme value', () {
      final result = PlinthDtcg.parse({
        'spacing': {
          'md': {r'$type': 'dimension', r'$value': '99px'},
        },
      });
      expect(result.theme.spacing[PlinthSize.md], 99);
      expect(result.theme.radius[PlinthSize.md], theme.radius[PlinthSize.md]);
      expect(result.theme.colors['blue'], theme.colors['blue']);
    });
  });

  group('round trip', () {
    test('export then import returns the colours it started with', () {
      // The only check that proves the two halves agree. Either alone
      // can be self-consistently wrong.
      final exported = PlinthDtcg.export(theme);
      final back = PlinthDtcg.parse(exported, base: PlinthTheme.darkTheme);

      for (final name in theme.colors.keys) {
        for (var shade = 0; shade < 10; shade++) {
          expect(
            back.theme.colors[name]![shade].toARGB32(),
            theme.colors[name]![shade].toARGB32(),
            reason: '$name.$shade did not survive the trip',
          );
        }
      }
    });

    test('and the scales it started with', () {
      final back = PlinthDtcg.parse(PlinthDtcg.export(theme));
      for (final size in PlinthSize.values) {
        expect(back.theme.spacing[size], theme.spacing[size]);
        expect(back.theme.radius[size], theme.radius[size]);
        expect(back.theme.fontSizes[size], theme.fontSizes[size]);
      }
    });
  });
}
