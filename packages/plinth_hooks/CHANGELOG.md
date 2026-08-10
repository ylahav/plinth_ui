# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to adhere to [Semantic Versioning](https://semver.org/)
once it reaches a `1.0.0` release. Versions before `1.0.0` may include
breaking changes without a major version bump.

## 0.0.1 — Initial development release

- `PlinthDisclosureController`: a `ChangeNotifier`-based open/closed
  state controller (`open()`, `close()`, `toggle()`, `isOpen`) —
  Plinth's equivalent of Mantine's `useDisclosure` hook. Drives every
  controller-based overlay in `plinth_components`
  (`PlinthModal`, `PlinthDrawer`, `PlinthPopover`, `PlinthMenu`).
