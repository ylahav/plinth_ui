/// Arrow-key navigation over a list of options, while focus stays put.
///
/// **A focus trap would be the wrong shape here.** In a combobox the
/// keyboard belongs in the text field — the user is still typing — so
/// nothing in the open list is focusable at all. What moves is a
/// *highlight*, and Enter commits whatever it is on. That is the ARIA
/// combobox pattern, and it is why this is a key handler rather than a
/// `FocusTraversalGroup`.
///
/// Extracted rather than written a third time. `PlinthTabs` and
/// `PlinthSegmentedControl` each grew their own arrow handling, and
/// when `PlinthAutocomplete` and `PlinthMultiSelect` needed it they got
/// nothing instead: both opened a list a mouse could use and a keyboard
/// could not, which is WCAG 2.1.1 — the same guideline `F-4` broke.
///
/// **Not exported.** Internal, like `PlinthFieldChrome` and
/// `PlinthFocusRing`.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Handles the keys an open option list answers to.
///
/// Returns [KeyEventResult.handled] only for keys it acted on, so
/// everything else — typing, Tab — carries on to the field underneath.
/// Swallowing keys indiscriminately is how a combobox stops being a
/// text field.
KeyEventResult plinthHandleOptionKeys(
  KeyEvent event, {
  required int count,
  required int? active,
  required ValueChanged<int?> onActiveChanged,
  required void Function(int index) onSelect,
  required VoidCallback onDismiss,
  bool loop = true,
}) {
  // Down and up only; a key going up is not a second press.
  if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
    return KeyEventResult.ignored;
  }
  if (count <= 0) return KeyEventResult.ignored;

  final key = event.logicalKey;

  int step(int delta) {
    if (active == null) {
      // First arrow enters the list from the end it came from, so
      // Down lands on the first option and Up on the last.
      return delta > 0 ? 0 : count - 1;
    }
    final next = active + delta;
    if (next >= 0 && next < count) return next;
    return loop ? (next + count) % count : active;
  }

  if (key == LogicalKeyboardKey.arrowDown) {
    onActiveChanged(step(1));
    return KeyEventResult.handled;
  }
  if (key == LogicalKeyboardKey.arrowUp) {
    onActiveChanged(step(-1));
    return KeyEventResult.handled;
  }
  if (key == LogicalKeyboardKey.home) {
    onActiveChanged(0);
    return KeyEventResult.handled;
  }
  if (key == LogicalKeyboardKey.end) {
    onActiveChanged(count - 1);
    return KeyEventResult.handled;
  }

  if (key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter) {
    // Only when something is highlighted. Otherwise Enter belongs to
    // the form, and swallowing it would break submit-on-enter for
    // every field that happens to have a list attached.
    if (active == null) return KeyEventResult.ignored;
    onSelect(active);
    return KeyEventResult.handled;
  }

  if (key == LogicalKeyboardKey.escape) {
    onDismiss();
    return KeyEventResult.handled;
  }

  return KeyEventResult.ignored;
}
