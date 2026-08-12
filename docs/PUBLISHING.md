# Publishing Plinth UI to pub.dev

All three packages are live on pub.dev. The first-publish sequence
(publish the leaf packages, then switch `plinth_components` off its
local `path:` dependencies onto hosted versions) is **done** — this doc
now covers releasing an update.

## Current state

| Package | pub.dev | In this repo |
|---|---|---|
| `plinth_core` | 0.0.1 | 0.0.1 — `publish_to: none` guard in place |
| `plinth_hooks` | 0.0.1 | 0.0.1 — `publish_to: none` guard in place |
| `plinth_components` | 0.3.0 | **0.4.0 — unreleased** |

`plinth_components` depends on the other two by hosted version
(`plinth_core: ^0.0.1`, `plinth_hooks: ^0.0.1`), not by path. Melos
still writes a `pubspec_overrides.yaml` pointing at the local copies so
the workspace builds against your working tree — see the caveat below.

`plinth_core` and `plinth_hooks` carry `publish_to: none` as a guard
against an accidental publish. Neither needs a release right now;
remove the line only when you actually intend to push a new version,
and restore it afterward.

## Releasing `plinth_components` 0.4.0

The version is already bumped and the CHANGELOG entry is written
(`PlinthFlex`, `PlinthImage`, `PlinthScrollArea`, `PlinthPortal`).

```bash
melos bootstrap
melos run analyze && melos run format && melos run test
cd packages/plinth_components
flutter pub publish --dry-run
flutter pub publish          # interactive confirmation, needs a pub.dev account
```

Publishing is **irreversible** — a version can't be retracted after
seven days, and the version number can never be reused. Treat the dry
run as the last checkpoint.

Expect the golden test to fail locally on Windows/macOS while passing
in CI; that's the documented platform sensitivity in
[TESTING.md §7](TESTING.md), not a release blocker. GitHub Actions is
the source of truth.

### The `pubspec_overrides.yaml` hint

The dry run reports two hints, both of this form:

> Non-dev dependencies are overridden in pubspec_overrides.yaml. This
> indicates you are not testing your package against the same versions
> of its dependencies that users will have when they use it.

This is real and worth taking seriously: your tests run against the
**local** `plinth_core`/`plinth_hooks`, but consumers get the published
0.0.1. If the local copies have drifted without a version bump, you'd
be shipping something you never actually tested in the configuration
users will get.

To check rather than assume, diff the published archive against your
working tree:

```bash
curl -s https://pub.dev/api/packages/plinth_core \
  | grep -o '"archive_url":"[^"]*"' | head -1 | sed 's/.*archive_url":"//;s/"//'
# download that URL, extract, and diff its lib/ against packages/plinth_core/lib
```

As of the 0.4.0 prep this came back clean — `plinth_hooks` is
byte-identical to its published 0.0.1, and `plinth_core` differs only
in `dart format` line reflow (identical once whitespace is stripped),
so the override is not masking a behavioral difference.

If a future check *does* find a real difference, the fix is to bump and
publish that package first, then raise the constraint in
`plinth_components` — not to publish over the top of it.

## Releasing a change to `plinth_core` or `plinth_hooks`

Order matters, because pub.dev resolves the hosted constraint:

1. Bump the version and add a CHANGELOG entry in that package.
2. Remove its `publish_to: none`, `flutter pub publish`, then restore
   the guard line.
3. Raise the constraint in `packages/plinth_components/pubspec.yaml`
   (e.g. `plinth_core: ^0.1.0`).
4. Bump `plinth_components` too — a consumer pinning the old version
   won't otherwise pick up the dependency change.
5. `melos bootstrap && melos run analyze && melos run test`, then
   publish `plinth_components`.

`melos version` can bump packages in lockstep and generate CHANGELOG
entries from commit history, which is worth using once more than one
package moves at a time.

## Version strategy

`plinth_core` and `plinth_hooks` are still at 0.0.1 and have been
stable since the initial publish. `plinth_components` is the package
that actually moves; it's on a 0.x line where minor bumps carry new
components and may include breaking changes without a major bump, as
its CHANGELOG header states.

Worth deciding before 1.0: whether the two leaf packages should be
brought up to a matching version line, or left to drift at their own
pace. Lockstep versioning is simpler to reason about for consumers;
independent versioning is more honest about what actually changed.

## Optional automation

Dart supports [automated publishing via GitHub Actions](https://dart.dev/tools/pub/automated-publishing) —
publishing triggers off a git tag matching a pattern you configure on
pub.dev, instead of running `flutter pub publish` by hand. The manual
process has now been done successfully more than once, so the
prerequisite ("understand what you're automating") is satisfied.
