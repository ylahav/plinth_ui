# Publishing Plinth UI to pub.dev

This is a Melos monorepo with three publishable packages, connected by
local `path:` dependencies that only work for development — pub.dev
doesn't understand `path:`. That constrains the order things have to
happen in. This doc is the full checklist, in order.

## What's already done

- MIT `LICENSE` in the repo root and in each of the three packages.
- `CHANGELOG.md` in each of the three packages (a `0.0.1` initial entry).
- `homepage` / `repository` / `issue_tracker` set in each `pubspec.yaml`,
  pointing at https://github.com/ylahav/plinth_ui.
- An API-consistency pass across all 51 components in
  `plinth_components` (see the main README's "API consistency review").

## What's still open, in order

### 1. Publish `plinth_core` first

It has no dependency on the other two packages, so it's unblocked.

```bash
cd packages/plinth_core
dart pub publish --dry-run
```

Fix anything the dry run flags (missing fields, formatting, lint
issues — `pana`, the same tool pub.dev runs, drives this check). Once
it's clean:

1. Remove the `publish_to: none` line from `packages/plinth_core/pubspec.yaml`
   — that line is a deliberate safety guard against an accidental
   publish; only remove it right before you actually intend to publish.
2. `dart pub publish` for real. You'll need a pub.dev account
   (Google sign-in) and to confirm the publish interactively.

### 2. Publish `plinth_hooks` next

Same shape, and also has no dependency on the other two:

```bash
cd packages/plinth_hooks
dart pub publish --dry-run
# remove publish_to: none, then:
dart pub publish
```

### 3. Update `plinth_components` to depend on the published versions

Only after steps 1 and 2 are live on pub.dev. Edit
`packages/plinth_components/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  plinth_core: ^0.0.1      # was: path: ../plinth_core
  plinth_hooks: ^0.0.1     # was: path: ../plinth_hooks
```

Then re-run `melos bootstrap` (or `flutter pub get` inside
`packages/plinth_components`) to confirm it resolves against the real
published packages rather than the local paths, and run the full test
suite again — this is a real dependency-resolution change, not just a
paperwork one, so it's worth the same verification as any other change:

```bash
melos run analyze && melos run test
```

### 4. Publish `plinth_components`

```bash
cd packages/plinth_components
dart pub publish --dry-run
# remove publish_to: none, then:
dart pub publish
```

## Before any of the above: re-confirm the name is free

This project verified `plinth` / `plinth_ui` were unclaimed on pub.dev
early on — that check is now old relative to how much has shipped
since. Right before step 1, check directly on pub.dev's own search
(https://pub.dev/packages?q=plinth) for `plinth_core`, `plinth_hooks`,
and `plinth_components` specifically, since those are the exact names
being published (a web search engine isn't a reliable enough substitute
— pub.dev's live namespace isn't fully indexed by general search).

## Version strategy

All three packages are `0.0.1` right now. Consider whether the first
real release should also be `0.0.1` (signals "very early, expect
changes") or `0.1.0` (signals "usable, but not API-stable yet") —
`0.1.0` is the more common choice for a library with this much
functionality already built. Whichever you pick, `melos version` (now
usable since `repository:` is set in `melos.yaml`) can bump all three
in lockstep and update each `CHANGELOG.md` automatically from commit
history, once you're ready.

## After the first publish: optional automation

Dart supports [automated publishing via GitHub Actions](https://dart.dev/tools/pub/automated-publishing) —
publish triggers off pushing a git tag matching a pattern you configure
on pub.dev, rather than running `dart pub publish` by hand each time.
Worth setting up once the manual process above has been done
successfully at least once, so you understand what it's automating.
