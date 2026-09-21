# Account starter

Sign-in, and the signed-in shell behind it: profile, security, team
permissions. Built on [Plinth UI](https://github.com/ylahav/plinth_ui).

```bash
cp -r templates/account my-app && cd my-app
flutter create .          # adds the platform folders, which are not committed here
flutter run
```

**The password is `plinth`.** Anything else fails, on purpose — see
below.

Then open `lib/src/theme.dart` and change one line:

```dart
const brandColor = Color(0xFF7048E8);
```

## What it is showing you

| File | The thing worth copying |
|---|---|
| [lib/src/session.dart](lib/src/session.dart) | One object owns "is anyone signed in". No screen keeps its own flag |
| [lib/src/app.dart](lib/src/app.dart) | One `ListenableBuilder` picks signed-out or signed-in. That is the whole routing decision |
| [lib/src/screens/sign_in.dart](lib/src/screens/sign_in.dart) | A failure that is about the *attempt*, not about the field |
| [lib/src/screens/security.dart](lib/src/screens/security.dart) | Input and strength meter as two widgets, so the meter works under a field you already have |
| [lib/src/screens/permissions.dart](lib/src/screens/permissions.dart) | Four roles — past where colour alone can carry meaning |

## The one that earns its keep

Type the wrong password and the error appears as an **alert about the
attempt**, not as an error on the password field.

That distinction is invisible if you can see the screen and decisive if
you cannot. A field-level error tells a screen reader the password is
malformed — and the password was typed perfectly. The account simply is
not that one. So `PlinthSignInBlock` takes an `error` for the card and
leaves the fields alone:

```dart
PlinthSignInBlock(
  error: session.error,
  onSubmit: (values) => session.signIn(values.email, values.password),
)
```

The second one: **four roles is past where colour works.** Owner, admin,
member, invited. A red/green pair collapses to one for a colour-blind
reader, so each badge carries its role as text and takes its colour from
a declared role in `theme.dart` — `invited` is grey, which is exactly
where a shade picked by eye lands under the floor.

## Tests

```bash
flutter test
```

Nine, and none of them test Plinth. They test that the wrong password
keeps you out and the right one gets you in, that two-factor survives a
tab change (because the session owns it and not the screen), that every
role renders as a word, and that all four clear 4.5:1 on both surfaces.

One asserts the semantics node of the two-factor switch directly —
`isToggled`, and a label with the description merged in, so a reader
hears what the setting *does* and not only what it is called.
