# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/).

The three Plinth packages move in lockstep from `1.0.0` onward — see
[PUBLISHING.md](../../docs/PUBLISHING.md#decided-lockstep-from-10-onward).
A release where this package itself did not change says so rather than
inventing one. Before `1.0.0`, minor bumps could carry breaking
changes; from `1.0.0` they cannot.

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
