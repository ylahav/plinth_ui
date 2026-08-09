import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

void main() {
  group('PlinthDisclosureController', () {
    test('starts closed by default', () {
      final controller = PlinthDisclosureController();
      expect(controller.isOpen, isFalse);
    });

    test('starts open when initiallyOpen is true', () {
      final controller = PlinthDisclosureController(initiallyOpen: true);
      expect(controller.isOpen, isTrue);
    });

    test('open() sets isOpen to true and notifies listeners', () {
      final controller = PlinthDisclosureController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.open();

      expect(controller.isOpen, isTrue);
      expect(notifications, equals(1));
    });

    test('open() on an already-open controller does not re-notify', () {
      final controller = PlinthDisclosureController(initiallyOpen: true);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.open();

      expect(notifications, equals(0),
          reason: 'no-op open() should not notify');
    });

    test('close() sets isOpen to false and notifies listeners', () {
      final controller = PlinthDisclosureController(initiallyOpen: true);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.close();

      expect(controller.isOpen, isFalse);
      expect(notifications, equals(1));
    });

    test('toggle() flips isOpen each call', () {
      final controller = PlinthDisclosureController();

      controller.toggle();
      expect(controller.isOpen, isTrue);

      controller.toggle();
      expect(controller.isOpen, isFalse);
    });

    test('removed listeners stop receiving notifications', () {
      final controller = PlinthDisclosureController();
      var notifications = 0;
      void listener() => notifications++;

      controller.addListener(listener);
      controller.open();
      controller.removeListener(listener);
      controller.close();

      expect(notifications, equals(1),
          reason: 'only the open() call should have notified');
    });
  });
}
