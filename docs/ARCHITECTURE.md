# Plinth UI — Architecture

Plinth UI is structured as a multi‑package design system for Flutter. Each
package serves a distinct role, and together they form the design system described in [VISION.md](VISION.md).

---

## 1. Package Overview

### `plinth_core`
The foundation of the system. Defines:

- `PlinthTheme` (ThemeExtension)
- Color ramps and shade generator
- Semantic chrome tokens
- Spacing, radius, font size, border width, elevation, duration, curve
- Role ramps and contrast‑floor resolution
- Token hierarchy and validation
- DTCG import/export

All components and blocks resolve their tokens through this package.

---

### `plinth_components`
The component library. Contains:

- Components across primitives, forms, navigation, overlays, data display,
  feedback, surfaces, and layout.
- Accessibility primitives: FocusTrap, LiveRegion, AnnounceWhen, TapTarget.
- Controlled‑component patterns (Tabs, SegmentedControl, Stepper).
- Overlay system (Modal, Drawer, Popover, Menu, Menubar).
- Responsive layout primitives (Grid, SimpleGrid, AppShell).

Every component reads from `PlinthTheme` and follows the token system.

---

### `plinth_hooks`
State utilities required by components:

- `PlinthDisclosureController` (open/close state for overlays)
- `PlinthFormController` (named values, errors, validation, reset; no widgets)
- Roving focus helpers for dropdowns and segmented controls

---

### `plinth_blocks`
Composed blocks: reusable page sections built from components.

- Blocks across Page Sections, Application UI, and Blog UI.
- Designed for real applications, not demos.
- Blocks read tokens from `PlinthTheme`; the starters in `templates/` are the rebrand check.

---

### `plinth_charts`
Chart primitives:

- Line, bar, donut charts
- CVD‑validated categorical palette
- Text alternatives for accessibility

---

### `templates/`
Starter applications:

- Dashboard
- Account shell
- Blog
- Mobile list–detail

Each template is tested in CI.

---

## 2. Architectural Principles

### Token‑first
Tokens drive every component, block, and template. No component uses raw colors
or pixel values.

### Accessibility‑first
Accessibility is a correctness requirement. Every component is reachable,
announced, and contrast‑safe.

### Controlled components
State belongs to the caller. Components report intended state changes rather
than mutating themselves.

### Composition over inheritance
Blocks are composed from components; components are composed from primitives.

### Evidence‑driven development
Gaps are discovered through real application migrations, not speculation.

---

## 3. Data Flow

1. **Tokens** → `PlinthTheme`
2. **Theme** → Components
3. **Components** → Blocks
4. **Blocks** → Templates
5. **Templates** → Real applications

This hierarchy ensures consistency and rebrand survival.

---

## 4. Accessibility Architecture

- Semantics tree correctness
- Keyboard reachability
- Focus visibility
- Live regions
- Announcements
- Density floors
- RTL correctness

Accessibility is implemented at the primitive level and inherited upward.

---

## 5. Testing Architecture

- Golden tests for visual correctness
- Widget tests for behavior
- Smoke tests for blocks
- Template tests for API stability
- Token validation tests
- RTL tests

All packages are tested in CI.

---
