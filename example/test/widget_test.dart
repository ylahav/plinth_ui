import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_example/main.dart';

// This replaces Flutter's default `flutter create` starter test, which
// references `MyApp` — a placeholder class from the template, never
// part of this app. `flutter create --platforms=...` regenerates that
// starter file whenever `test/` doesn't already exist, which is what
// happened here since this app had no test/ folder before enabling
// web/desktop platforms. This is a real smoke test for the actual
// app instead.
void main() {
  testWidgets('PlinthExampleApp launches and shows the hero title',
      (tester) async {
    await tester.pumpWidget(const PlinthExampleApp());
    await tester.pump();

    expect(find.text('Plinth UI'), findsWidgets);
  });
}
