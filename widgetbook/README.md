# plinth_widgetbook

The isolated component gallery for Plinth UI — every component's key
states as browsable use cases, separate from the `example/` app (which
shows everything composed together on one scrollable page).

## Running it

```bash
melos bootstrap          # from the repo root, once
cd widgetbook
flutter run -d chrome    # or any device
```

The `web/` platform folder is checked in, so no `flutter create` step
is needed.

## What's in here

`lib/main.dart` registers everything manually — directories, components,
and use cases are written in Dart rather than generated from `@UseCase`
annotations, so there's no `build_runner` step to run.

Each component has two kinds of use case:

- **Playground** — one instance driven by `context.knobs.*`, for
  exploring combinations nobody enumerated in advance. Knob values are
  encoded into the URL, so a particular configuration is a shareable
  link.
- **Static variants** ("All variants", "All sizes", "Error state", …) —
  fixed compositions, often rendering every option side by side. These
  aren't redundant with a playground: comparing `subtle` against
  `transparent` needs them on screen together, which a single
  knob-driven instance can't show.

66 of the 71 components have a playground. The rest take a child and
little else, so a playground would be ceremony — see the doc comment on
`PlinthWidgetbookApp` for the full reasoning and the conventions to
follow when adding more.

## Tests

`test/gallery_smoke_test.dart` builds every use case and asserts none
throws:

```bash
flutter test
```

It runs in CI via `melos run test`. This catches a use case that
compiles but blows up on render — a knob value that trips an assertion
inside a component, say — before anyone opens that page. It asserts the
absence of exceptions at each use case's initial knob values, and
nothing about appearance.
