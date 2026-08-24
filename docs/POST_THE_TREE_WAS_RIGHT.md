# The semantics tree was right. The link was unusable.

*A Flutter accessibility bug that no test in the repository could have
found, why the whole category is invisible, and the ten-line test that
catches it.*

---

We had a link. A screen reader announced it correctly. Its semantics
tree was exactly what you would draw on a whiteboard. Every
accessibility test passed.

A keyboard user could never reach it.

## The bug

```dart
Semantics(
  link: true,
  child: GestureDetector(
    onTap: widget.onTap,
    child: Text(label, style: linkStyle),
  ),
)
```

Read that and try to find the defect. It is not there — it is in what
is *missing*, which is the hard kind to see.

`GestureDetector` supplies a tap **action**. It does not supply a
**focus node**. So this widget could be clicked by a mouse, and
activated by a screen reader in browse mode, and `Tab` walked straight
past it as though it were a paragraph. WCAG 2.1.1, failed outright: not
degraded, not awkward — unreachable.

The same shape sat in our unstyled button too, which is worse for being
named a button.

## Why nothing caught it

Three reasons, and each one generalises past this bug.

**1. Every accessibility test we had walks the semantics tree — and the
tree was correct.**

This is the part worth sitting with. `link: true` was there. The label
was there. A test that pumps the widget and asserts
`matchesSemantics(isLink: true, label: 'Send a new code')` passes,
because every one of those things is true. The missing piece was a
focus node, which is not in the semantics tree at all. It lives in the
focus system, a completely separate mechanism that no semantics
assertion can see.

An accessibility test that inspects the semantics tree can only find
things that are *in* the semantics tree. That sounds tautological. It
is also the whole bug.

**2. The screen reader made it look fine.**

NVDA's elements list showed the link. Activating it from browse mode
worked. The semantics were right, so the screen reader was right — and
the tool most people reach for to check accessibility reported no
problem, confidently, because from where it was standing there wasn't
one.

**3. Our existing checks were pointed the other way.**

We had a real screen-reader pass that verified every Tab-reachable
control was properly named. Excellent test. It asks: *of the things Tab
reaches, are they labelled?* It cannot ask: *does Tab reach everything
it should?* Nobody was looking in that direction, and a checklist only
finds what it is pointed at.

## The Flutter mechanic underneath

Four common ways to make something tappable, and what each actually
gives you:

| | Focus node | Keyboard activation | Semantic role |
|---|---|---|---|
| `GestureDetector` | ✗ | ✗ | ✗ |
| `Semantics(link:/button:)` | ✗ | ✗ | ✓ |
| `InkWell` | ✓ | ✓ | ✗ |
| `FocusableActionDetector` | ✓ | ✓ | ✗ |

Nothing in that table gives you all three. `GestureDetector` +
`Semantics` — the combination that reads most naturally, and the one we
wrote — is the single cell that gives you a role and no focus. It looks
like the careful, accessible choice. Adding `Semantics` is the thing
you do when you are *trying*.

And the failure is silent in both directions: `InkWell` alone is
reachable and roleless, so it announces as text; `Semantics` +
`GestureDetector` is roleful and unreachable. Neither one throws, and
neither shows up in a widget test unless you are specifically looking
for the axis it is missing.

## The fix

`FocusableActionDetector` supplies the focus node and the intent
plumbing; `Semantics` still supplies the role.

```dart
FocusableActionDetector(
  enabled: widget.onTap != null,
  mouseCursor: SystemMouseCursors.click,
  onShowFocusHighlight: (value) => setState(() => _focused = value),
  actions: <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate()),
    ButtonActivateIntent:
        CallbackAction<ButtonActivateIntent>(onInvoke: (_) => _activate()),
  },
  child: Semantics(
    link: true,
    child: GestureDetector(onTap: widget.onTap, child: /* ... */),
  ),
)
```

**Both intents, and this one is a genuine trap.** On the web, Flutter
routes `Enter` to `ButtonActivateIntent` and `Space` to
`ActivateIntent`. On every other platform, both arrive as
`ActivateIntent`. Handle only `ActivateIntent` — the obvious choice,
and the one most examples show — and `Enter` is silently dead on the
web, which is very likely where your demo is. The shortcut map is
chosen by `kIsWeb`, so a test on the VM cannot switch it on: you have
to invoke the intent directly to cover it.

Two smaller things that came out of the same fix, since they are the
kind of detail nobody budgets for:

- **Draw the focus ring as a foreground decoration**, not a border. A
  real border shifts every link by its own width the instant it takes
  focus.
- **`onShowFocusHighlight` fires only in traversal mode**, so a mouse
  tap does not leave a ring behind. That is what it is for, and it
  saves you tracking focus origin yourself.

## The test that catches the whole category

Ten lines of principle: put the widget between two text fields, focus
the first, press `Tab` once, and ask what focus landed on.

```dart
Future<String> _tabFrom(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: Column(children: [
    const TextField(decoration: InputDecoration(labelText: 'before')),
    child,
    const TextField(decoration: InputDecoration(labelText: 'after')),
  ]))));

  await tester.tap(find.byType(TextField).first);
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();

  final context = FocusManager.instance.primaryFocus?.context;
  var landed = 'nothing';
  context?.visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is TextField) {
      landed = 'the ${widget.decoration?.labelText} field';
      return false;
    }
    return true;
  });
  return landed;
}
```

Then assert, for every interactive widget you ship:

```dart
expect(landed, isNot('the after field'),
    reason: 'Tab skipped it entirely, so a keyboard user can never '
        'operate it. Anything with an onTap needs a focus node, not '
        'only a tap action');
```

Two things make this worth more than it looks.

**Sweep everything, including the widgets that are already right.** A
sweep is only worth having if it would notice a regression in the ones
nobody is currently worried about. Ours covers six widgets; two were
the bug and four were already correct, and it is those four that make
it a regression test rather than a one-off.

**Assert the disabled case too.** A control with no callback should be
*skipped*:

```dart
expect(landed, 'the after field',
    reason: 'focusable and dead is worse than unfocusable: it stops a '
        'keyboard user on something that does nothing');
```

`FocusableActionDetector(enabled: onTap != null, ...)` gets this right
for free, which is a good reason to prefer it over hand-rolling a
`Focus` widget.

## Finding it in code you already have

The shape is greppable. Look for a `GestureDetector` with an `onTap`
that has no focus mechanism anywhere above it:

```bash
rg -l 'GestureDetector' lib/ | xargs rg -L 'Focus|InkWell|FocusableActionDetector'
```

That is a starting point, not a proof — it misses a focus node three
widgets up and flags plenty of legitimate drag handles. In our case it
returned exactly two files, and both were bugs. Worth the five minutes.

## The part I keep thinking about

We found this by ear. Somebody put on a screen reader, tabbed through a
form, and said *"Tab from the last digit doesn't reach Send a new code,
it goes to the next link."*

They were not testing the anchor. They were testing something else
entirely and walked past it.

Nothing else in the project would have found it, because the tree was
right — and everything we had was pointed at the tree. Four listening
passes have now run against this library. **Every one of them found
something the tests could not**, and the fourth found nothing only
after the first three had taught us what to look for.

The lesson is not "write more assertions." It is that *correct* and
*usable* are different properties, and most accessibility tooling —
ours, and the screen reader's element list, and probably yours —
measures the first one.

---

*The library is [Plinth UI](https://github.com/ylahav/plinth_ui). The
full sweep is
[`plinth_keyboard_reachable_test.dart`](https://github.com/ylahav/plinth_ui/blob/main/packages/plinth_components/test/plinth_keyboard_reachable_test.dart);
what four screen-reader passes actually heard, false alarms included,
is in
[B0C_FINDINGS.md](https://github.com/ylahav/plinth_ui/blob/main/docs/B0C_FINDINGS.md).*
