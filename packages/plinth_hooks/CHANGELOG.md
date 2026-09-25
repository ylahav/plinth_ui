# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/).

The three Plinth packages move in lockstep from `1.0.0` onward — see
[PUBLISHING.md](../../docs/PUBLISHING.md#decided-lockstep-from-10-onward).
A release where this package itself did not change says so rather than
inventing one. Before `1.0.0`, minor bumps could carry breaking
changes; from `1.0.0` they cannot.

## 1.7.0

No change in this package. Released in lockstep with
`plinth_components` 1.7.0, which completes the full-screen sheet
(`PlinthDrawer` can now hand its child the whole panel, which `extent`
alone did not do) and adds `PlinthClock` plus asset, header and
fallback support on `PlinthImage`.

## 1.6.0

No change in this package. Released in lockstep with
`plinth_components` 1.6.0, which adds `PlinthDrawer.extent` — the
full-screen sheet the size scale could not express, found while
converting an existing app onto Plinth.

This also brings the three back into line after `plinth_core` 1.5.1,
which went out alone because the bug it fixed was core's alone.

## 1.5.0

No change in this package. Released in lockstep with `plinth_core`
1.5.0, which fixes two contrast floors its own new validator found, and
`plinth_components` 1.5.0, which adds a translation seam and fixes two
dropdowns a keyboard could not use.

## 1.4.0

No change in this package. Released in lockstep with
`plinth_components` 1.4.0, which adds `inputFormatters` to
`PlinthTextarea` — the one parameter that kept `PlinthCharacterLimitField`
correcting a committed value instead of refusing one.

## 1.3.1

No change in this package. Released in lockstep with
`plinth_components` 1.3.1, which fixes five controls that were
reachable by keyboard and invisible once reached — WCAG 2.4.7.

The constraint on this package is deliberately still `^1.3.0`. Nothing
here moved, so a consumer who already has 1.3.0 has no reason to be
made to take 1.3.1; lockstep is a release convention, not a reason to
force an upgrade that buys nobody anything.

## 1.3.0

No change in this package. Released in lockstep with `plinth_core`
1.3.0, which adds five token fields across four new axes and fixes a
`shadow` token that had painted nothing since `1.0.0`, and
`plinth_components` 1.3.0, which closes Tier 1 of the pre-1.0 audit —
`loading` on every input, `clearable` across the select family, and the
shared field chrome that made both one change rather than eleven.

## 1.2.0

No change in this package. Released in lockstep with `plinth_components`
1.2.0, which builds out `F-3` - the announcement work - and fixes two
components that could not be reached by keyboard. See
[B0C_FINDINGS.md](../../docs/B0C_FINDINGS.md#second-pass--23-aug-2026).

## 1.1.0

No change in this package. Released in lockstep with
`plinth_components` 1.1.0, which carries the fixes from the
[B0c screen-reader pass](../../docs/B0C_FINDINGS.md).

## 1.0.1

**No changes to this package.** The version moves because the three
packages are released in lockstep. The other two shipped a pubspec
description that exceeded pub.dev's 180-character limit; this one did
not, which is why it kept 160 pub points while they dropped to 150.

## 1.0.0

**No changes to this package.** The version moves because the three
packages are released in lockstep.

`PlinthDisclosureController` has been unchanged since `0.0.2` and is
what the overlay components take. The rest of what a Mantine-style hooks
package would carry is deliberately not here — a team adopting Plinth
has its own state utilities. See
[the roadmap](../../docs/ROADMAP.md) for what survives that call.

**What 1.0.0 promises:** no breaking *source* change without a 2.0.0.
See [PUBLISHING.md](../../docs/PUBLISHING.md#what-100-promises).

## 1.0.0-beta.2

**No changes to this package.** The version moves because the three
packages are released in lockstep.

## 1.0.0-beta.1

**No changes to this package.** The version moves because the three
Plinth packages are now released in lockstep, and this is the first
release under that convention. `PlinthDisclosureController` is
unchanged since 0.0.2, which is itself the argument for lockstep: a
package nobody depends on directly is one whose version number is only
useful as an answer to "which one goes with the others?".

The `1.0.0-beta` line is the rehearsal for that promise, not the
promise itself: the API is what 1.0.0 intends to ship, and the beta
exists so the three-package release sequence gets run once while a
mistake is still cheap. `flutter pub add` still resolves the last
stable release unless a prerelease is asked for.

## 0.0.2

### Added
- An `example/` showing `PlinthDisclosureController` driving a panel,
  including the listener/dispose pairing every caller needs and the
  fact that `close()` on an already-closed controller is a no-op.

## 0.0.1 — Initial development release

- `PlinthDisclosureController`: a `ChangeNotifier`-based open/closed
  state controller (`open()`, `close()`, `toggle()`, `isOpen`) —
  Plinth's equivalent of Mantine's `useDisclosure` hook. Drives every
  controller-based overlay in `plinth_components`
  (`PlinthModal`, `PlinthDrawer`, `PlinthPopover`, `PlinthMenu`).
