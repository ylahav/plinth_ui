import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

Color _hsv(double h, double s, double v) =>
    HSVColor.fromAHSV(1, h, s, v).toColor();

void main() {
  group('PlinthColorInput hex parsing', () {
    test('accepts the forms a person actually types', () {
      const cyan = Color(0xFFAABBCC);

      expect(PlinthColorInput.parseHex('#aabbcc'), cyan);
      expect(PlinthColorInput.parseHex('aabbcc'), cyan);
      expect(PlinthColorInput.parseHex('  #AABBCC  '), cyan);
      // #abc is shorthand for #aabbcc.
      expect(PlinthColorInput.parseHex('#abc'), cyan);
      expect(PlinthColorInput.parseHex('abc'), cyan);
    });

    test('reads eight digits as CSS RRGGBBAA, not Flutter AARRGGBB', () {
      // Half-transparent mid-grey: alpha is the *last* pair typed.
      expect(PlinthColorInput.parseHex('#80808080'), const Color(0x80808080));
      expect(PlinthColorInput.parseHex('#aabbcc00'), const Color(0x00AABBCC));
    });

    test('returns null for anything that is not a colour yet', () {
      // Every prefix of a hex value passes through here while typing,
      // so "not yet" has to be distinct from "wrong".
      expect(PlinthColorInput.parseHex('#2f9'), isNotNull);
      expect(PlinthColorInput.parseHex('#2f9e'), isNull);
      expect(PlinthColorInput.parseHex('#'), isNull);
      expect(PlinthColorInput.parseHex(''), isNull);
      expect(PlinthColorInput.parseHex('nothex'), isNull);
      expect(PlinthColorInput.parseHex('#zzzzzz'), isNull);
    });

    test('formats as CSS hex, round-tripping through parseHex', () {
      expect(PlinthColorInput.formatHex(const Color(0xFFAABBCC)), '#aabbcc');
      expect(
        PlinthColorInput.formatHex(const Color(0x80AABBCC), withAlpha: true),
        '#aabbcc80',
      );

      const original = Color(0xFF2F9E44);
      expect(
        PlinthColorInput.parseHex(PlinthColorInput.formatHex(original)),
        original,
      );
    });
  });

  group('PlinthHueSlider', () {
    testWidgets('announces itself as a slider in degrees', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            child: PlinthHueSlider(value: 210, onChanged: (_) {}),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PlinthHueSlider));
      expect(semantics.label, 'Hue');
      expect(semantics.value, '210 degrees');
    });

    testWidgets('tapping the track reports the hue at that position', (
      tester,
    ) async {
      double? reported;
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            child: PlinthHueSlider(value: 0, onChanged: (h) => reported = h),
          ),
        ),
      );

      final rect = tester.getRect(find.byType(PlinthHueSlider));
      await tester.tapAt(Offset(rect.left + rect.width / 2, rect.center.dy));

      // Halfway along a 0-360 track.
      expect(reported, closeTo(180, 5));
    });

    testWidgets('a null onChanged makes it inert', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 200,
            child: PlinthHueSlider(value: 90, onChanged: null),
          ),
        ),
      );

      final rect = tester.getRect(find.byType(PlinthHueSlider));
      await tester.tapAt(rect.center);
      await tester.pump();

      // Inert, but still readable: a disabled control that stops
      // announcing its value is worse than one that can't be moved.
      expect(tester.takeException(), isNull);
      expect(
        tester.getSemantics(find.byType(PlinthHueSlider)).value,
        '90 degrees',
      );
    });
  });

  group('PlinthAlphaSlider', () {
    testWidgets('announces opacity as a percentage', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            child: PlinthAlphaSlider(
              color: Colors.blue,
              value: 0.5,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PlinthAlphaSlider));
      expect(semantics.label, 'Opacity');
      expect(semantics.value, '50%');
    });

    testWidgets('dragging reports a new opacity', (tester) async {
      double? reported;
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            child: PlinthAlphaSlider(
              color: Colors.blue,
              value: 0,
              onChanged: (a) => reported = a,
            ),
          ),
        ),
      );

      final rect = tester.getRect(find.byType(PlinthAlphaSlider));
      await tester.tapAt(Offset(rect.left + rect.width * 0.75, rect.center.dy));

      expect(reported, closeTo(0.75, 0.05));
    });
  });

  group('PlinthAngleSlider', () {
    testWidgets('zero points up and the value grows clockwise', (tester) async {
      double? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthAngleSlider(value: 0, onChanged: (a) => reported = a),
        ),
      );

      final rect = tester.getRect(find.byType(PlinthAngleSlider));

      // Directly right of centre is a quarter turn clockwise.
      await tester.tapAt(Offset(rect.right - 2, rect.center.dy));
      expect(reported, closeTo(90, 5));

      // Directly below centre is half a turn.
      await tester.tapAt(Offset(rect.center.dx, rect.bottom - 2));
      expect(reported, closeTo(180, 5));

      // Directly above centre is back to zero.
      await tester.tapAt(Offset(rect.center.dx, rect.top + 2));
      expect(reported, closeTo(0, 5));
    });

    testWidgets('divisions snap to equal steps', (tester) async {
      double? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthAngleSlider(
            value: 0,
            divisions: 4,
            onChanged: (a) => reported = a,
          ),
        ),
      );

      final rect = tester.getRect(find.byType(PlinthAngleSlider));
      // Just past due-right still lands on the quarter mark.
      await tester.tapAt(Offset(rect.right - 2, rect.center.dy + 4));

      expect(reported, 90);
    });

    testWidgets('announces itself as a slider in degrees', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthAngleSlider(value: 135, onChanged: (_) {})),
      );

      final semantics = tester.getSemantics(find.byType(PlinthAngleSlider));
      expect(semantics.value, '135 degrees');
    });
  });

  group('PlinthColorPicker', () {
    testWidgets('shows a hue slider, and an alpha slider only when asked', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 240,
            child: PlinthColorPicker(value: Colors.teal, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byType(PlinthHueSlider), findsOneWidget);
      expect(find.byType(PlinthAlphaSlider), findsNothing);

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 240,
            child: PlinthColorPicker(
              value: Colors.teal,
              withAlpha: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(PlinthAlphaSlider), findsOneWidget);
    });

    testWidgets('remembers the hue after the colour turns black', (
      tester,
    ) async {
      Color? reported;

      Widget picker(Color value) => _wrap(
            SizedBox(
              width: 240,
              child: PlinthColorPicker(
                value: value,
                onChanged: (c) => reported = c,
              ),
            ),
          );

      await tester.pumpWidget(picker(_hsv(200, 1, 1)));
      // The caller drags brightness to zero; the colour is now black,
      // and HSVColor reports its hue as 0.
      await tester.pumpWidget(picker(Colors.black));

      final area = tester.getRect(find.byType(PlinthColorPicker));
      // Top-right of the saturation/brightness square: full saturation,
      // full brightness.
      await tester.tapAt(Offset(area.right - 2, area.top + 2));

      expect(reported, isNotNull);
      // Without the remembered hue this comes back red — the classic
      // "drag to black and lose your colour" picker bug.
      expect(HSVColor.fromColor(reported!).hue, closeTo(200, 2));
    });

    testWidgets('drops alpha unless withAlpha is set', (tester) async {
      Color? reported;
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 240,
            child: PlinthColorPicker(
              value: const Color(0x802196F3),
              onChanged: (c) => reported = c,
            ),
          ),
        ),
      );

      final area = tester.getRect(find.byType(PlinthColorPicker));
      await tester.tapAt(Offset(area.right - 2, area.top + 2));

      expect(reported, isNotNull);
      expect((reported!.toARGB32() >> 24) & 0xFF, 0xFF);
    });

    testWidgets('a null onChanged disables every part', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 240,
            child: PlinthColorPicker(value: Colors.teal, onChanged: null),
          ),
        ),
      );

      final area = tester.getRect(find.byType(PlinthColorPicker));
      await tester.tapAt(Offset(area.right - 2, area.top + 2));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthColorInput', () {
    testWidgets('shows the label and the colour as hex', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthColorInput(
            label: 'Brand colour',
            value: const Color(0xFF2F9E44),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Brand colour'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '#2f9e44',
      );
    });

    testWidgets('typing a complete hex reports the colour', (tester) async {
      Color? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthColorInput(
            value: Colors.black,
            onChanged: (c) => reported = c,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '#2f9e44');
      await tester.pump();

      expect(reported, const Color(0xFF2F9E44));
    });

    testWidgets('a half-typed hex reports nothing and is left alone', (
      tester,
    ) async {
      Color? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthColorInput(
            value: Colors.black,
            onChanged: (c) => reported = c,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '#2f9e');
      await tester.pump();

      // Nothing valid yet — and the field must not be rewritten from
      // under the caret while somebody is mid-value.
      expect(reported, isNull);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '#2f9e',
      );
    });

    testWidgets('the swatch opens the picker', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthColorInput(value: Colors.teal, onChanged: (_) {}),
        ),
      );

      expect(find.byType(PlinthColorPicker), findsNothing);

      await tester.tap(find.bySemanticsLabel('Choose colour'));
      await tester.pumpAndSettle();

      expect(find.byType(PlinthColorPicker), findsOneWidget);
    });

    testWidgets('an external colour change updates the field', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthColorInput(value: Colors.black, onChanged: (_) {})),
      );
      await tester.pumpWidget(
        _wrap(
          PlinthColorInput(
            value: const Color(0xFF2F9E44),
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '#2f9e44',
      );
    });
  });
}
