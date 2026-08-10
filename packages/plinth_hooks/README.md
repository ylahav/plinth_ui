# plinth_hooks

Reusable stateful controllers for [Plinth UI](https://github.com/ylahav/plinth_ui)
— the equivalent of Mantine's `@mantine/hooks`.

## Usage

```dart
final _modal = PlinthDisclosureController();

// Later, in a widget:
PlinthButton(onPressed: _modal.open, child: const Text('Open'));

// Always dispose it, same as any ChangeNotifier:
@override
void dispose() {
  _modal.dispose();
  super.dispose();
}
```

## What's in this package

- `PlinthDisclosureController` — a `ChangeNotifier`-based open/closed
  state controller (`open()`, `close()`, `toggle()`, `isOpen`).
  Drives every controller-based overlay in
  [`plinth_components`](https://pub.dev/packages/plinth_components) —
  `PlinthModal`, `PlinthDrawer`, `PlinthPopover`, and `PlinthMenu` all
  take one of these to manage their visibility, so a single controller
  can coordinate a trigger button and the overlay it opens.

See the [full documentation](https://github.com/ylahav/plinth_ui) for
the complete component reference and a live example app.
