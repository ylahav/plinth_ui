# Publishing Plinth UI to pub.dev

All three packages are live on pub.dev. The first-publish sequence
(publish the leaf packages, then switch `plinth_components` off its
local `path:` dependencies onto hosted versions) is **done** — this doc
now covers releasing an update.

## Current state

| Package | pub.dev | In this repo |
|---|---|---|
| `plinth_core` | 0.2.1 | 0.2.1 |
| `plinth_hooks` | 0.0.2 | 0.0.2 |
| `plinth_components` | 0.16.4 | 0.17.0 (unreleased) |

`plinth_components` depends on the other two by hosted version
(`plinth_core: ^0.2.0`, `plinth_hooks: >=0.0.1 <0.1.0`), not by path. Melos
still writes a `pubspec_overrides.yaml` pointing at the local copies so
the workspace builds against your working tree — see the caveat below.

**No package carries `publish_to: none`, and none should.** Beyond
blocking a publish outright rather than prompting, pana clones this
repository to verify each package is published from it — and a
committed `publish_to` makes that check fail, costing 10 pub points
with the message *"we are unable to verify the package is published
from here"*. `plinth_hooks` sat at 150/160 for exactly that reason
while the other two scored 160.

That is easy to reintroduce by accident: removing the line locally to
publish, then committing it back. `dart pub publish` confirms
interactively regardless, so the guard was never buying much.

## ⚠️ Publish in dependency order, or you ship a broken version

**This has already gone wrong once.** `plinth_components` 0.6.0 was
published while it depended on a `plinth_core` ^0.1.0 that hadn't been
pushed yet. The result: `flutter pub add plinth_components` failed with
*"plinth_core ^0.1.0 which doesn't match any versions"* for everyone,
until core went out.

Nothing in the repo catches this. Melos writes a
`pubspec_overrides.yaml` pointing every package at its local sibling,
so `melos run test`, `melos run analyze`, and CI all pass happily while
a constraint points at a version pub.dev has never seen. The workspace
is the one place the mistake is invisible.

**If you raised a constraint on `plinth_core` or `plinth_hooks`,
publish that package first.** Then components. See
"Releasing a change to plinth_core or plinth_hooks" below for the full
order.

To check a constraint is satisfiable before publishing, resolve it
somewhere the overrides don't reach:

```bash
# in a scratch directory, not the workspace
flutter create resolve_check && cd resolve_check
flutter pub add plinth_components   # fails loudly if a dep is unpublished
```

Note that pub caches its version listings on disk, so a package
published moments ago can still look absent. If a resolve fails and you
believe it shouldn't, clear the stale listing and retry:

```bash
# Windows: %LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\.cache\
# macOS/Linux: ~/.pub-cache/hosted/pub.dev/.cache/
rm <PUB_CACHE>/hosted/pub.dev/.cache/plinth_core-versions.json
```

## Releasing `plinth_components`

Bump the version, write the CHANGELOG entry, then:

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
**local** `plinth_core`/`plinth_hooks`, but consumers get whatever is
published. If the local copies have drifted without a version bump,
you'd be shipping something you never actually tested in the
configuration users will get — and it's the same blind spot that let a
constraint on an unpublished version reach pub.dev.

To check rather than assume, diff the published archive against your
working tree:

```bash
curl -s https://pub.dev/api/packages/plinth_core \
  | grep -o '"archive_url":"[^"]*"' | head -1 | sed 's/.*archive_url":"//;s/"//'
# download that URL, extract, and diff its lib/ against packages/plinth_core/lib
```

Last checked during the 0.4.0 prep, when both were clean. Re-run it
whenever a leaf package has changed without a release.

If a future check *does* find a real difference, the fix is to bump and
publish that package first, then raise the constraint in
`plinth_components` — not to publish over the top of it.

## Releasing a change to `plinth_core` or `plinth_hooks`

Order matters, because pub.dev resolves the hosted constraint:

1. Bump the version and add a CHANGELOG entry in that package.
2. `flutter pub publish` it.
3. Raise the constraint in `packages/plinth_components/pubspec.yaml`
   (e.g. `plinth_core: ^0.1.0`).
4. Bump `plinth_components` too — a consumer pinning the old version
   won't otherwise pick up the dependency change.
5. `melos bootstrap && melos run analyze && melos run test`, then
   publish `plinth_components`.

**Step 2 must actually happen before step 5.** Raising the constraint
and publishing components without pushing the leaf package first is the
exact mistake described at the top of this file — and the workspace
will not warn you, because melos resolves the sibling from disk.

`melos version` can bump packages in lockstep and generate CHANGELOG
entries from commit history, which is worth using once more than one
package moves at a time.

## Version strategy

`plinth_hooks` is at 0.0.2 and has been stable since the initial
publish — its only releases have been an example and a removed publish
guard. `plinth_core` moves when the token layer does: 0.1.0 for the
widened palette and dark-theme tokens, 0.2.0 for contrast-aware colour
resolution.
`plinth_components` is the package that actually moves; it's on a 0.x
line where minor bumps carry new components and may include breaking
changes without a major bump, as its CHANGELOG header states.

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
