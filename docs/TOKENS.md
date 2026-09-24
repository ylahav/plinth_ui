# Tokens

**Generated — do not edit.** Run
`flutter test tool/generate_token_usage.dart` from
`packages/plinth_components`. `token_usage_fresh_test.dart`
fails if this file falls behind the source.

Every token, and which components read it. The question
this answers is the one you ask before changing a token,
and it was previously answerable only by grepping and
hoping you guessed the right spelling — `theme.surface`,
`theme.spacing[PlinthSize.md]` and `theme.space(4)` are
all token reads and none of them look alike.

Values come from `PlinthTheme.defaultTheme` and
`PlinthTheme.darkTheme`. A rebranded theme has different
values and the same readers.

## Every token, in both themes

| Token | Tier | Light | Dark | Read by |
|---|---|---|---|---|
| `color.blue.0` | primitive | `#f0f5f9` | `#f0f5f9` | — |
| `color.blue.1` | primitive | `#deeaf5` | `#deeaf5` | — |
| `color.blue.2` | primitive | `#bfd9ef` | `#bfd9ef` | — |
| `color.blue.3` | primitive | `#99c5eb` | `#99c5eb` | — |
| `color.blue.4` | primitive | `#6eb0e9` | `#6eb0e9` | — |
| `color.blue.5` | primitive | `#439cea` | `#439cea` | — |
| `color.blue.6` | primitive | `#228be6` | `#228be6` | — |
| `color.blue.7` | primitive | `#1a71bc` | `#1a71bc` | — |
| `color.blue.8` | primitive | `#185a93` | `#185a93` | — |
| `color.blue.9` | primitive | `#15436b` | `#15436b` | — |
| `color.cyan.0` | primitive | `#f0f8f9` | `#f0f8f9` | — |
| `color.cyan.1` | primitive | `#daf0f3` | `#daf0f3` | — |
| `color.cyan.2` | primitive | `#b4e5ec` | `#b4e5ec` | — |
| `color.cyan.3` | primitive | `#85dce8` | `#85dce8` | — |
| `color.cyan.4` | primitive | `#50d2e5` | `#50d2e5` | — |
| `color.cyan.5` | primitive | `#1bcde6` | `#1bcde6` | — |
| `color.cyan.6` | primitive | `#15aabf` | `#15aabf` | — |
| `color.cyan.7` | primitive | `#168fa0` | `#168fa0` | — |
| `color.cyan.8` | primitive | `#157785` | `#157785` | — |
| `color.cyan.9` | primitive | `#14606b` | `#14606b` | — |
| `color.grape.0` | primitive | `#f7f1f9` | `#f7f1f9` | — |
| `color.grape.1` | primitive | `#f0e2f4` | `#f0e2f4` | — |
| `color.grape.2` | primitive | `#e6c9ed` | `#e6c9ed` | — |
| `color.grape.3` | primitive | `#dbaae8` | `#dbaae8` | — |
| `color.grape.4` | primitive | `#d088e2` | `#d088e2` | — |
| `color.grape.5` | primitive | `#c866e0` | `#c866e0` | — |
| `color.grape.6` | primitive | `#be4bdb` | `#be4bdb` | — |
| `color.grape.7` | primitive | `#a12bbf` | `#a12bbf` | — |
| `color.grape.8` | primitive | `#7b2490` | `#7b2490` | — |
| `color.grape.9` | primitive | `#551c64` | `#551c64` | — |
| `color.gray.0` | primitive | `#f4f5f5` | `#f4f5f5` | — |
| `color.gray.1` | primitive | `#e9eaeb` | `#e9eaeb` | — |
| `color.gray.2` | primitive | `#d8dadc` | `#d8dadc` | — |
| `color.gray.3` | primitive | `#c3c7ca` | `#c3c7ca` | — |
| `color.gray.4` | primitive | `#adb2b7` | `#adb2b7` | — |
| `color.gray.5` | primitive | `#989fa6` | `#989fa6` | — |
| `color.gray.6` | primitive | `#868e96` | `#868e96` | — |
| `color.gray.7` | primitive | `#6a7279` | `#6a7279` | — |
| `color.gray.8` | primitive | `#53595e` | `#53595e` | — |
| `color.gray.9` | primitive | `#3c4044` | `#3c4044` | — |
| `color.green.0` | primitive | `#f2f8f3` | `#f2f8f3` | — |
| `color.green.1` | primitive | `#e2f0e4` | `#e2f0e4` | — |
| `color.green.2` | primitive | `#c6e5cc` | `#c6e5cc` | — |
| `color.green.3` | primitive | `#a6dbaf` | `#a6dbaf` | — |
| `color.green.4` | primitive | `#80d18f` | `#80d18f` | — |
| `color.green.5` | primitive | `#5dc970` | `#5dc970` | — |
| `color.green.6` | primitive | `#40c057` | `#40c057` | — |
| `color.green.7` | primitive | `#379b49` | `#379b49` | — |
| `color.green.8` | primitive | `#2e7a3c` | `#2e7a3c` | — |
| `color.green.9` | primitive | `#245b2e` | `#245b2e` | — |
| `color.indigo.0` | primitive | `#f0f2fa` | `#f0f2fa` | — |
| `color.indigo.1` | primitive | `#e1e6f7` | `#e1e6f7` | — |
| `color.indigo.2` | primitive | `#c9d1f4` | `#c9d1f4` | — |
| `color.indigo.3` | primitive | `#aab9f3` | `#aab9f3` | — |
| `color.indigo.4` | primitive | `#889ef3` | `#889ef3` | — |
| `color.indigo.5` | primitive | `#6683f6` | `#6683f6` | — |
| `color.indigo.6` | primitive | `#4c6ef5` | `#4c6ef5` | — |
| `color.indigo.7` | primitive | `#133ee8` | `#133ee8` | — |
| `color.indigo.8` | primitive | `#1231ab` | `#1231ab` | — |
| `color.indigo.9` | primitive | `#0f2370` | `#0f2370` | — |
| `color.lime.0` | primitive | `#f6f9f1` | `#f6f9f1` | — |
| `color.lime.1` | primitive | `#eaf3dc` | `#eaf3dc` | — |
| `color.lime.2` | primitive | `#d7ebba` | `#d7ebba` | — |
| `color.lime.3` | primitive | `#c2e690` | `#c2e690` | — |
| `color.lime.4` | primitive | `#abe160` | `#abe160` | — |
| `color.lime.5` | primitive | `#97e031` | `#97e031` | — |
| `color.lime.6` | primitive | `#82c91e` | `#82c91e` | — |
| `color.lime.7` | primitive | `#6ca51d` | `#6ca51d` | — |
| `color.lime.8` | primitive | `#59861b` | `#59861b` | — |
| `color.lime.9` | primitive | `#476818` | `#476818` | — |
| `color.orange.0` | primitive | `#faf4ef` | `#faf4ef` | — |
| `color.orange.1` | primitive | `#f7e9dc` | `#f7e9dc` | — |
| `color.orange.2` | primitive | `#f5d5bb` | `#f5d5bb` | — |
| `color.orange.3` | primitive | `#f5c093` | `#f5c093` | — |
| `color.orange.4` | primitive | `#f7a765` | `#f7a765` | — |
| `color.orange.5` | primitive | `#fd9137` | `#fd9137` | — |
| `color.orange.6` | primitive | `#fd7e14` | `#fd7e14` | — |
| `color.orange.7` | primitive | `#d56507` | `#d56507` | — |
| `color.orange.8` | primitive | `#a4500a` | `#a4500a` | — |
| `color.orange.9` | primitive | `#753b0a` | `#753b0a` | — |
| `color.pink.0` | primitive | `#f9f1f4` | `#f9f1f4` | — |
| `color.pink.1` | primitive | `#f5e2e8` | `#f5e2e8` | — |
| `color.pink.2` | primitive | `#f0c8d6` | `#f0c8d6` | — |
| `color.pink.3` | primitive | `#eca9c1` | `#eca9c1` | — |
| `color.pink.4` | primitive | `#ea86a9` | `#ea86a9` | — |
| `color.pink.5` | primitive | `#ea6493` | `#ea6493` | — |
| `color.pink.6` | primitive | `#e64980` | `#e64980` | — |
| `color.pink.7` | primitive | `#ce215e` | `#ce215e` | — |
| `color.pink.8` | primitive | `#9a1d49` | `#9a1d49` | — |
| `color.pink.9` | primitive | `#691733` | `#691733` | — |
| `color.red.0` | primitive | `#faf0f0` | `#faf0f0` | — |
| `color.red.1` | primitive | `#f8e2e2` | `#f8e2e2` | — |
| `color.red.2` | primitive | `#f6caca` | `#f6caca` | — |
| `color.red.3` | primitive | `#f6adad` | `#f6adad` | — |
| `color.red.4` | primitive | `#f78c8c` | `#f78c8c` | — |
| `color.red.5` | primitive | `#fb6b6b` | `#fb6b6b` | — |
| `color.red.6` | primitive | `#fa5252` | `#fa5252` | — |
| `color.red.7` | primitive | `#f21010` | `#f21010` | — |
| `color.red.8` | primitive | `#b20e0e` | `#b20e0e` | — |
| `color.red.9` | primitive | `#730d0d` | `#730d0d` | — |
| `color.teal.0` | primitive | `#f0f9f7` | `#f0f9f7` | — |
| `color.teal.1` | primitive | `#d9f3eb` | `#d9f3eb` | — |
| `color.teal.2` | primitive | `#b1ecda` | `#b1ecda` | — |
| `color.teal.3` | primitive | `#80e8c9` | `#80e8c9` | — |
| `color.teal.4` | primitive | `#48e6b6` | `#48e6b6` | — |
| `color.teal.5` | primitive | `#16e3a5` | `#16e3a5` | — |
| `color.teal.6` | primitive | `#12b886` | `#12b886` | — |
| `color.teal.7` | primitive | `#139c73` | `#139c73` | — |
| `color.teal.8` | primitive | `#148462` | `#148462` | — |
| `color.teal.9` | primitive | `#136c51` | `#136c51` | — |
| `color.violet.0` | primitive | `#f2f0fa` | `#f2f0fa` | — |
| `color.violet.1` | primitive | `#e7e2f7` | `#e7e2f7` | — |
| `color.violet.2` | primitive | `#d4caf4` | `#d4caf4` | — |
| `color.violet.3` | primitive | `#beacf2` | `#beacf2` | — |
| `color.violet.4` | primitive | `#a58bf2` | `#a58bf2` | — |
| `color.violet.5` | primitive | `#8d69f4` | `#8d69f4` | — |
| `color.violet.6` | primitive | `#7950f2` | `#7950f2` | — |
| `color.violet.7` | primitive | `#4b17e4` | `#4b17e4` | — |
| `color.violet.8` | primitive | `#3a15a8` | `#3a15a8` | — |
| `color.violet.9` | primitive | `#29116e` | `#29116e` | — |
| `color.yellow.0` | primitive | `#faf7ef` | `#faf7ef` | — |
| `color.yellow.1` | primitive | `#f7eedb` | `#f7eedb` | — |
| `color.yellow.2` | primitive | `#f3e1b8` | `#f3e1b8` | — |
| `color.yellow.3` | primitive | `#f3d48d` | `#f3d48d` | — |
| `color.yellow.4` | primitive | `#f5c75b` | `#f5c75b` | — |
| `color.yellow.5` | primitive | `#fbbc2b` | `#fbbc2b` | — |
| `color.yellow.6` | primitive | `#fab005` | `#fab005` | — |
| `color.yellow.7` | primitive | `#c88e09` | `#c88e09` | — |
| `color.yellow.8` | primitive | `#9d710b` | `#9d710b` | — |
| `color.yellow.9` | primitive | `#74540c` | `#74540c` | — |
| `spacing.xs` | primitive | 10 | 10 | 39 |
| `radius.xs` | primitive | 2 | 2 | 3 |
| `fontSize.xs` | primitive | 12 | 12 | 1 |
| `borderWidth.xs` | primitive | 1 | 1 | 1 |
| `duration.xs` | primitive | 100ms | 100ms | 1 |
| `spacing.sm` | primitive | 12 | 12 | 22 |
| `radius.sm` | primitive | 4 | 4 | 3 |
| `fontSize.sm` | primitive | 14 | 14 | 1 |
| `borderWidth.sm` | primitive | 1.5 | 1.5 | 1 |
| `duration.sm` | primitive | 150ms | 150ms | 6 |
| `spacing.md` | primitive | 16 | 16 | 6 |
| `radius.md` | primitive | 8 | 8 | — |
| `fontSize.md` | primitive | 16 | 16 | — |
| `borderWidth.md` | primitive | 2 | 2 | 8 |
| `duration.md` | primitive | 200ms | 200ms | 3 |
| `spacing.lg` | primitive | 20 | 20 | 3 |
| `radius.lg` | primitive | 16 | 16 | — |
| `fontSize.lg` | primitive | 18 | 18 | — |
| `borderWidth.lg` | primitive | 3 | 3 | 1 |
| `duration.lg` | primitive | 300ms | 300ms | — |
| `spacing.xl` | primitive | 32 | 32 | 1 |
| `radius.xl` | primitive | 32 | 32 | — |
| `fontSize.xl` | primitive | 20 | 20 | — |
| `borderWidth.xl` | primitive | 4 | 4 | 1 |
| `duration.xl` | primitive | 500ms | 500ms | — |
| `fontWeight.regular` | primitive | w400 | w400 | 7 |
| `fontWeight.medium` | primitive | w500 | w500 | — |
| `fontWeight.semibold` | primitive | w600 | w600 | 22 |
| `fontWeight.bold` | primitive | w700 | w700 | 11 |
| `curve.standard` | primitive | Cubic(0.00, 0.00, 0.58, 1.00) | Cubic(0.00, 0.00, 0.58, 1.00) | 4 |
| `curve.emphasized` | primitive | Cubic(0.21, 0.61, 0.35, 1.00) | Cubic(0.21, 0.61, 0.35, 1.00) | 1 |
| `curve.linear` | primitive | _Linear | _Linear | — |
| `elevation.none` | primitive | blur 0.0, y 0.0 | blur 0.0, y 0.0 | — |
| `elevation.sm` | primitive | blur 4.0, y 1.0 | blur 4.0, y 1.0 | — |
| `elevation.md` | primitive | blur 10.0, y 4.0 | blur 10.0, y 4.0 | — |
| `elevation.lg` | primitive | blur 20.0, y 8.0 | blur 20.0, y 8.0 | — |
| `series.0` | primitive | `#f6caca` | `#f6caca` | — |
| `series.1` | primitive | `#aab9f3` | `#aab9f3` | — |
| `series.2` | primitive | `#7950f2` | `#7950f2` | — |
| `series.3` | primitive | `#5dc970` | `#5dc970` | — |
| `series.4` | primitive | `#e6c9ed` | `#e6c9ed` | — |
| `series.5` | primitive | `#1a71bc` | `#1a71bc` | — |
| `series.6` | primitive | `#f5c75b` | `#f5c75b` | — |
| `series.7` | primitive | `#a4500a` | `#a4500a` | — |
| `series.8` | primitive | `#d7ebba` | `#d7ebba` | — |
| `series.9` | primitive | `#ea86a9` | `#ea86a9` | — |
| `surface` | semantic | `#ffffff` | `#1a1b1e` | 44 |
| `surfaceMuted` | semantic | `#f1f3f5` | `#25262b` | 24 |
| `surfaceSunken` | semantic | `#e9ecef` | `#2c2e33` | 15 |
| `border` | semantic | `#808890` | `#71777f` | 24 |
| `borderMuted` | semantic | `#dee2e6` | `#2c2e33` | 5 |
| `text` | semantic | `#000000` | `#c1c2c5` | 17 |
| `textMuted` | semantic | `#000000` | `#939599` | 15 |
| `textDisabled` | semantic | `#000000` | `#5c5f66` | 7 |
| `onFilled` | semantic | `#ffffff` | `#ffffff` | 3 |
| `onFilledInverse` | semantic | `#1a1b1e` | `#1a1b1e` | — |
| `shadow` | semantic | `#000000` | `#000000` | 5 |
| `scrim` | semantic | `#000000` | `#000000` | 1 |
| `role.error` | semantic | `#fa5252` | `#fa5252` | — |
| `role.neutral` | semantic | `#868e96` | `#868e96` | — |
| `role.success` | semantic | `#40c057` | `#40c057` | — |

## What reads what

| Token | Components |
|---|---|
| `border` | **24 components**, including FieldChrome, PlinthActionIcon, PlinthAutocomplete, PlinthButton |
| `borderMuted` | PlinthActionIcon, PlinthButton, PlinthFloatingWindow, PlinthKbd, PlinthTable |
| `borderWidth.lg` | PlinthBlockquote |
| `borderWidth.md` | **8 components**, including FocusRing, PlinthAnchor, PlinthColorSwatch, PlinthPinInput |
| `borderWidth.sm` | PlinthCheckbox |
| `borderWidth.xl` | PlinthNotification |
| `borderWidth.xs` | PlinthAppShell |
| `curve.emphasized` | PlinthRollingNumber |
| `curve.standard` | PlinthAccordion, PlinthProgress, PlinthSpoiler, PlinthSwitch |
| `duration.md` | PlinthNavLink, PlinthProgress, PlinthSpoiler |
| `duration.sm` | PlinthAccordion, PlinthBurger, PlinthCarousel, PlinthChip, PlinthSegmentedControl, PlinthSwitch |
| `duration.xs` | PlinthBurger |
| `fontSize.sm` | PlinthFieldset |
| `fontSize.xs` | SliderMarks |
| `fontWeight.bold` | **11 components**, including PlinthAlert, PlinthBadge, PlinthDialog, PlinthDrawer |
| `fontWeight.regular` | **7 components**, including PlinthChip, PlinthNavLink, PlinthPagination, PlinthSegmentedControl |
| `fontWeight.semibold` | **22 components**, including FieldChrome, PlinthAccordion, PlinthAvatar, PlinthButton |
| `onFilled` | PlinthBackgroundImage, PlinthSwitch, PlinthTooltip |
| `radius.sm` | FocusRing, PlinthBackgroundImage, PlinthUnstyledButton |
| `radius.xs` | PlinthColorInput, PlinthColorPicker, PlinthTree |
| `scrim` | PlinthBackgroundImage |
| `shadow` | ColorSliderBase, PlinthCombobox, PlinthDialog, PlinthFloatingWindow, PlinthSwitch |
| `spacing.lg` | PlinthDrawer, PlinthEmptyState, PlinthNavLink |
| `spacing.md` | PlinthAlert, PlinthBlockquote, PlinthDialog, PlinthEmptyState, PlinthStepper, PlinthTimeline |
| `spacing.sm` | **22 components**, including PlinthAccordion, PlinthAlert, PlinthAutocomplete, PlinthBlockquote |
| `spacing.xl` | PlinthEmptyState |
| `spacing.xs` | **39 components**, including FieldChrome, PlinthAccordion, PlinthAlert, PlinthAutocomplete |
| `surface` | **44 components**, including ColorSliderBase, FocusRing, PlinthActionIcon, PlinthAnchor |
| `surfaceMuted` | **24 components**, including PlinthActionIcon, PlinthAutocomplete, PlinthBackgroundImage, PlinthBadge |
| `surfaceSunken` | **15 components**, including ColorSliderBase, PlinthAccordion, PlinthAngleSlider, PlinthCarousel |
| `text` | **17 components**, including PlinthActionIcon, PlinthAlert, PlinthBadge, PlinthButton |
| `textDisabled` | **7 components**, including PlinthActionIcon, PlinthButton, PlinthCloseButton, PlinthFileInput |
| `textMuted` | **15 components**, including FieldChrome, PlinthCascader, PlinthCloseButton, PlinthDataList |

## Reads that cannot be pinned to one token

These are real token reads whose target is only known at
runtime — the caller passed the ramp. Recording them as a
kind rather than guessing a path is deliberate: assuming
`color.blue.6` because blue is the default would be a lie
that survives until somebody rebrands.

| Kind of read | Components |
|---|---|
| a ramp chosen at runtime | **54 components**, including FieldChrome, PlinthActionIcon, PlinthAlert, PlinthAngleSlider |
| a ramp, resolved against the contrast floor | **17 components**, including FocusRing, PlinthActionIcon, PlinthAlert, PlinthAnchor |
| the spacing unit, by multiple | PlinthCascader |

## Tokens nothing reads

Not necessarily dead. A token can exist for an *adopter*
to read rather than for this library to paint with, which
is most of the point of a token layer. But a token here
that nobody outside can name either is worth a question.

