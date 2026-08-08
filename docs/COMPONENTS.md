# Component Reference

Every component reads from the active `PlinthTheme` via `context.plinth`
(`plinth_core`). Register the theme once, at the app root:

```dart
MaterialApp(
  theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
)
```

Shared enums used throughout: `PlinthSize` (`xs, sm, md, lg, xl`) and
`PlinthVariant` (`filled, light, outline, subtle, transparent, defaultVariant`).

---

## Primitives

### `PlinthButton`
`onPressed`, `child`, `variant`, `size`, `color`, `radius`, `fullWidth`, `leadingIcon`.
The reference implementation — every other component's variant/size/color
resolution logic follows this one's pattern.

### `PlinthBox`
`child`, `p`/`px`/`py` (padding), `m`/`mx`/`my` (margin) — all keyed by
`PlinthSize` and resolved through `theme.spacing`. Also `w`, `h`, `bg`,
`radius`, `border`, `alignment`.

### `PlinthText`
`data`, `size`, `color`, `weight`, `textAlign`, `italic`, `maxLines`, `overflow`.
`size` resolves through `theme.fontSizes` instead of a raw `fontSize` double.

---

## Forms

### `PlinthTextInput`
`label`, `description`, `placeholder`, `error`, `controller`, `onChanged`,
`size`, `color`, `radius`, `obscureText`, `enabled`, `leadingIcon`.
Border color: gray (default) -> theme color at shade 6 (focused) -> red
(error present) — error takes precedence over focus.

### `PlinthCheckbox`
`value`, `onChanged` (nullable — null disables), `label`, `size`, `color`, `radius`.

### `PlinthRadio<T>` / `PlinthRadioGroup<T>`
Use `PlinthRadioGroup` in practice — it wires `groupValue`/`onChanged` to
each `PlinthRadioOption<T>` for you:
```dart
PlinthRadioGroup<String>(
  label: 'Plan',
  value: _plan,
  onChanged: (v) => setState(() => _plan = v),
  options: const [
    PlinthRadioOption('free', 'Free'),
    PlinthRadioOption('pro', 'Pro'),
  ],
)
```

### `PlinthSelect<T>`
`options` (`List<PlinthSelectOption<T>>`), `value`, `onChanged`, `label`,
`description`, `placeholder`, `error`, `size`, `color`, `radius`, `enabled`.
Shares `PlinthTextInput`'s label/description/error chrome; wraps
`DropdownButton` internally with the default underline hidden.

### `PlinthSwitch`
`value`, `onChanged` (nullable), `label`, `size`, `color`. Same
animated-fill pattern as `PlinthCheckbox`, pill-shaped instead of square.

### `PlinthSlider`
`value`, `onChanged` (nullable), `min`, `max`, `divisions` (omit for
continuous), `color`, `size`, `label` (shown above the thumb while
dragging). A themed wrapper around Flutter's built-in `Slider` (via
`SliderTheme`) — same rationale as `PlinthTooltip`: drag handling,
keyboard stepping, and accessibility are worth not reimplementing.

---

## Feedback

### `PlinthBadge`
`label` (positional), `variant`, `size`, `color`, `leadingIcon`. Renders
uppercase by default, pill-shaped (`borderRadius: 999`).

### `PlinthAlert`
`title` (optional), `child`, `color` (default `'blue'`), `icon`, `onClose`
(non-null shows a close button), `radius`. Background at shade 0, accent
(icon/title/border) at shade 6.

### `PlinthProgress`
`value` (0.0–1.0, asserted in range), `color`, `size` (controls track
height), `radius`, `trackColor`. Fill animates smoothly on value change
via an internal `AnimatedFractionallySizedBox` helper.

---

## Data Display

### `PlinthAvatar`
`imageUrl`, `initials`, `color`, `size`, `radius` (omit for fully circular).
Fallback chain: `imageUrl` -> `initials` on a tinted background -> generic
person icon.

### `PlinthTable`
`columns` (`List<String>`), `rows` (`List<List<String>>` — each inner
list must match `columns.length`), `striped`, `size`. Built on Flutter's
low-level `Table` widget rather than `DataTable`, since `DataTable`'s
built-in Material styling (fixed row heights, sort/selection chrome)
fights against a themeable design system more than it helps. No custom
per-cell widget support yet — cells are plain text.

---

## Navigation

### `PlinthAccordion` + `PlinthAccordionItem`
`items` (`List<PlinthAccordionItem>`), `multiple` (default `false` — only
one item open at a time), `initiallyOpen` (`Set<String>` of item
`value`s), `color`. Each `PlinthAccordionItem` has `value` (unique id),
`title`, `content`, `icon`. Manages its own open/closed state
internally — unlike the overlay components, there's no external
controller, since expanded state is presentation-local to the widget.

### `PlinthTabs<T>` + `PlinthTabView<T>`
`PlinthTabs`: `tabs` (`List<PlinthTabItem<T>>`), `value`, `onChanged`, `size`,
`color`. Renders an underline-style tab bar — deliberately a static
per-tab underline rather than a measured sliding indicator (the kind
needing `GlobalKey`/`RenderBox` size lookups), to keep the implementation
simple and reliable.

`PlinthTabView`: `value`, `children` (`Map<T, Widget>`). Fades between
entries keyed by the same `value`/type as `PlinthTabs`. Renders nothing
(not an error) if `value` has no matching key — treated as a recoverable
transient state rather than a bug.

```dart
PlinthTabs<String>(
  value: _tab,
  onChanged: (v) => setState(() => _tab = v),
  tabs: const [
    PlinthTabItem('account', 'Account'),
    PlinthTabItem('security', 'Security'),
  ],
),
PlinthTabView<String>(
  value: _tab,
  children: const {
    'account': Text('Account settings'),
    'security': Text('Security settings'),
  },
),
```

---

## Overlays

All four overlay components share `PlinthDisclosureController`
(`plinth_hooks`) for open/close state — `open()`, `close()`, `toggle()`,
`isOpen`. Always call `.dispose()` on the controller when its owning
State is disposed.

### `PlinthModal` + `PlinthModalHost`
`controller`, `title`, `child`, `size`, `closeOnBackdropTap`, `radius`.
`PlinthModal` doesn't render inline — wrap the part of your tree that
should react to it in `PlinthModalHost(modal: ..., child: ...)`, which
calls `modal.show(context)` automatically whenever the controller opens
(via `showGeneralDialog` under the hood). Auto-closes the controller on
dismissal (backdrop tap or `Navigator.pop`).

### `PlinthDrawer` + `PlinthDrawerHost`
Same shape as Modal, plus `position` (`PlinthDrawerPosition`: `left,
right, top, bottom`). Slides in via `SlideTransition`; sizing is width
for left/right, height for top/bottom.

### `PlinthPopover`
`controller`, `target`, `content`, `position` (`PlinthPopoverPosition`:
`top, bottom, left, right`), `width`, `closeOnOutsideTap`. Unlike
Modal/Drawer, **not** route-based — built on
`CompositedTransformTarget`/`CompositedTransformFollower` + a manual
`OverlayEntry`, so it tracks its target's actual on-screen position
(including through scrolling). Tapping `target` toggles the controller
directly; no separate host widget needed since the popover wraps its
own trigger.

### `PlinthTooltip`
`message`, `child`, `size`, `radius`. A themed wrapper around Flutter's
built-in `Tooltip` — shown on hover (desktop/web) or long-press (touch).

### `PlinthMenu` + `PlinthMenuItem`
`controller`, `target`, `items` (`List<PlinthMenuItem>`), `position`, `width`.
Built directly on `PlinthPopover` rather than reimplementing anchored
positioning — a menu is structurally a popover whose content is a themed
item list. Each `PlinthMenuItem` has `label`, `icon`, `onTap`, `color`
(e.g. `'red'` for a destructive action), and a `divider` flag —
`PlinthMenuItem.divider()` is a shorthand constructor for a separator.
Tapping an item closes the controller *then* calls its `onTap`.

---

## Internal / not exported

- **`PlinthOverlayHost`** (`plinth_components/src/widgets/overlay_host.dart`)
  — shared listener/dispose plumbing behind `PlinthModalHost` and
  `PlinthDrawerHost`. Not part of the public API; any future route-based
  overlay host should wrap this the same way.
