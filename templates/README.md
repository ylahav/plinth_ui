# Templates

Starter apps built on Plinth UI. Each one is a real Flutter app that
compiles, runs and is tested in CI alongside the packages — not a
screenshot, and not a snippet.

| Template | What it starts you with |
|---|---|
| [dashboard](dashboard/) | Sidebar shell, overview with charts, filterable orders table, settings form |
| [account](account/) | Sign-in that can fail, then profile, security and team permissions |
| [blog](blog/) | Article list, article with a derived table of contents, comment thread |
| [mobile](mobile/) | Searchable list — a pushed route on a phone, two panes on a tablet |

## How to use one

```bash
cp -r templates/dashboard my-app && cd my-app
flutter create .
flutter run
```

**The platform folders are not committed.** `flutter create .` writes
them, which is the same thing it would do for a new project and keeps
this repository from carrying four copies of the same generated
`android/`, `ios/`, `linux/`, `macos/`, `web/` and `windows/` trees.
`tutorial/` predates this decision and commits 73 such files against 10
of real code; the templates do not repeat it.

## Why they are melos packages

`melos run analyze`, `format` and `test` cover `templates/*` the same as
`packages/*`, so a template that has stopped compiling against the
current API fails in CI. The alternative — a template nobody builds
until someone tries to start a project with it — is how starters rot,
and the person who finds out is the worst possible person to find out.

Each one also doubles as an integration test at app scale: the packages
test their own units, and these test that the units still assemble into
something that works.

## What they are not

They are not a framework. There is no `plinth_template` package to
depend on, no base class to extend, nothing to keep in sync. You copy
the directory and it becomes yours — including the parts you delete.
