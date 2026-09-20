# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/).

Unlike `plinth_core`, `plinth_components` and `plinth_hooks`, this
package is **not yet in the lockstep** those three keep from `1.0.0`
onward — see
[PUBLISHING.md](../../docs/PUBLISHING.md#decided-lockstep-from-10-onward).
Whether it joins, or versions on its own because a block catalogue will
churn while a token engine does not, is a decision for the first
release rather than one to inherit from the number below.

## 0.1.0

Unreleased. The first blocks, and the shape the rest will follow.

### Added

- `PlinthAuthCard` — the card the authentication blocks are built in,
  public because the four here are not the only auth screens an app
  has. A "check your email" interstitial or an SSO hand-off is the same
  card with different contents, and rebuilding it to add one is how a
  screen ends up not matching the others.
- `PlinthSignInBlock` — email, password, remember-me, a forgot-password
  link that is absent rather than inert when it has nowhere to go, and
  alternatives under a divider that only appears when there are any.
  Reports `(email, password, rememberMe)` on submit.
- `PlinthSignUpBlock` — name, email, password, terms. The terms gate
  the submit button when `requireTerms` is set: a disabled button says
  something is missing, where one that submits and then fails says the
  app is broken. Hiding the checkbox does not leave the gate shut.
- `PlinthPasswordResetBlock` — the request form and the confirmation
  that replaces it, switched by one `sent` bool. The confirmation is
  part of the block because it is the half that gets skipped, and it is
  worded not to say whether the address has an account, which would
  turn a public form into a way to enumerate who has registered.
- `PlinthTwoFactorBlock` — a pin input whose submit stays disabled
  until the code is the full length, because the button is the
  affordance that says how many digits are expected. `autoSubmit` is
  off by default: firing on a mistyped digit spends an attempt before
  the person has finished reading what they typed.
- `PlinthSplitAuthBlock` — the two-pane brand-and-form layout. The
  decoration pane drops below `breakpoint` rather than squeezing both
  halves onto a phone, and the form pane scrolls rather than clipping,
  which the original 620x300 arrangement did the moment a real sign-in
  card went in it.
- `PlinthErrorPageBlock` — one widget with `.notFound`,
  `.serverError`, `.maintenance` and `.permissionDenied` constructors,
  since those differ only in their words. Every default is
  overridable. The permission wording points at the admin who can
  actually grant access, because "access denied" alone leaves someone
  with nothing to do.
- `PlinthOfflineNotice` — deliberately *not* an error page. A dropped
  connection resolves itself, so this is a banner plus the state of the
  queue that the page keeps working around. Yellow rather than red:
  nothing has failed, work is being held.

### Notes

These were extracted from the demo app's showcase, where they were
fixed arrangements with `onPressed: () {}` throughout. Becoming a
package meant giving them the things a gallery never needed: values
reported back, disabled states that mean something, and every visible
string as a parameter.
