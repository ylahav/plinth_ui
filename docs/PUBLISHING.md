# Publishing Plinth UI to pub.dev

All three packages are live on pub.dev. The first-publish sequence
(publish the leaf packages, then switch `plinth_components` off its
local `path:` dependencies onto hosted versions) is **done** — this doc
now covers releasing an update.

## Current state

| Package | pub.dev | In this repo |
|---|---|---|
| `plinth_core` | **1.0.0** | 1.0.0 |
| `plinth_hooks` | **1.0.0** | 1.0.0 |
| `plinth_components` | **1.0.0** | 1.0.0 |

**1.0.0 shipped 20 Aug 2026.** `flutter pub add plinth_components` now
resolves to it without an explicit constraint, which the two betas never
did — pub.dev does not promote a prerelease to "latest".

### What the `1.0.0` release proved

The sequence held, and the two things it caught last time it caught
again: propagation took three attempts before `plinth_components`
resolved, and the archive diff came back identical so the
`pubspec_overrides` hints were benign.

One practical note for next time. The archive-diff step is easier than
the documented recipe suggests: after the resolve check, the real
published packages are already sitting in the pub cache at
`hosted/pub.dev/<name>-<version>/`, so diff against that instead of
downloading a tarball.

### What the `1.0.0-beta.2` release proved

Ran the sequence below in full, including step 3, and it earned its
place twice:

- **Propagation is not instant, and the failure looks like a bug.**
  `/api/packages/<name>` listed `1.0.0-beta.2` *immediately* while
  `pub get` still reported **"which doesn't match any versions"** for
  several minutes. Clearing the local listing cache did not help,
  because the staleness was not local. Two lessons: the API is not
  evidence that the version is resolvable, and **a failed resolve right
  after publishing means wait, not re-publish.** It took ~2 minutes for
  the leaf packages and ~3 for `plinth_components`.
- **The archive diff was worth running.** The `pubspec_overrides.yaml`
  hints appeared as documented; diffing both published archives' `lib/`
  against the working tree came back identical, so the hint was benign
  *this time* — which is only knowable by checking.

Final check, from a scratch project outside the workspace: a bare
`plinth_components: ^1.0.0-beta.2` resolved all three at
`1.0.0-beta.2`. That is the exact condition whose absence shipped the
broken `plinth_components` 0.6.0.

`plinth_components` depends on the other two by hosted version
(`plinth_core: ^1.0.0-beta.1`, `plinth_hooks: ^1.0.0-beta.1`), not by
path. Melos
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

## Keep the description between 60 and 180 characters

pub.dev scores `Provide a valid pubspec.yaml` at 0/10 if the
`description` is outside that range, which costs **10 pub points** —
the difference between 160 and 150.

`1.0.0` shipped with 202 and 203 characters on `plinth_core` and
`plinth_components`, because both were rewritten for accuracy just
before the release and nobody counted. `plinth_hooks` kept 160 for the
sole reason that its description was never edited. Fixed in `1.0.1`.

The dry run does **not** warn about this — the score is computed by pana
after publishing, so the first sign is the listing, where `Provide a
valid pubspec.yaml` at 0/10 means this and almost nothing else.

To check beforehand, count the *joined* text: a folded `>-` description
is several lines in the file and one string to pana, with the lines
joined by single spaces. Counting the file's characters will not match.

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

### Decided: lockstep from 1.0 onward

The three packages go to **1.0.0 together**, and move together after
that. This was the last open question before 1.0, and it is now closed.

**Why lockstep won.** The honesty argument for independent versions is
real — `plinth_hooks` has changed twice in its life, and a 1.0.0 on it
claims more movement than happened. But it is answering a question
nobody asks. Nobody depends on `plinth_hooks` alone; it exists because
`plinth_components` needed a disclosure controller. What consumers
actually ask is *"which versions of these three go together?"*, and
lockstep answers it by construction, where independent versioning
answers it with a compatibility table someone has to maintain and
everyone has to read.

The cost is honest and small: some 1.x releases of the leaf packages
will contain nothing but a version bump. That is a fair price for
never having to explain that `plinth_core` 0.2.1 is the right one for
`plinth_components` 0.25.0.

**What it does not mean.** Lockstep is a release convention, not a
promise that every package changes every time. A leaf package with no
changes gets a CHANGELOG entry saying exactly that.

### Reopened after 1.0, and closed again

**The reasoning above rests on one premise: "nobody depends on
`plinth_hooks` alone; it exists because `plinth_components` needed a
disclosure controller."** That premise was true of `plinth_core` too
when this was written, and it is exactly what
[ROADMAP.md](ROADMAP.md) decided to change —
`plinth_core` becomes the headline product and `plinth_components`
the reference implementation.

If people depend on `plinth_core` alone, lockstep starts working
against it. A foundation'''s value is that it does not move, and
lockstep bumps its version every time a component ships. The two goals
point in opposite directions.

**Resolved: lockstep stands.** The roadmap's thesis moved once more —
from "`plinth_core` is the headline" to "both layers serve one goal,
making a new Flutter app easier to build" — and that restores the
original argument rather than overriding it. If a user adopts both
layers as one experience, *"which versions go together?"* is exactly
the question they ask, and lockstep answers it by construction.

**One caveat, now that the audience is settled.** The roadmap's target
is Flutter *teams*, and one of the two — a team with an existing app and
their own widgets — may depend on `plinth_core` alone and never install
`plinth_components`. Lockstep shows that team version bumps containing
nothing for them.

That is the cost this section already accepted in writing (*"some 1.x
releases of the leaf packages will contain nothing but a version
bump"*), and it is still smaller than a compatibility table for the
teams who adopt both. **Revisit only if `plinth_core`-only adoption
turns out to dominate** — which is a fact to observe, not to predict.

Left in place rather than deleted, so the record shows the question was
answered rather than forgotten. Tracked as **V1** in
[ROADMAP.md](ROADMAP.md).

### The `1.0.0-beta.1` rehearsal

The beta exists so this sequence gets run once while a mistake is still
cheap. It is the same five steps as below, with `1.0.0-beta.1` in place
of `1.0.0`, and **the dry run cannot substitute for step 3.**

That was checked rather than assumed. Running
`flutter pub publish --dry-run` in `plinth_components` with the new
constraints in place **resolves cleanly** — because
`pubspec_overrides.yaml` points at the local siblings, so pub never
looks for `plinth_core 1.0.0-beta.1` on pub.dev at all. Pub says so
itself, in a hint most people skim past:

> Non-dev dependencies are overridden in pubspec_overrides.yaml.

A green dry run in the workspace is therefore **not evidence** that the
package a consumer downloads will resolve. It is the 0.6.0 failure with
the alarm already ringing.

**Verified in the beta:** `^1.0.0-beta.1` does resolve, and picks the
prerelease — a caret whose lower bound is a prerelease of the same
version matches that prerelease, so the constraint carries through to
`1.0.0` final without another edit.

**And a second lesson, which cost more than it should have.** Right
after publishing a version, pub.dev's listing takes a while to
propagate, and during that window a resolve fails with
*"which doesn't match any versions"* — the same message an
unpublished dependency gives. Clearing the local cache does **not**
fix it; only waiting does. It flaps rather than failing cleanly, so
the same command can fail, succeed, and fail again within a minute.

Do not conclude anything from a single failed resolve in that window.
Re-run it until two consecutive runs agree, then believe them. The
check is worth running anyway — it is the only one that sees what a
consumer sees — but it needs a moment after publishing before its
answer means anything.

### The 1.0.0 release sequence

Dependency order matters more here than in any release so far, because
all three constraints move at once. **This is the mistake that already
shipped a broken `plinth_components` 0.6.0** — see the warning at the
top of this file — and the workspace cannot catch it, because melos
resolves siblings from disk.

1. **`plinth_core` → 1.0.0.** Bump, CHANGELOG entry, `flutter pub publish`.
2. **`plinth_hooks` → 1.0.0.** Same. Its entry should say the version
   is lockstep rather than invent a change.
3. **Wait for both to be resolvable.** Not just "published" — pub
   caches version listings on disk, so verify from a scratch directory
   outside the workspace:
   ```bash
   flutter create resolve_check && cd resolve_check
   flutter pub add plinth_core plinth_hooks
   ```
   If it fails and you believe it shouldn't, clear the stale listing
   (paths in the section above) and retry.
4. **Raise both constraints** in `packages/plinth_components/pubspec.yaml`:
   `plinth_core: ^1.0.0` and `plinth_hooks: ^1.0.0`. The hooks
   constraint stops being the `>=0.0.1 <0.1.0` form, since `^` finally
   means something once the major version is non-zero.
5. **`plinth_components` → 1.0.0**, then
   `melos bootstrap && melos run analyze && melos run format && melos run test`,
   then publish.

Steps 1 and 2 must actually complete before step 5. Publishing
components against constraints pub.dev has never seen is the exact
failure described at the top of this file.

### What 1.0.0 promises

Worth writing down before it is claimed, because a major version is a
statement about the future rather than the present.

**The promise is about the API: no breaking source change without a
2.0.0.** Constructors, parameters, types and names. Code that compiles
against `1.x` keeps compiling against every later `1.x`.

**Rendered output is not covered, and that is deliberate rather than a
loophole.** A minor release may change colours, sizes, spacing or what a
screen reader announces, where the change is a correction. This library
has already shipped several of those and will ship more:

- `readableOn`'s floor moved from 3.0 to 4.5 because 3.0 is WCAG's
  *large text* threshold and most callers are painting a table cell.
- Anchoring the ramp generator repainted all 13 palettes, because they
  had never matched the values they were seeded with.
- Alert icons were failing 3:1 on 7 of 13 ramps.
- Eight controls announced as unnamed buttons.

**Not one of those could have waited for a 2.0.0**, and a promise that
would have forced them to wait is a promise that keeps the library
wrong. The honest version is the narrower one.

What this costs you, stated plainly: **pin goldens against a version,
not a range.** If you screenshot-test a Plinth UI, treat a minor bump as
something to re-baseline and review, the same way this repo does. The
CHANGELOG calls out every visual change under **Changed**, with the
measurement behind it.

**`B0c` — the manual screen-reader pass — had not run when 1.0.0
shipped.** Everything accessibility-related is verified by tests and
simulated semantics trees and has not been heard aloud. Findings from it
land as corrections under this policy, in a `1.x`.

The naming pass in 0.20.0 was the last breaking *API* change, which is
what makes the API half of this credible rather than optimistic.

**That stopped being true, and it is why `1.0.0-beta.2` exists.**
Migrating a real app onto the packages
([ADOPTION_REQUIREMENTS.md](ADOPTION_REQUIREMENTS.md)) produced three
more breaking changes after 0.20.0 — `readableOn`'s contrast floor, the
anchored ramp generator, and the filled-label flip that followed from
it. None was foreseeable from inside the source; all three came from
watching someone use it.

So the sequence above is unchanged but its **precondition** is not:
**do not start it while a requirement that moves rendered output is
still open.** `PR-17` is exactly that. A promise of "no breaking change
without a 2.0.0" made one week before a known visual change is not a
promise, and the fix is another beta rather than a softer promise.

## Optional automation

Dart supports [automated publishing via GitHub Actions](https://dart.dev/tools/pub/automated-publishing) —
publishing triggers off a git tag matching a pattern you configure on
pub.dev, instead of running `flutter pub publish` by hand. The manual
process has now been done successfully more than once, so the
prerequisite ("understand what you're automating") is satisfied.
