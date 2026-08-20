import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

// ─────────────────────────── Application UI: Navbars ───────────────────────────

class SimpleNavbarExample extends StatelessWidget {
  const SimpleNavbarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: Row(
        children: [
          const PlinthText('Acme',
              size: PlinthSize.lg, weight: FontWeight.w700),
          const SizedBox(width: 32),
          Expanded(
            child: PlinthGroup(
              gap: PlinthSize.lg,
              children: [
                PlinthAnchor('Product', onTap: () {}),
                PlinthAnchor('Pricing', onTap: () {}),
                PlinthAnchor('About', onTap: () {}),
              ],
            ),
          ),
          PlinthButton(onPressed: () {}, child: const Text('Sign in')),
        ],
      ),
    );
  }
}

class NavbarWithAvatarExample extends StatelessWidget {
  const NavbarWithAvatarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: Row(
        children: [
          const PlinthThemeIcon(
              icon: Icon(Icons.hexagon), variant: PlinthVariant.filled),
          const SizedBox(width: 12),
          const PlinthText('Dashboard', weight: FontWeight.w600),
          const Spacer(),
          PlinthActionIcon(
            semanticLabel: 'Notifications',
            icon: const Icon(Icons.notifications_none, size: 18),
            onPressed: () {},
            variant: PlinthVariant.subtle,
          ),
          const SizedBox(width: 12),
          const PlinthAvatar(initials: 'YL', size: PlinthSize.sm),
        ],
      ),
    );
  }
}

// ─────────────────────────── Application UI: Headers ───────────────────────────

class CenteredHeaderExample extends StatelessWidget {
  const CenteredHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlinthCenter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PlinthText('Settings', size: PlinthSize.xl, weight: FontWeight.w700),
          SizedBox(height: 4),
          PlinthText(
            'Manage your account preferences and integrations',
            size: PlinthSize.sm,
            color: 'gray',
          ),
        ],
      ),
    );
  }
}

class HeaderWithBreadcrumbsExample extends StatelessWidget {
  const HeaderWithBreadcrumbsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlinthBreadcrumbs(
          items: [
            PlinthBreadcrumbItem(label: 'Home', onTap: () {}),
            PlinthBreadcrumbItem(label: 'Projects', onTap: () {}),
            const PlinthBreadcrumbItem(label: 'Plinth UI'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(
              child: PlinthText('Plinth UI',
                  size: PlinthSize.xl, weight: FontWeight.w700),
            ),
            PlinthButton(
              onPressed: () {},
              leadingIcon: const Icon(Icons.add, size: 16),
              child: const Text('New release'),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────── Page Sections: Hero Sections ───────────────────────────

class HeroCenteredExample extends StatelessWidget {
  const HeroCenteredExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthCenter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PlinthBadge('New', color: 'grape'),
          const SizedBox(height: 12),
          const PlinthText(
            'Build interfaces faster',
            size: PlinthSize.xl,
            weight: FontWeight.w800,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const PlinthText(
            'A themeable Flutter component library for teams that ship.',
            size: PlinthSize.sm,
            color: 'gray',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PlinthGroup(
            mainAxisAlignment: MainAxisAlignment.center,
            gap: PlinthSize.sm,
            children: [
              PlinthButton(onPressed: () {}, child: const Text('Get started')),
              PlinthButton(
                onPressed: () {},
                variant: PlinthVariant.outline,
                child: const Text('Documentation'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeroSplitExample extends StatelessWidget {
  const HeroSplitExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PlinthText(
                'Ship your product today',
                size: PlinthSize.lg,
                weight: FontWeight.w700,
              ),
              const SizedBox(height: 8),
              const PlinthText(
                'Every component is themeable, accessible, and tested.',
                size: PlinthSize.sm,
                color: 'gray',
              ),
              const SizedBox(height: 12),
              PlinthButton(onPressed: () {}, child: const Text('Try it now')),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: PlinthAspectRatio(
            ratio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE7F5FF),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Page Sections: Feature Sections ───────────────────────────

class FeatureGridExample extends StatelessWidget {
  const FeatureGridExample({super.key});

  static const _features = [
    (
      Icons.bolt_outlined,
      'Fast',
      'Optimized rebuilds with no unnecessary widget churn.'
    ),
    (
      Icons.palette_outlined,
      'Themeable',
      'Every color, spacing, and radius token is overridable.'
    ),
    (
      Icons.accessibility_new,
      'Accessible',
      'Semantics built in, not bolted on afterward.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PlinthSimpleGrid(
      columns: 3,
      spacing: PlinthSize.md,
      children: [
        for (final (icon, title, desc) in _features)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlinthThemeIcon(icon: Icon(icon), variant: PlinthVariant.light),
              const SizedBox(height: 8),
              PlinthText(title, weight: FontWeight.w600),
              const SizedBox(height: 4),
              PlinthText(desc, size: PlinthSize.xs, color: 'gray'),
            ],
          ),
      ],
    );
  }
}

class FeatureListExample extends StatelessWidget {
  const FeatureListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlinthList(
      items: [
        PlinthListItem(
          PlinthText('67+ themeable components, zero design-system lock-in'),
          icon: Icon(Icons.check_circle, color: Color(0xFF40C057), size: 16),
        ),
        PlinthListItem(
          PlinthText('Widgetbook gallery for isolated visual development'),
          icon: Icon(Icons.check_circle, color: Color(0xFF40C057), size: 16),
        ),
        PlinthListItem(
          PlinthText('Published on pub.dev, versioned semantically'),
          icon: Icon(Icons.check_circle, color: Color(0xFF40C057), size: 16),
        ),
      ],
    );
  }
}

// ─────────────────────────── Blog UI: Article Cards ───────────────────────────

class SimpleArticleCardExample extends StatelessWidget {
  const SimpleArticleCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: PlinthCard(
        withBorder: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlinthAspectRatio(
              ratio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const PlinthBadge('Design', color: 'orange'),
            const SizedBox(height: 8),
            const PlinthText('Building a design system from scratch',
                weight: FontWeight.w600),
            const SizedBox(height: 4),
            const PlinthText(
              'A practical guide to tokens, theming, and component APIs.',
              size: PlinthSize.xs,
              color: 'gray',
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleCardWithAuthorExample extends StatelessWidget {
  const ArticleCardWithAuthorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 280,
      child: PlinthCard(
        withBorder: true,
        footer: PlinthGroup(
          gap: PlinthSize.xs,
          children: [
            PlinthAvatar(initials: 'YL', size: PlinthSize.sm),
            PlinthText('Yair Lahav',
                size: PlinthSize.xs, weight: FontWeight.w600),
            PlinthText('· Jan 12', size: PlinthSize.xs, color: 'gray'),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlinthText('Publishing your first Flutter package',
                weight: FontWeight.w600),
            SizedBox(height: 4),
            PlinthText(
              'From pubspec.yaml to a green checkmark on pub.dev.',
              size: PlinthSize.xs,
              color: 'gray',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Blog UI: Author Info ───────────────────────────

class AuthorInlineExample extends StatelessWidget {
  const AuthorInlineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlinthGroup(
      gap: PlinthSize.sm,
      children: [
        PlinthAvatar(initials: 'YL', size: PlinthSize.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PlinthText('Yair Lahav', weight: FontWeight.w600),
            PlinthText('Package maintainer',
                size: PlinthSize.xs, color: 'gray'),
          ],
        ),
      ],
    );
  }
}

class AuthorCardExample extends StatelessWidget {
  const AuthorCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: PlinthCard(
        withBorder: true,
        child: PlinthCenter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PlinthAvatar(initials: 'YL', size: PlinthSize.xl),
              const SizedBox(height: 8),
              const PlinthText('Yair Lahav', weight: FontWeight.w600),
              const SizedBox(height: 4),
              const PlinthText(
                'Building Plinth UI, a Flutter component library.',
                size: PlinthSize.xs,
                color: 'gray',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              PlinthGroup(
                mainAxisAlignment: MainAxisAlignment.center,
                gap: PlinthSize.xs,
                children: [
                  PlinthActionIcon(
                    semanticLabel: 'Show code',
                    icon: const Icon(Icons.code, size: 16),
                    onPressed: () {},
                    variant: PlinthVariant.subtle,
                  ),
                  PlinthActionIcon(
                    semanticLabel: 'Copy link',
                    icon: const Icon(Icons.link, size: 16),
                    onPressed: () {},
                    variant: PlinthVariant.subtle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── Page Sections: Authentication ───────────────────────

class SignInFormExample extends StatelessWidget {
  const SignInFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: PlinthCard(
        withBorder: true,
        p: PlinthSize.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PlinthTitle('Welcome back', order: 3),
            const SizedBox(height: 4),
            const PlinthText(
              'Sign in to continue to your dashboard.',
              size: PlinthSize.sm,
              color: 'gray',
            ),
            const SizedBox(height: 20),
            PlinthTextInput(
              label: 'Email',
              placeholder: 'you@example.com',
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            PlinthPasswordInput(
              label: 'Password',
              placeholder: 'Your password',
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            // Wrap rather than Row: at a large text scale these two
            // no longer fit side by side in a 360-wide card, and a
            // sign-in form is exactly where that must degrade rather
            // than clip.
            PlinthGroup(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              gap: PlinthSize.xs,
              children: [
                PlinthCheckbox(
                  label: 'Remember me',
                  value: true,
                  size: PlinthSize.sm,
                  onChanged: (_) {},
                ),
                PlinthAnchor('Forgot password?',
                    size: PlinthSize.sm, onTap: () {}),
              ],
            ),
            const SizedBox(height: 20),
            PlinthButton(
              fullWidth: true,
              onPressed: () {},
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 16),
            const PlinthDivider(label: 'OR'),
            const SizedBox(height: 16),
            PlinthButton(
              variant: PlinthVariant.defaultVariant,
              fullWidth: true,
              leadingIcon: const Icon(Icons.g_mobiledata, size: 20),
              onPressed: () {},
              child: const Text('Continue with Google'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpFormExample extends StatelessWidget {
  const SignUpFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: PlinthCard(
        withBorder: true,
        p: PlinthSize.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PlinthTitle('Create an account', order: 3),
            const SizedBox(height: 20),
            PlinthTextInput(label: 'Name', onChanged: (_) {}),
            const SizedBox(height: 12),
            PlinthTextInput(
              label: 'Email',
              placeholder: 'you@example.com',
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            PlinthPasswordInput(
              label: 'Password',
              description: 'At least 12 characters.',
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            PlinthCheckbox(
              label: 'I agree to the terms of service',
              value: false,
              size: PlinthSize.sm,
              onChanged: (_) {},
            ),
            const SizedBox(height: 20),
            PlinthButton(
              fullWidth: true,
              onPressed: () {},
              child: const Text('Create account'),
            ),
            const SizedBox(height: 12),
            PlinthGroup(
              mainAxisAlignment: MainAxisAlignment.center,
              gap: PlinthSize.xs,
              children: [
                const PlinthText('Already have an account?',
                    size: PlinthSize.sm, color: 'gray'),
                PlinthAnchor('Sign in', size: PlinthSize.sm, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Application UI: Stats ───────────────────────────

class StatTileRowExample extends StatelessWidget {
  const StatTileRowExample({super.key});

  static const _stats = [
    (label: 'Revenue', value: r'$13,456', delta: '+12.4%', up: true),
    (label: 'Active users', value: '2,340', delta: '+3.1%', up: true),
    (label: 'Churn', value: '1.8%', delta: '-0.4%', up: false),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlinthSimpleGrid(
        columns: 3,
        children: [
          for (final stat in _stats)
            PlinthPaper(
              withBorder: true,
              p: PlinthSize.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlinthText(
                    stat.label.toUpperCase(),
                    size: PlinthSize.xs,
                    color: 'gray',
                    weight: FontWeight.w700,
                  ),
                  const SizedBox(height: 8),
                  PlinthTitle(stat.value, order: 3),
                  const SizedBox(height: 8),
                  PlinthGroup(
                    gap: PlinthSize.xs,
                    children: [
                      Icon(
                        stat.up ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color:
                            context.plinth.color(stat.up ? 'green' : 'red', 6),
                      ),
                      PlinthText(
                        stat.delta,
                        size: PlinthSize.xs,
                        color: stat.up ? 'green' : 'red',
                        weight: FontWeight.w600,
                      ),
                      const PlinthText('vs last month',
                          size: PlinthSize.xs, color: 'gray'),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class StatWithProgressExample extends StatelessWidget {
  const StatWithProgressExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlinthText('Storage used', weight: FontWeight.w600),
                PlinthBadge('Pro', color: 'grape'),
              ],
            ),
            const SizedBox(height: 4),
            const PlinthText('68 GB of 100 GB',
                size: PlinthSize.sm, color: 'gray'),
            const SizedBox(height: 16),
            const PlinthProgress(value: 0.68),
            const SizedBox(height: 12),
            PlinthAnchor('Manage plan', size: PlinthSize.sm, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── Page Sections: Error pages ───────────────────────

class NotFoundPageExample extends StatelessWidget {
  const NotFoundPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: PlinthCenter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PlinthTitle('404', color: 'gray'),
            const SizedBox(height: 8),
            const PlinthTitle('Nothing to see here', order: 3),
            const SizedBox(height: 8),
            const PlinthText(
              'The page you are looking for was moved, removed, or never '
              'existed in the first place.',
              size: PlinthSize.sm,
              color: 'gray',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PlinthGroup(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlinthButton(
                  variant: PlinthVariant.defaultVariant,
                  onPressed: () {},
                  child: const Text('Go back'),
                ),
                PlinthButton(
                  onPressed: () {},
                  child: const Text('Take me home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ServerErrorPageExample extends StatelessWidget {
  const ServerErrorPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: PlinthCenter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PlinthThemeIcon(
              icon: Icon(Icons.cloud_off),
              variant: PlinthVariant.light,
              color: 'red',
              size: PlinthSize.xl,
            ),
            const SizedBox(height: 16),
            const PlinthTitle('Something went wrong', order: 3),
            const SizedBox(height: 8),
            const PlinthText(
              'Our servers could not handle that request. We have been '
              'notified and are looking into it.',
              size: PlinthSize.sm,
              color: 'gray',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const PlinthCode('request_id: 7f3c9a21'),
            const SizedBox(height: 20),
            PlinthButton(onPressed: () {}, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────── Application UI: Footers ──────────────────────────

class SimpleFooterExample extends StatelessWidget {
  const SimpleFooterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: Row(
          children: [
            const PlinthText('Acme', weight: FontWeight.w700),
            const SizedBox(width: 12),
            const PlinthText('© 2026', size: PlinthSize.xs, color: 'gray'),
            const Spacer(),
            PlinthGroup(
              gap: PlinthSize.md,
              children: [
                PlinthAnchor('Privacy', size: PlinthSize.sm, onTap: () {}),
                PlinthAnchor('Terms', size: PlinthSize.sm, onTap: () {}),
                PlinthAnchor('Contact', size: PlinthSize.sm, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FooterWithLinkColumnsExample extends StatelessWidget {
  const FooterWithLinkColumnsExample({super.key});

  static const _columns = [
    (title: 'Product', links: ['Features', 'Pricing', 'Changelog']),
    (title: 'Company', links: ['About', 'Careers', 'Blog']),
    (title: 'Support', links: ['Docs', 'Status', 'Contact']),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlinthSimpleGrid(
              columns: 3,
              children: [
                for (final column in _columns)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlinthText(column.title, weight: FontWeight.w600),
                      const SizedBox(height: 8),
                      for (final link in column.links)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: PlinthAnchor(link,
                              size: PlinthSize.sm, onTap: () {}),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const PlinthDivider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const PlinthText('© 2026 Acme, Inc.',
                    size: PlinthSize.xs, color: 'gray'),
                PlinthGroup(
                  gap: PlinthSize.xs,
                  children: [
                    PlinthActionIcon(
                      semanticLabel: 'Show code',
                      icon: const Icon(Icons.code, size: 16),
                      onPressed: () {},
                      variant: PlinthVariant.subtle,
                    ),
                    PlinthActionIcon(
                      semanticLabel: 'Subscribe',
                      icon: const Icon(Icons.rss_feed, size: 16),
                      onPressed: () {},
                      variant: PlinthVariant.subtle,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────── Page Sections: Frequently asked questions ────────────────────

class FaqAccordionExample extends StatelessWidget {
  const FaqAccordionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthTitle('Frequently asked questions', order: 3),
          SizedBox(height: 20),
          PlinthAccordion(
            items: [
              PlinthAccordionItem(
                value: 'billing',
                title: 'When am I billed?',
                content: PlinthText(
                  'On the same day each month, starting the day you '
                  'upgrade. Downgrades take effect at the end of the '
                  'current period.',
                  size: PlinthSize.sm,
                ),
              ),
              PlinthAccordionItem(
                value: 'cancel',
                title: 'Can I cancel at any time?',
                content: PlinthText(
                  'Yes. Your plan stays active until the end of the '
                  'period you have already paid for.',
                  size: PlinthSize.sm,
                ),
              ),
              PlinthAccordionItem(
                value: 'refund',
                title: 'Do you offer refunds?',
                content: PlinthText(
                  'Within 30 days of purchase, no questions asked.',
                  size: PlinthSize.sm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FaqWithContactExample extends StatelessWidget {
  const FaqWithContactExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlinthGrid(
        children: [
          PlinthGridCol(
            span: 12,
            spanMd: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PlinthTitle('Still deciding?', order: 4),
                const SizedBox(height: 8),
                const PlinthText(
                  'The answers most people need are on the right. If '
                  'yours is not, we read every message.',
                  size: PlinthSize.sm,
                  color: 'gray',
                ),
                const SizedBox(height: 16),
                PlinthButton(
                  variant: PlinthVariant.light,
                  leadingIcon: const Icon(Icons.mail_outline, size: 16),
                  onPressed: () {},
                  child: const Text('Contact support'),
                ),
              ],
            ),
          ),
          const PlinthGridCol(
            span: 12,
            spanMd: 7,
            child: PlinthAccordion(
              items: [
                PlinthAccordionItem(
                  value: 'trial',
                  title: 'Is there a free trial?',
                  content: PlinthText(
                    '14 days, no card required.',
                    size: PlinthSize.sm,
                  ),
                ),
                PlinthAccordionItem(
                  value: 'seats',
                  title: 'Can I add seats later?',
                  content: PlinthText(
                    'At any time — you are billed the prorated '
                    'difference.',
                    size: PlinthSize.sm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────── Application UI: User info and controls ────────────────

class UserButtonExample extends StatelessWidget {
  const UserButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.sm,
        child: Row(
          children: [
            const PlinthAvatar(initials: 'YL'),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlinthText('Yair Lahav', weight: FontWeight.w600),
                  PlinthText(
                    'yair@example.com',
                    size: PlinthSize.xs,
                    color: 'gray',
                  ),
                ],
              ),
            ),
            PlinthActionIcon(
              semanticLabel: 'Expand',
              icon: const Icon(Icons.unfold_more, size: 16),
              variant: PlinthVariant.subtle,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfileCardExample extends StatelessWidget {
  const UserProfileCardExample({super.key});

  static const _stats = [
    (label: 'Posts', value: '128'),
    (label: 'Followers', value: '2.4k'),
    (label: 'Following', value: '312'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: PlinthCard(
        withBorder: true,
        child: Column(
          children: [
            const PlinthAvatar(initials: 'YL', size: PlinthSize.xl),
            const SizedBox(height: 12),
            const PlinthTitle('Yair Lahav', order: 4),
            const SizedBox(height: 4),
            const PlinthBadge('Maintainer', color: 'grape'),
            const SizedBox(height: 16),
            Row(
              children: [
                // Expanded rather than spaceEvenly: three fixed-width
                // columns overflow a narrow card once the labels grow
                // or the text scale does.
                for (final stat in _stats)
                  Expanded(
                    child: Column(
                      children: [
                        PlinthText(stat.value, weight: FontWeight.w700),
                        PlinthText(
                          stat.label,
                          size: PlinthSize.xs,
                          color: 'gray',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            PlinthButton(
              fullWidth: true,
              variant: PlinthVariant.light,
              onPressed: () {},
              child: const Text('Follow'),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────── Application UI: Application cards ────────────────────

class ProjectCardExample extends StatelessWidget {
  const ProjectCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 320,
      child: PlinthCard(
        withBorder: true,
        header: Row(
          children: [
            PlinthThemeIcon(
              icon: Icon(Icons.rocket_launch_outlined),
              variant: PlinthVariant.light,
              color: 'grape',
            ),
            SizedBox(width: 12),
            Expanded(
                child: PlinthText('Launch checklist', weight: FontWeight.w600)),
            PlinthBadge('Active', color: 'green'),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlinthText(
              'Everything that has to land before the public beta.',
              size: PlinthSize.sm,
              color: 'gray',
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlinthText('12 of 18 done', size: PlinthSize.xs),
                PlinthText('67%', size: PlinthSize.xs, color: 'gray'),
              ],
            ),
            SizedBox(height: 6),
            PlinthProgress(value: 0.67, color: 'grape'),
          ],
        ),
      ),
    );
  }
}

class TaskCardExample extends StatelessWidget {
  const TaskCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 300,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: PlinthText(
                    'Regenerate goldens on Linux',
                    weight: FontWeight.w600,
                  ),
                ),
                PlinthBadge('High', color: 'red'),
              ],
            ),
            SizedBox(height: 8),
            PlinthText(
              'CI renders differently to a dev machine, so the '
              'reference images have to come from CI.',
              size: PlinthSize.xs,
              color: 'gray',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                PlinthAvatar(initials: 'YL', size: PlinthSize.sm),
                SizedBox(width: 6),
                PlinthAvatar(initials: 'AB', size: PlinthSize.sm),
                Spacer(),
                PlinthGroup(
                  gap: PlinthSize.xs,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 14),
                    PlinthText('4', size: PlinthSize.xs, color: 'gray'),
                    SizedBox(width: 4),
                    Icon(Icons.attach_file, size: 14),
                    PlinthText('2', size: PlinthSize.xs, color: 'gray'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Blog UI: Comments ───────────────────────────

class SingleCommentExample extends StatelessWidget {
  const SingleCommentExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const PlinthAvatar(initials: 'AB', size: PlinthSize.sm),
                const SizedBox(width: 8),
                const PlinthText('Ada Byron',
                    weight: FontWeight.w600, size: PlinthSize.sm),
                const SizedBox(width: 8),
                const PlinthText('2 hours ago',
                    size: PlinthSize.xs, color: 'gray'),
                const Spacer(),
                PlinthActionIcon(
                  semanticLabel: 'More actions',
                  icon: const Icon(Icons.more_horiz, size: 16),
                  variant: PlinthVariant.subtle,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            const PlinthText(
              'The contrast work is the part I would have missed — a '
              'colour being visible is not the same as it being '
              'readable.',
              size: PlinthSize.sm,
            ),
          ],
        ),
      ),
    );
  }
}

class CommentThreadExample extends StatelessWidget {
  const CommentThreadExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ThreadComment(
            initials: 'AB',
            name: 'Ada Byron',
            when: '2 hours ago',
            body: 'Does the shade mirroring apply to custom palettes too, '
                'or only the built-in ramps?',
          ),
          Padding(
            // Indent marks the reply as a reply — the whole reason a
            // thread reads differently to a list.
            padding: const EdgeInsets.only(left: 32, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ThreadComment(
                  initials: 'YL',
                  name: 'Yair Lahav',
                  when: '1 hour ago',
                  body: 'Any ramp registered on the theme — mirroring is '
                      'by shade index, not by colour name.',
                ),
                const SizedBox(height: 12),
                PlinthAnchor('Reply', size: PlinthSize.xs, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadComment extends StatelessWidget {
  const _ThreadComment({
    required this.initials,
    required this.name,
    required this.when,
    required this.body,
  });

  final String initials;
  final String name;
  final String when;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlinthAvatar(initials: initials, size: PlinthSize.sm),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PlinthText(name,
                      weight: FontWeight.w600, size: PlinthSize.sm),
                  const SizedBox(width: 8),
                  PlinthText(when, size: PlinthSize.xs, color: 'gray'),
                ],
              ),
              const SizedBox(height: 4),
              PlinthText(body, size: PlinthSize.sm),
            ],
          ),
        ),
      ],
    );
  }
}

// ────────────────────────── Page Sections: Banners ──────────────────────────

class AnnouncementBannerExample extends StatelessWidget {
  const AnnouncementBannerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlinthAlert(
        color: 'grape',
        icon: const Icon(Icons.campaign_outlined),
        onClose: () {},
        title: 'Plinth UI 0.9.0 is out',
        child: PlinthGroup(
          gap: PlinthSize.sm,
          children: [
            const PlinthText(
              'Dark mode, contrast-aware colours, and three new form '
              'components.',
              size: PlinthSize.sm,
            ),
            PlinthAnchor('Read the changelog',
                size: PlinthSize.sm, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class ConsentBannerExample extends StatelessWidget {
  const ConsentBannerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlinthPaper(
        withBorder: true,
        shadow: PlinthShadow.md,
        p: PlinthSize.md,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: PlinthText(
                'We use a single cookie to remember your theme. Nothing '
                'is shared with anyone.',
                size: PlinthSize.sm,
              ),
            ),
            const SizedBox(width: 16),
            PlinthGroup(
              gap: PlinthSize.xs,
              wrap: false,
              children: [
                PlinthButton(
                  variant: PlinthVariant.subtle,
                  size: PlinthSize.sm,
                  onPressed: () {},
                  child: const Text('Decline'),
                ),
                PlinthButton(
                  size: PlinthSize.sm,
                  onPressed: () {},
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Application UI: Tables ───────────────────────────

class MemberTableExample extends StatelessWidget {
  const MemberTableExample({super.key});

  static const _members = [
    (
      initials: 'AB',
      name: 'Ada Byron',
      email: 'ada@example.com',
      role: 'Maintainer',
      status: 'Active',
      tone: 'green',
    ),
    (
      initials: 'GH',
      name: 'Grace Hopper',
      email: 'grace@example.com',
      role: 'Reviewer',
      status: 'Invited',
      tone: 'gray',
    ),
    (
      initials: 'AT',
      name: 'Alan Turing',
      email: 'alan@example.com',
      role: 'Contributor',
      status: 'Blocked',
      tone: 'red',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.xs,
        // Widget cells are what makes this a table rather than a grid
        // of strings: the member column pairs an avatar with two lines,
        // and the status column carries a badge.
        child: PlinthTable(
          columns: const ['Member', 'Role', 'Status', ''],
          rows: [
            for (final member in _members)
              [
                Row(
                  children: [
                    PlinthAvatar(
                        initials: member.initials, size: PlinthSize.sm),
                    const SizedBox(width: 8),
                    // Expanded because a table cell has a bounded
                    // width: an unflexed Row of an avatar plus two
                    // lines overflows as soon as a name is long.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PlinthText(
                            member.name,
                            size: PlinthSize.sm,
                            weight: FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          PlinthText(
                            member.email,
                            size: PlinthSize.xs,
                            color: 'gray',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                PlinthText(member.role, size: PlinthSize.sm),
                PlinthBadge(member.status, color: member.tone),
                PlinthActionIcon(
                  semanticLabel: 'More actions',
                  icon: const Icon(Icons.more_horiz, size: 16),
                  variant: PlinthVariant.subtle,
                  onPressed: () {},
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class InvoiceTableExample extends StatelessWidget {
  const InvoiceTableExample({super.key});

  static const _invoices = [
    (id: 'INV-014', due: 'Due in 6 days', amount: r'$1,240.00', paid: false),
    (id: 'INV-013', due: 'Paid 2 Aug', amount: r'$980.00', paid: true),
    (id: 'INV-012', due: 'Paid 2 Jul', amount: r'$980.00', paid: true),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.xs,
        child: PlinthTable(
          striped: true,
          columns: const ['Invoice', 'Amount', 'Status'],
          rows: [
            for (final invoice in _invoices)
              [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlinthText(invoice.id,
                        size: PlinthSize.sm, weight: FontWeight.w600),
                    PlinthText(invoice.due, size: PlinthSize.xs, color: 'gray'),
                  ],
                ),
                PlinthText(invoice.amount, size: PlinthSize.sm),
                invoice.paid
                    ? const PlinthBadge('Paid', color: 'green')
                    : PlinthButton(
                        size: PlinthSize.xs,
                        onPressed: () {},
                        child: const Text('Pay now'),
                      ),
              ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Application UI: Inputs ───────────────────────────

class SearchBarExample extends StatefulWidget {
  const SearchBarExample({super.key});

  @override
  State<SearchBarExample> createState() => _SearchBarExampleState();
}

class _SearchBarExampleState extends State<SearchBarExample> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: PlinthAutocomplete(
              placeholder: 'Search components…',
              value: _query,
              onChanged: (v) => setState(() => _query = v),
              options: const [
                'PlinthButton',
                'PlinthTextInput',
                'PlinthTable',
                'PlinthAutocomplete',
                'PlinthTagsInput',
              ],
            ),
          ),
          const SizedBox(width: 8),
          PlinthButton(
            leadingIcon: const Icon(Icons.search, size: 16),
            onPressed: () {},
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

class FilterFieldsExample extends StatefulWidget {
  const FilterFieldsExample({super.key});

  @override
  State<FilterFieldsExample> createState() => _FilterFieldsExampleState();
}

class _FilterFieldsExampleState extends State<FilterFieldsExample> {
  List<String> _tags = ['flutter'];
  String? _status = 'open';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlinthText('Filters', weight: FontWeight.w600),
            const SizedBox(height: 12),
            PlinthGrid(
              gutter: PlinthSize.sm,
              children: [
                PlinthGridCol(
                  span: 12,
                  spanMd: 6,
                  child: PlinthSelect<String>(
                    label: 'Status',
                    value: _status,
                    onChanged: (v) => setState(() => _status = v),
                    options: const [
                      PlinthSelectOption('open', 'Open'),
                      PlinthSelectOption('closed', 'Closed'),
                    ],
                  ),
                ),
                PlinthGridCol(
                  span: 12,
                  spanMd: 6,
                  child: PlinthTagsInput(
                    label: 'Labels',
                    placeholder: 'Add a label',
                    value: _tags,
                    onChanged: (t) => setState(() => _tags = t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PlinthGroup(
              mainAxisAlignment: MainAxisAlignment.end,
              gap: PlinthSize.xs,
              children: [
                PlinthButton(
                  variant: PlinthVariant.subtle,
                  onPressed: () {},
                  child: const Text('Reset'),
                ),
                PlinthButton(onPressed: () {}, child: const Text('Apply')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Application UI: Buttons ───────────────────────────

class ToolbarActionsExample extends StatelessWidget {
  const ToolbarActionsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.sm,
        child: Row(
          children: [
            PlinthButtonGroup(
              children: [
                PlinthButton(
                  variant: PlinthVariant.defaultVariant,
                  size: PlinthSize.sm,
                  leadingIcon: const Icon(Icons.format_bold, size: 14),
                  onPressed: () {},
                  child: const Text('Bold'),
                ),
                PlinthButton(
                  variant: PlinthVariant.defaultVariant,
                  size: PlinthSize.sm,
                  leadingIcon: const Icon(Icons.format_italic, size: 14),
                  onPressed: () {},
                  child: const Text('Italic'),
                ),
              ],
            ),
            const Spacer(),
            PlinthGroup(
              gap: PlinthSize.xs,
              wrap: false,
              children: [
                PlinthActionIcon(
                  semanticLabel: 'Undo',
                  icon: const Icon(Icons.undo, size: 16),
                  variant: PlinthVariant.subtle,
                  onPressed: () {},
                ),
                const PlinthActionIcon(
                  semanticLabel: 'Redo',
                  icon: Icon(Icons.redo, size: 16),
                  variant: PlinthVariant.subtle,
                  onPressed: null,
                ),
                PlinthButton(
                  size: PlinthSize.sm,
                  onPressed: () {},
                  child: const Text('Publish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DestructiveActionsExample extends StatelessWidget {
  const DestructiveActionsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlinthCard(
        withBorder: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlinthTitle('Delete workspace', order: 5),
            const SizedBox(height: 6),
            const PlinthText(
              'Every project, member, and invoice goes with it. This '
              'cannot be undone.',
              size: PlinthSize.sm,
              color: 'gray',
            ),
            const SizedBox(height: 16),
            PlinthGroup(
              mainAxisAlignment: MainAxisAlignment.end,
              gap: PlinthSize.xs,
              children: [
                PlinthButton(
                  variant: PlinthVariant.defaultVariant,
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
                PlinthButton(
                  color: 'red',
                  leadingIcon: const Icon(Icons.delete_outline, size: 16),
                  onPressed: () {},
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Application UI: Sliders ───────────────────────────

class PriceRangeFilterExample extends StatefulWidget {
  const PriceRangeFilterExample({super.key});

  @override
  State<PriceRangeFilterExample> createState() =>
      _PriceRangeFilterExampleState();
}

class _PriceRangeFilterExampleState extends State<PriceRangeFilterExample> {
  RangeValues _range = const RangeValues(20, 80);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: PlinthText('Price range', weight: FontWeight.w600),
                ),
                PlinthText(
                  '\$${_range.start.round()} – \$${_range.end.round()}',
                  size: PlinthSize.sm,
                  color: 'gray',
                ),
              ],
            ),
            const SizedBox(height: 8),
            PlinthRangeSlider(
              values: _range,
              divisions: 20,
              onChanged: (v) => setState(() => _range = v),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingSlidersExample extends StatefulWidget {
  const SettingSlidersExample({super.key});

  @override
  State<SettingSlidersExample> createState() => _SettingSlidersExampleState();
}

class _SettingSlidersExampleState extends State<SettingSlidersExample> {
  double _volume = 65;
  double _brightness = 40;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        children: [
          _SliderRow(
            icon: Icons.volume_up_outlined,
            label: 'Volume',
            value: _volume,
            onChanged: (v) => setState(() => _volume = v),
          ),
          const SizedBox(height: 8),
          _SliderRow(
            icon: Icons.brightness_6_outlined,
            label: 'Brightness',
            value: _brightness,
            onChanged: (v) => setState(() => _brightness = v),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 12),
        // A fixed label column keeps the two sliders aligned with each
        // other rather than each starting wherever its label ends.
        SizedBox(
          width: 80,
          child: PlinthText(label, size: PlinthSize.sm),
        ),
        Expanded(
          child: PlinthSlider(value: value, onChanged: onChanged),
        ),
        SizedBox(
          width: 36,
          child: PlinthText(
            '${value.round()}',
            size: PlinthSize.xs,
            color: 'gray',
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Application UI: Grids ───────────────────────────

class DashboardGridExample extends StatelessWidget {
  const DashboardGridExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 560,
      child: PlinthGrid(
        children: [
          PlinthGridCol(
            span: 12,
            spanMd: 8,
            child: _GridPanel(title: 'Traffic', height: 120),
          ),
          PlinthGridCol(
            span: 12,
            spanMd: 4,
            child: _GridPanel(title: 'Conversion', height: 120),
          ),
          PlinthGridCol(
            span: 12,
            spanMd: 4,
            child: _GridPanel(title: 'Signups', height: 90),
          ),
          PlinthGridCol(
            span: 12,
            spanMd: 4,
            child: _GridPanel(title: 'Churn', height: 90),
          ),
          PlinthGridCol(
            span: 12,
            spanMd: 4,
            child: _GridPanel(title: 'Revenue', height: 90),
          ),
        ],
      ),
    );
  }
}

class _GridPanel extends StatelessWidget {
  const _GridPanel({required this.title, required this.height});

  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      withBorder: true,
      p: PlinthSize.sm,
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlinthText(title, size: PlinthSize.sm, weight: FontWeight.w600),
            const Spacer(),
            const PlinthSkeleton(height: 10),
            const SizedBox(height: 6),
            const PlinthSkeleton(height: 10, width: 120),
          ],
        ),
      ),
    );
  }
}

class CardGalleryGridExample extends StatelessWidget {
  const CardGalleryGridExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlinthGrid(
        children: [
          for (final item in const [
            (title: 'Starter', price: r'$0', tone: 'gray'),
            (title: 'Pro', price: r'$29', tone: 'blue'),
            (title: 'Team', price: r'$99', tone: 'grape'),
          ])
            PlinthGridCol(
              span: 12,
              spanSm: 4,
              child: PlinthCard(
                withBorder: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlinthBadge(item.title, color: item.tone),
                    const SizedBox(height: 8),
                    PlinthTitle(item.price, order: 3),
                    const SizedBox(height: 4),
                    const PlinthText('per month',
                        size: PlinthSize.xs, color: 'gray'),
                    const SizedBox(height: 12),
                    PlinthButton(
                      fullWidth: true,
                      variant: PlinthVariant.light,
                      color: item.tone,
                      onPressed: () {},
                      child: const Text('Choose'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ────────────────────── Page Sections: Contact us ──────────────────────

class ContactFormExample extends StatelessWidget {
  const ContactFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlinthCard(
        withBorder: true,
        p: PlinthSize.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PlinthTitle('Get in touch', order: 3),
            const SizedBox(height: 4),
            const PlinthText(
              'We usually reply within a working day.',
              size: PlinthSize.sm,
              color: 'gray',
            ),
            const SizedBox(height: 20),
            PlinthTextInput(label: 'Name', onChanged: (_) {}),
            const SizedBox(height: 12),
            PlinthTextInput(
              label: 'Email',
              placeholder: 'you@example.com',
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            PlinthTextarea(
              label: 'Message',
              placeholder: 'How can we help?',
              onChanged: (_) {},
            ),
            const SizedBox(height: 20),
            PlinthButton(
              fullWidth: true,
              onPressed: () {},
              child: const Text('Send message'),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactWithDetailsExample extends StatelessWidget {
  const ContactWithDetailsExample({super.key});

  static const _details = [
    (Icons.mail_outline, 'Email', 'support@example.com'),
    (Icons.phone_outlined, 'Phone', '+1 (555) 010-4477'),
    (Icons.schedule_outlined, 'Hours', 'Mon–Fri, 9–5 UTC'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlinthGrid(
        children: [
          PlinthGridCol(
            span: 12,
            spanMd: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PlinthTitle('Contact us', order: 4),
                const SizedBox(height: 16),
                for (final (icon, label, value) in _details)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        PlinthThemeIcon(
                          icon: Icon(icon),
                          variant: PlinthVariant.light,
                          size: PlinthSize.sm,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PlinthText(label,
                                  size: PlinthSize.xs, color: 'gray'),
                              PlinthText(
                                value,
                                size: PlinthSize.sm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          PlinthGridCol(
            span: 12,
            spanMd: 7,
            child: PlinthPaper(
              withBorder: true,
              p: PlinthSize.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PlinthTextInput(
                    label: 'Email',
                    placeholder: 'you@example.com',
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                  PlinthTextarea(
                    label: 'Message',
                    minLines: 2,
                    maxLines: 4,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  PlinthButton(
                    fullWidth: true,
                    onPressed: () {},
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Application UI: Dropzones ─────────────────────────

class FileDropzoneExample extends StatefulWidget {
  const FileDropzoneExample({super.key});

  @override
  State<FileDropzoneExample> createState() => _FileDropzoneExampleState();
}

class _FileDropzoneExampleState extends State<FileDropzoneExample> {
  List<String> _files = [];

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: PlinthStack(
        gap: PlinthSize.sm,
        children: [
          const PlinthTitle('Attachments', order: 4),
          PlinthFileInput<String>(
            label: 'Documents',
            description: 'PDF or PNG, up to 5 MB each',
            multiple: true,
            value: _files,
            // A real app opens file_picker here; the showcase stands
            // one in so the block is runnable on its own.
            onPick: () async => ['contract-${_files.length + 1}.pdf'],
            onChanged: (files) => setState(() => _files = files),
            labelBuilder: (file) => file,
          ),
        ],
      ),
    );
  }
}

class AvatarUploadExample extends StatefulWidget {
  const AvatarUploadExample({super.key});

  @override
  State<AvatarUploadExample> createState() => _AvatarUploadExampleState();
}

class _AvatarUploadExampleState extends State<AvatarUploadExample> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: PlinthGroup(
        gap: PlinthSize.md,
        children: [
          PlinthAvatar(
              initials: _picked == null ? 'AN' : 'OK', size: PlinthSize.xl),
          PlinthStack(
            gap: PlinthSize.xs,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PlinthText('Profile photo', weight: FontWeight.w600),
              PlinthText(
                _picked ?? 'PNG or JPG, square works best',
                size: PlinthSize.xs,
                color: 'gray',
              ),
              PlinthGroup(
                gap: PlinthSize.xs,
                children: [
                  PlinthFileButton<String>(
                    size: PlinthSize.sm,
                    variant: PlinthVariant.outline,
                    onPick: () async => ['avatar.png'],
                    onChanged: (f) => setState(() => _picked = f.first),
                    child: const Text('Upload'),
                  ),
                  if (_picked != null)
                    PlinthButton(
                      size: PlinthSize.sm,
                      variant: PlinthVariant.subtle,
                      color: 'red',
                      onPressed: () => setState(() => _picked = null),
                      child: const Text('Remove'),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────── Application UI: Drag'n'Drop ────────────────────────

class ReorderableListExample extends StatefulWidget {
  const ReorderableListExample({super.key});

  @override
  State<ReorderableListExample> createState() => _ReorderableListExampleState();
}

class _ReorderableListExampleState extends State<ReorderableListExample> {
  final List<String> _items = ['Draft the brief', 'Review copy', 'Ship it'];

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: PlinthStack(
        gap: PlinthSize.sm,
        children: [
          const PlinthTitle('Backlog', order: 4),
          // Flutter's own ReorderableListView rather than a Plinth
          // component: drag-to-reorder is exactly the kind of thing
          // not worth re-deriving, and it takes Plinth children fine.
          SizedBox(
            height: 160,
            child: ReorderableListView(
              buildDefaultDragHandles: true,
              // onReorderItem rather than onReorder: it hands back an
              // index already adjusted for the removed item, so the
              // usual `if (newIndex > oldIndex) newIndex -= 1` dance
              // that everyone gets wrong once isn't needed.
              onReorderItem: (oldIndex, newIndex) => setState(
                () => _items.insert(newIndex, _items.removeAt(oldIndex)),
              ),
              children: [
                for (final item in _items)
                  Padding(
                    key: ValueKey(item),
                    padding: const EdgeInsets.only(bottom: 6),
                    child: PlinthPaper(
                      p: PlinthSize.sm,
                      withBorder: true,
                      child: PlinthGroup(
                        children: [
                          const Icon(Icons.drag_indicator, size: 18),
                          PlinthText(item),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KanbanDropExample extends StatefulWidget {
  const KanbanDropExample({super.key});

  @override
  State<KanbanDropExample> createState() => _KanbanDropExampleState();
}

class _KanbanDropExampleState extends State<KanbanDropExample> {
  final Map<String, List<String>> _columns = {
    'To do': ['Write tests'],
    'Done': ['Set up CI'],
  };

  void _move(String card, String from, String to) {
    if (from == to) return;
    setState(() {
      _columns[from]!.remove(card);
      _columns[to]!.add(card);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlinthGroup(
      gap: PlinthSize.sm,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final column in _columns.keys)
          SizedBox(
            width: 180,
            child: DragTarget<({String card, String from})>(
              onAcceptWithDetails: (details) =>
                  _move(details.data.card, details.data.from, column),
              builder: (context, candidate, rejected) => PlinthPaper(
                p: PlinthSize.sm,
                withBorder: true,
                child: PlinthStack(
                  gap: PlinthSize.xs,
                  children: [
                    PlinthText(
                      column,
                      size: PlinthSize.sm,
                      weight: FontWeight.w700,
                      // Highlighting the target is the whole feedback
                      // loop of a drag — without it you are guessing.
                      color: candidate.isEmpty ? 'gray' : 'blue',
                    ),
                    for (final card in _columns[column]!)
                      Draggable<({String card, String from})>(
                        data: (card: card, from: column),
                        feedback: PlinthBadge(card, color: 'blue'),
                        childWhenDragging: const SizedBox.shrink(),
                        child: PlinthPaper(
                          p: PlinthSize.xs,
                          withBorder: true,
                          child: PlinthText(card, size: PlinthSize.sm),
                        ),
                      ),
                    if (_columns[column]!.isEmpty)
                      const PlinthText('Drop here',
                          size: PlinthSize.xs, color: 'gray'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ────────────────────────── Blog UI: Table of Contents ──────────────────────────

class ArticleContentsExample extends StatefulWidget {
  const ArticleContentsExample({super.key});

  @override
  State<ArticleContentsExample> createState() => _ArticleContentsExampleState();
}

class _ArticleContentsExampleState extends State<ArticleContentsExample> {
  int _active = 0;

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: SizedBox(
        width: 240,
        child: PlinthStack(
          gap: PlinthSize.sm,
          children: [
            const PlinthText('On this page',
                size: PlinthSize.xs, weight: FontWeight.w700),
            PlinthTableOfContents(
              activeIndex: _active,
              onSelected: (i) => setState(() => _active = i),
              items: const [
                PlinthTocItem(label: 'Introduction'),
                PlinthTocItem(label: 'Installing', order: 2),
                PlinthTocItem(label: 'From pub.dev', order: 3),
                PlinthTocItem(label: 'Theming', order: 2),
                PlinthTocItem(label: 'Dark mode', order: 3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleWithContentsRailExample extends StatefulWidget {
  const ArticleWithContentsRailExample({super.key});

  @override
  State<ArticleWithContentsRailExample> createState() =>
      _ArticleWithContentsRailExampleState();
}

class _ArticleWithContentsRailExampleState
    extends State<ArticleWithContentsRailExample> {
  final _sections = ['Introduction', 'Installing', 'Theming'];
  final _keys = [GlobalKey(), GlobalKey(), GlobalKey()];
  final _scroll = ScrollController();
  int _active = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: PlinthGroup(
        gap: PlinthSize.md,
        wrap: false,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: PlinthTableOfContents(
              activeIndex: _active,
              onSelected: (i) => setState(() => _active = i),
              items: [
                for (var i = 0; i < _sections.length; i++)
                  PlinthTocItem(label: _sections[i], targetKey: _keys[i]),
              ],
            ),
          ),
          Expanded(
            // A SingleChildScrollView rather than a ListView: the
            // rail scrolls to a heading via ensureVisible, which needs
            // the target already built.
            child: SingleChildScrollView(
              controller: _scroll,
              child: PlinthStack(
                gap: PlinthSize.md,
                children: [
                  for (var i = 0; i < _sections.length; i++)
                    PlinthStack(
                      gap: PlinthSize.xs,
                      children: [
                        PlinthTitle(_sections[i], key: _keys[i], order: 4),
                        const PlinthText(
                          'Body copy for this section, long enough that '
                          'the rail has somewhere to scroll to.',
                          size: PlinthSize.sm,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── Blocks built on the newer components ─────────────────────

class LiveMetricsExample extends StatefulWidget {
  const LiveMetricsExample({super.key});

  @override
  State<LiveMetricsExample> createState() => _LiveMetricsExampleState();
}

class _LiveMetricsExampleState extends State<LiveMetricsExample> {
  num _revenue = 48210;
  static const double _capacity = 0.62;

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: PlinthGroup(
        gap: PlinthSize.xl,
        children: [
          PlinthStack(
            gap: PlinthSize.xs,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PlinthText('Revenue', size: PlinthSize.xs, color: 'gray'),
              PlinthRollingNumber(
                value: _revenue,
                prefix: r'$',
                size: PlinthSize.xl,
                weight: FontWeight.w700,
              ),
              PlinthButton(
                size: PlinthSize.xs,
                variant: PlinthVariant.subtle,
                onPressed: () => setState(() => _revenue += 1372),
                child: const Text('Simulate sale'),
              ),
            ],
          ),
          PlinthStack(
            gap: PlinthSize.xs,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PlinthText('Capacity', size: PlinthSize.xs, color: 'gray'),
              PlinthSemiCircleProgress(
                value: _capacity,
                diameter: 120,
                label: PlinthText(
                  '${(_capacity * 100).round()}%',
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SortableTableExample extends StatefulWidget {
  const SortableTableExample({super.key});

  @override
  State<SortableTableExample> createState() => _SortableTableExampleState();
}

class _SortableTableExampleState extends State<SortableTableExample> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: PlinthStack(
        gap: PlinthSize.sm,
        children: [
          PlinthTextInput(
            placeholder: 'Filter members…',
            leadingIcon: const Icon(Icons.search, size: 18),
            onChanged: (v) => setState(() => _query = v),
          ),
          PlinthTable.text(
            columns: const ['Name', 'Role', 'Commits'],
            // Sortable and filterable because the values are strings —
            // a widget-cell table would need sortValues alongside.
            sortable: true,
            filter: _query,
            striped: true,
            emptyState: const PlinthEmptyState(
              title: 'No members match',
              description: 'Try a shorter search.',
            ),
            rows: const [
              ['Carol', 'Engineer', '9'],
              ['Alice', 'Designer', '124'],
              ['Bob', 'Engineer', '31'],
            ],
          ),
        ],
      ),
    );
  }
}

class FormattedFieldsExample extends StatefulWidget {
  const FormattedFieldsExample({super.key});

  @override
  State<FormattedFieldsExample> createState() => _FormattedFieldsExampleState();
}

class _FormattedFieldsExampleState extends State<FormattedFieldsExample> {
  Color _brand = const Color(0xFF2F9E44);

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: PlinthStack(
        gap: PlinthSize.sm,
        children: [
          const PlinthTitle('Workspace settings', order: 4),
          PlinthMaskInput(
            mask: '(###) ###-####',
            label: 'Support line',
            onChanged: (_) {},
          ),
          PlinthColorInput(
            label: 'Brand colour',
            value: _brand,
            onChanged: (c) => setState(() => _brand = c),
            swatches: const [
              Color(0xFF2F9E44),
              Color(0xFF1971C2),
              Color(0xFFE03131),
              Color(0xFF7048E8),
            ],
          ),
          const PlinthJsonInput(
            label: 'Webhook payload',
            description: 'Validated when you click away',
            minLines: 3,
            maxLines: 6,
          ),
        ],
      ),
    );
  }
}

// ───────────────────── Application UI: Navbars (depth) ─────────────────────

class CollapsibleNavbarExample extends StatefulWidget {
  const CollapsibleNavbarExample({super.key});

  @override
  State<CollapsibleNavbarExample> createState() =>
      _CollapsibleNavbarExampleState();
}

class _CollapsibleNavbarExampleState extends State<CollapsibleNavbarExample> {
  bool _collapsed = false;
  String _active = 'home';

  static const _items = [
    (value: 'home', label: 'Home', icon: Icons.home_outlined),
    (value: 'projects', label: 'Projects', icon: Icons.folder_outlined),
    (value: 'team', label: 'Team', icon: Icons.people_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PlinthPaper(
        p: PlinthSize.sm,
        withBorder: true,
        child: SizedBox(
          // The whole point of this variant: the rail changes width
          // rather than disappearing, so the icons stay reachable.
          width: _collapsed ? 64 : 200,
          child: PlinthStack(
            gap: PlinthSize.xs,
            children: [
              PlinthBurger(
                opened: !_collapsed,
                onPressed: () => setState(() => _collapsed = !_collapsed),
              ),
              for (final item in _items)
                PlinthNavLink(
                  label: _collapsed ? '' : item.label,
                  leadingIcon: Icon(item.icon, size: 18),
                  active: _active == item.value,
                  onTap: () => setState(() => _active = item.value),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionedNavbarExample extends StatelessWidget {
  const SectionedNavbarExample({super.key});

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4, left: 8),
        child: PlinthText(
          text.toUpperCase(),
          size: PlinthSize.xs,
          color: 'gray',
          weight: FontWeight.w700,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: PlinthPaper(
        p: PlinthSize.sm,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.xs,
          children: [
            // Headings rather than a tree: these are flat destinations
            // that happen to group, not a hierarchy you navigate into.
            _heading('Workspace'),
            PlinthNavLink(
              label: 'Overview',
              leadingIcon: const Icon(Icons.dashboard_outlined, size: 18),
              active: true,
              onTap: () {},
            ),
            PlinthNavLink(
              label: 'Reports',
              leadingIcon: const Icon(Icons.insights_outlined, size: 18),
              onTap: () {},
            ),
            _heading('Settings'),
            PlinthNavLink(
              label: 'Members',
              leadingIcon: const Icon(Icons.people_outline, size: 18),
              trailing: const PlinthBadge('4'),
              onTap: () {},
            ),
            PlinthNavLink(
              label: 'Billing',
              leadingIcon: const Icon(Icons.credit_card, size: 18),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class NavbarWithSearchExample extends StatelessWidget {
  const NavbarWithSearchExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: Row(
        children: [
          const PlinthText('Acme',
              size: PlinthSize.lg, weight: FontWeight.w700),
          const SizedBox(width: 24),
          // A navbar that carries a control rather than only links —
          // the arrangement most app shells actually need.
          const Expanded(
            child: PlinthTextInput(
              placeholder: 'Search projects…',
              size: PlinthSize.sm,
              leadingIcon: Icon(Icons.search, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          const PlinthKbd('Ctrl'),
          const SizedBox(width: 4),
          const PlinthKbd('K'),
          const SizedBox(width: 16),
          PlinthActionIcon(
            semanticLabel: 'Settings',
            icon: const Icon(Icons.settings_outlined, size: 18),
            variant: PlinthVariant.subtle,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const PlinthAvatar(initials: 'YL', size: PlinthSize.sm),
        ],
      ),
    );
  }
}

// ───────────────────── Application UI: Headers (depth) ─────────────────────

class HeaderWithTabsExample extends StatefulWidget {
  const HeaderWithTabsExample({super.key});

  @override
  State<HeaderWithTabsExample> createState() => _HeaderWithTabsExampleState();
}

class _HeaderWithTabsExampleState extends State<HeaderWithTabsExample> {
  String _tab = 'overview';

  @override
  Widget build(BuildContext context) {
    return PlinthStack(
      gap: PlinthSize.sm,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: PlinthText('Plinth UI',
                  size: PlinthSize.xl, weight: FontWeight.w700),
            ),
            PlinthButton(
              variant: PlinthVariant.outline,
              onPressed: () {},
              child: const Text('Share'),
            ),
          ],
        ),
        // Tabs belong to the header rather than the body: the title
        // stays put while the section below it changes.
        PlinthTabs<String>(
          value: _tab,
          onChanged: (t) => setState(() => _tab = t),
          tabs: const [
            PlinthTabItem('overview', 'Overview'),
            PlinthTabItem('activity', 'Activity'),
            PlinthTabItem('settings', 'Settings'),
          ],
        ),
      ],
    );
  }
}

class HeaderWithFiltersExample extends StatefulWidget {
  const HeaderWithFiltersExample({super.key});

  @override
  State<HeaderWithFiltersExample> createState() =>
      _HeaderWithFiltersExampleState();
}

class _HeaderWithFiltersExampleState extends State<HeaderWithFiltersExample> {
  String _view = 'all';

  @override
  Widget build(BuildContext context) {
    return PlinthStack(
      gap: PlinthSize.sm,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const PlinthText('Issues',
                size: PlinthSize.xl, weight: FontWeight.w700),
            const SizedBox(width: 8),
            const PlinthBadge('128', color: 'gray'),
            const Spacer(),
            PlinthButton(
              onPressed: () {},
              leadingIcon: const Icon(Icons.add, size: 16),
              child: const Text('New issue'),
            ),
          ],
        ),
        PlinthGroup(
          children: [
            PlinthSegmentedControl<String>(
              value: _view,
              onChanged: (v) => setState(() => _view = v),
              items: const [
                PlinthSegmentedControlItem('all', 'All'),
                PlinthSegmentedControlItem('open', 'Open'),
                PlinthSegmentedControlItem('closed', 'Closed'),
              ],
            ),
            const SizedBox(
              width: 220,
              child: PlinthTextInput(
                placeholder: 'Filter…',
                size: PlinthSize.sm,
                leadingIcon: Icon(Icons.filter_list, size: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StickyHeaderExample extends StatelessWidget {
  const StickyHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PlinthPaper(
        // xs rather than the md default: the header and list supply
        // their own padding, and doubling it wastes the panel.
        p: PlinthSize.xs,
        withBorder: true,
        child: Column(
          children: [
            // Fixed row plus a scrolling Expanded, rather than a
            // SliverAppBar: the header never moves, so there is no
            // collapse behaviour to tune.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.plinth.surfaceSunken),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: PlinthText('Changelog', weight: FontWeight.w700),
                  ),
                  PlinthActionIcon(
                    semanticLabel: 'Close',
                    icon: const Icon(Icons.close, size: 16),
                    variant: PlinthVariant.subtle,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 12,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child:
                      PlinthText('Release 0.${16 - i}.0', size: PlinthSize.sm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────── Application UI: User Info & Controls (depth) ──────────────

class UserMenuExample extends StatefulWidget {
  const UserMenuExample({super.key});

  @override
  State<UserMenuExample> createState() => _UserMenuExampleState();
}

class _UserMenuExampleState extends State<UserMenuExample> {
  final PlinthDisclosureController _menu = PlinthDisclosureController();

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.sm,
      withBorder: true,
      child: PlinthMenu(
        controller: _menu,
        items: [
          PlinthMenuItem(label: 'Profile', onTap: () {}),
          PlinthMenuItem(label: 'Settings', onTap: () {}),
          PlinthMenuItem(label: 'Sign out', onTap: () {}),
        ],
        // The whole control is the trigger, not a separate caret —
        // the avatar and name are what people aim at.
        target: const PlinthGroup(
          gap: PlinthSize.xs,
          children: [
            PlinthAvatar(initials: 'YL', size: PlinthSize.sm),
            PlinthStack(
              gap: PlinthSize.xs,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlinthText('Yair Lahav',
                    size: PlinthSize.sm, weight: FontWeight.w600),
                PlinthText('Owner', size: PlinthSize.xs, color: 'gray'),
              ],
            ),
            Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
      ),
    );
  }
}

class MemberListExample extends StatelessWidget {
  const MemberListExample({super.key});

  static const _members = [
    (initials: 'AN', name: 'Alice Nguyen', role: 'Owner', color: 'green'),
    (initials: 'BK', name: 'Ben Kaur', role: 'Editor', color: 'blue'),
    (initials: 'CD', name: 'Cara Diaz', role: 'Viewer', color: 'gray'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: PlinthPaper(
        p: PlinthSize.md,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.sm,
          children: [
            const Row(
              children: [
                Expanded(
                  child: PlinthText('Members', weight: FontWeight.w700),
                ),
                // The people beyond the first few, without a second row.
                PlinthOverflowList(
                  children: [
                    PlinthAvatar(initials: 'AN', size: PlinthSize.sm),
                    PlinthAvatar(initials: 'BK', size: PlinthSize.sm),
                    PlinthAvatar(initials: 'CD', size: PlinthSize.sm),
                    PlinthAvatar(initials: 'EF', size: PlinthSize.sm),
                    PlinthAvatar(initials: 'GH', size: PlinthSize.sm),
                  ],
                ),
              ],
            ),
            for (final m in _members)
              // A Row rather than PlinthGroup: Group wraps by default,
              // and Expanded's parent data means nothing to a Wrap.
              Row(
                children: [
                  PlinthAvatar(initials: m.initials, size: PlinthSize.sm),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PlinthText(m.name, size: PlinthSize.sm),
                  ),
                  PlinthBadge(m.role, color: m.color),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class UserStatusExample extends StatefulWidget {
  const UserStatusExample({super.key});

  @override
  State<UserStatusExample> createState() => _UserStatusExampleState();
}

class _UserStatusExampleState extends State<UserStatusExample> {
  String _status = 'online';

  static const _colors = {
    'online': 'green',
    'away': 'yellow',
    'busy': 'red',
  };

  @override
  Widget build(BuildContext context) {
    return PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: PlinthStack(
        gap: PlinthSize.sm,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthGroup(
            gap: PlinthSize.sm,
            children: [
              // The dot rides the avatar rather than sitting beside it,
              // which is what makes presence readable at a glance.
              PlinthIndicator(
                color: _colors[_status],
                child: const PlinthAvatar(initials: 'YL'),
              ),
              PlinthStack(
                gap: PlinthSize.xs,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PlinthText('Yair Lahav', weight: FontWeight.w600),
                  PlinthText(_status, size: PlinthSize.xs, color: 'gray'),
                ],
              ),
            ],
          ),
          PlinthSegmentedControl<String>(
            size: PlinthSize.sm,
            value: _status,
            onChanged: (s) => setState(() => _status = s),
            items: const [
              PlinthSegmentedControlItem('online', 'Online'),
              PlinthSegmentedControlItem('away', 'Away'),
              PlinthSegmentedControlItem('busy', 'Busy'),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────── Application UI: Application Cards (depth) ───────────────

class PricingCardExample extends StatelessWidget {
  const PricingCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: PlinthCard(
        withBorder: true,
        header: const PlinthGroup(
          children: [
            PlinthText('Pro', size: PlinthSize.lg, weight: FontWeight.w700),
            PlinthBadge('Popular', color: 'violet'),
          ],
        ),
        footer: PlinthButton(
          fullWidth: true,
          onPressed: () {},
          child: const Text('Start trial'),
        ),
        child: const PlinthStack(
          gap: PlinthSize.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The price is the thing being compared, so it carries the
            // weight rather than the plan name above it.
            PlinthGroup(
              gap: PlinthSize.xs,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PlinthNumberFormatter(
                  value: 24,
                  prefix: r'$',
                  size: PlinthSize.xl,
                  weight: FontWeight.w700,
                ),
                PlinthText('/ month', size: PlinthSize.xs, color: 'gray'),
              ],
            ),
            PlinthList(
              size: PlinthSize.sm,
              items: [
                PlinthListItem(PlinthText('Unlimited projects'),
                    icon: Icon(Icons.check, size: 14)),
                PlinthListItem(PlinthText('Priority support'),
                    icon: Icon(Icons.check, size: 14)),
                PlinthListItem(PlinthText('Audit log'),
                    icon: Icon(Icons.check, size: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MediaCardExample extends StatelessWidget {
  const MediaCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // 320 rather than 280: two tags plus the bookmark action overflow
      // a narrower card, and shrinking the tags to fit would misrepresent
      // how much room this arrangement actually needs.
      width: 320,
      child: PlinthCard(
        withBorder: true,
        // The image is the header rather than a child, so it runs to
        // the card's edges instead of sitting inside its padding.
        header: const PlinthBackgroundImage(
          src: 'https://picsum.photos/seed/plinth-card/600/240',
          height: 120,
          child: PlinthTitle('Kyoto', order: 4),
        ),
        child: PlinthStack(
          gap: PlinthSize.xs,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlinthText(
              'Twelve temples, two days, and more stairs than either of '
              'us expected.',
              size: PlinthSize.sm,
            ),
            // Row, not PlinthGroup: Spacer is an Expanded underneath,
            // and Group wraps by default so the flex never applies.
            Row(
              children: [
                const PlinthBadge('Travel'),
                const SizedBox(width: 4),
                const PlinthBadge('Photography'),
                const Spacer(),
                PlinthActionIcon(
                  semanticLabel: 'Bookmark',
                  icon: const Icon(Icons.bookmark_border, size: 16),
                  variant: PlinthVariant.subtle,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityCardExample extends StatelessWidget {
  const ActivityCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 300,
      child: PlinthCard(
        withBorder: true,
        header: PlinthText('Deployment', weight: FontWeight.w700),
        // A card whose body is a sequence rather than a paragraph —
        // the arrangement a status panel actually needs.
        child: PlinthTimeline(
          items: [
            PlinthTimelineItem(
              title: 'Queued',
              description: '14:02',
              active: true,
            ),
            PlinthTimelineItem(
              title: 'Building',
              description: '14:03',
              active: true,
            ),
            PlinthTimelineItem(title: 'Deploying', description: 'Pending'),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── Application UI: Stats (depth) ─────────────────────

class StatWithPeriodExample extends StatefulWidget {
  const StatWithPeriodExample({super.key});

  @override
  State<StatWithPeriodExample> createState() => _StatWithPeriodExampleState();
}

class _StatWithPeriodExampleState extends State<StatWithPeriodExample> {
  String _period = 'month';

  static const _values = {'week': 12480, 'month': 48210, 'year': 512900};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: PlinthStack(
          gap: PlinthSize.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlinthText('Revenue', size: PlinthSize.sm, color: 'gray'),
            // The number rolls between periods rather than swapping,
            // which is the one place an animated figure earns itself:
            // it shows the two values are the same measure.
            PlinthRollingNumber(
              value: _values[_period]!,
              prefix: r'$',
              size: PlinthSize.xl,
              weight: FontWeight.w700,
            ),
            PlinthSegmentedControl<String>(
              size: PlinthSize.sm,
              fullWidth: true,
              value: _period,
              onChanged: (p) => setState(() => _period = p),
              items: const [
                PlinthSegmentedControlItem('week', 'Week'),
                PlinthSegmentedControlItem('month', 'Month'),
                PlinthSegmentedControlItem('year', 'Year'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatBreakdownExample extends StatelessWidget {
  const StatBreakdownExample({super.key});

  static const _segments = [
    (label: 'Direct', share: 5, color: 'blue'),
    (label: 'Search', share: 3, color: 'teal'),
    (label: 'Social', share: 2, color: 'grape'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return SizedBox(
      width: 360,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: PlinthStack(
          gap: PlinthSize.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlinthText('Sessions', size: PlinthSize.sm, color: 'gray'),
            const PlinthNumberFormatter(
              value: 18420,
              size: PlinthSize.xl,
              weight: FontWeight.w700,
            ),
            // A part-to-whole bar rather than three separate figures:
            // the point of this arrangement is the proportion, which
            // separate numbers make you compute yourself.
            //
            // This was a hand-rolled Row of Expandeds until 0.19.0,
            // when PlinthProgress learned sections — the audit found
            // the gap by noticing this block routing around it.
            PlinthProgress.sections(
              size: PlinthSize.sm,
              sections: [
                for (final s in _segments)
                  PlinthProgressSection(
                    value: s.share / 10,
                    color: s.color,
                    label: s.label,
                  ),
              ],
            ),
            PlinthGroup(
              gap: PlinthSize.md,
              children: [
                for (final s in _segments)
                  PlinthGroup(
                    gap: PlinthSize.xs,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.shaded(s.color, 6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      PlinthText(s.label, size: PlinthSize.xs),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatGoalRingsExample extends StatelessWidget {
  const StatGoalRingsExample({super.key});

  static const _goals = [
    (label: 'Signups', value: 0.82, color: 'teal'),
    (label: 'Activation', value: 0.46, color: 'blue'),
    (label: 'Retention', value: 0.91, color: 'grape'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: PlinthGroup(
          gap: PlinthSize.xl,
          children: [
            for (final g in _goals)
              PlinthStack(
                gap: PlinthSize.xs,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Rings rather than bars: these are three unrelated
                  // targets, not parts of one total, and a row of bars
                  // would imply they add up.
                  PlinthRingProgress(
                    value: g.value,
                    color: g.color,
                    diameter: 72,
                    label: PlinthText(
                      '${(g.value * 100).round()}%',
                      size: PlinthSize.sm,
                      weight: FontWeight.w700,
                    ),
                  ),
                  PlinthText(g.label, size: PlinthSize.xs, color: 'gray'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── Page Sections: Authentication (depth) ─────────────────────

class PasswordResetExample extends StatelessWidget {
  const PasswordResetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: PlinthPaper(
        p: PlinthSize.lg,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlinthTitle('Reset your password', order: 4),
            const PlinthText(
              'We will send a link to the address on your account.',
              size: PlinthSize.sm,
              color: 'gray',
            ),
            const PlinthTextInput(
              label: 'Email',
              placeholder: 'you@example.com',
            ),
            PlinthButton(
              fullWidth: true,
              onPressed: () {},
              child: const Text('Send reset link'),
            ),
            // The way back matters as much as the way forward: a reset
            // screen with no exit strands anyone who mistyped the URL.
            Center(child: PlinthAnchor('Back to sign in', onTap: () {})),
          ],
        ),
      ),
    );
  }
}

class TwoFactorExample extends StatefulWidget {
  const TwoFactorExample({super.key});

  @override
  State<TwoFactorExample> createState() => _TwoFactorExampleState();
}

class _TwoFactorExampleState extends State<TwoFactorExample> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: PlinthPaper(
        p: PlinthSize.lg,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlinthTitle('Two-factor code', order: 4),
            const PlinthText(
              'Enter the six digits from your authenticator app.',
              size: PlinthSize.sm,
              color: 'gray',
            ),
            Center(
              child: PlinthPinInput(
                length: 6,
                value: _code,
                onChanged: (v) => setState(() => _code = v),
              ),
            ),
            PlinthButton(
              fullWidth: true,
              // Disabled until the code is complete — the button is the
              // affordance that says how many digits are expected.
              onPressed: _code.length == 6 ? () {} : null,
              child: const Text('Verify'),
            ),
            Center(child: PlinthAnchor('Send a new code', onTap: () {})),
          ],
        ),
      ),
    );
  }
}

class SplitAuthExample extends StatelessWidget {
  const SplitAuthExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 620,
      height: 300,
      child: PlinthPaper(
        p: PlinthSize.xs,
        withBorder: true,
        child: Row(
          children: [
            // The brand half is decoration, so it goes first in the
            // tree but carries no focusable content — a screen reader
            // reaches the form without wading through it.
            const Expanded(
              child: PlinthBackgroundImage(
                src: 'https://picsum.photos/seed/plinth-auth/600/600',
                height: double.infinity,
                child: PlinthTitle('Build faster', order: 3),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: PlinthStack(
                  gap: PlinthSize.sm,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PlinthTitle('Welcome back', order: 4),
                    const PlinthTextInput(label: 'Email'),
                    const PlinthTextInput(label: 'Password', obscureText: true),
                    PlinthButton(
                      fullWidth: true,
                      onPressed: () {},
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── Page Sections: Error Pages (depth) ─────────────────────

class MaintenanceExample extends StatelessWidget {
  const MaintenanceExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlinthEmptyState(
        icon: const Icon(Icons.build_outlined),
        title: 'Down for maintenance',
        description: 'We are upgrading the database. Back at 14:30 UTC.',
        // A maintenance page is the one error state where the useful
        // action is elsewhere, so it points at status rather than
        // offering a retry that cannot succeed yet.
        action: PlinthButton(
          variant: PlinthVariant.outline,
          onPressed: () {},
          leadingIcon: const Icon(Icons.open_in_new, size: 16),
          child: const Text('Status page'),
        ),
      ),
    );
  }
}

class PermissionDeniedExample extends StatelessWidget {
  const PermissionDeniedExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlinthStack(
        gap: PlinthSize.sm,
        children: [
          PlinthEmptyState(
            icon: const Icon(Icons.lock_outline),
            title: 'You do not have access',
            description: 'Ask an owner of this workspace to invite you.',
            color: 'red',
            action: PlinthButton(
              onPressed: () {},
              child: const Text('Request access'),
            ),
          ),
          // Naming who can actually help turns a dead end into a next
          // step — "contact an administrator" rarely says which one.
          const PlinthDataList(
            orientation: PlinthDataListOrientation.horizontal,
            items: [
              PlinthDataListItem.text('Workspace', 'Acme design'),
              PlinthDataListItem.text('Owner', 'alice@acme.com'),
            ],
          ),
        ],
      ),
    );
  }
}

class OfflineExample extends StatelessWidget {
  const OfflineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlinthPaper(
        p: PlinthSize.lg,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.sm,
          children: [
            const PlinthAlert(
              title: 'You are offline',
              color: 'yellow',
              icon: Icon(Icons.wifi_off),
              child: Text(
                'Changes are saved locally and will sync when the '
                'connection returns.',
              ),
            ),
            // Unlike the other two, this state resolves itself, so the
            // page keeps working rather than replacing itself with an
            // apology.
            const PlinthDataList(
              items: [
                PlinthDataListItem.text('Queued changes', '3'),
                PlinthDataListItem.text('Last synced', '11:42'),
              ],
            ),
            PlinthGroup(
              children: [
                PlinthButton(
                  variant: PlinthVariant.outline,
                  onPressed: () {},
                  leadingIcon: const Icon(Icons.refresh, size: 16),
                  child: const Text('Retry now'),
                ),
                PlinthButton(
                  variant: PlinthVariant.subtle,
                  onPressed: () {},
                  child: const Text('Work offline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Blog UI: Article Cards (depth) ─────────────────────────

class HorizontalArticleCardExample extends StatelessWidget {
  const HorizontalArticleCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: PlinthPaper(
        p: PlinthSize.sm,
        withBorder: true,
        // Horizontal rather than stacked: a feed of these fits far
        // more articles on screen, and the image can shrink without
        // the headline reflowing.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: const PlinthImage(
                src: 'https://picsum.photos/seed/plinth-row/240/240',
                width: 96,
                height: 96,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: PlinthStack(
                gap: PlinthSize.xs,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlinthBadge('Engineering', color: 'blue'),
                  PlinthText(
                    'What a render object is actually for',
                    weight: FontWeight.w700,
                  ),
                  PlinthText(
                    'Most layout problems are solved by composition. '
                    'A few are not, and knowing which is the skill.',
                    size: PlinthSize.sm,
                    color: 'gray',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  PlinthText('6 min read', size: PlinthSize.xs, color: 'gray'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OverlayArticleCardExample extends StatelessWidget {
  const OverlayArticleCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 300,
      // Text over the photograph rather than beneath it. This only
      // works because PlinthBackgroundImage lays a scrim between the
      // two — over a light photo the same text would be unreadable.
      child: PlinthBackgroundImage(
        src: 'https://picsum.photos/seed/plinth-overlay/600/400',
        height: 200,
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: PlinthStack(
            gap: PlinthSize.xs,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlinthBadge('Travel', color: 'teal'),
              PlinthText(
                'Two days in Kyoto',
                size: PlinthSize.lg,
                weight: FontWeight.w700,
              ),
              PlinthText('12 August · 4 min read', size: PlinthSize.xs),
            ],
          ),
        ),
      ),
    );
  }
}

class QuoteArticleCardExample extends StatelessWidget {
  const QuoteArticleCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 380,
      child: PlinthPaper(
        p: PlinthSize.md,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The pull-quote is the card. A headline would compete
            // with it, so the attribution does the naming instead.
            PlinthBlockquote(
              quote: 'A component library is a set of decisions you only '
                  'have to make once.',
              citation: 'Design systems, in practice',
            ),
            PlinthGroup(
              gap: PlinthSize.xs,
              children: [
                PlinthAvatar(initials: 'AN', size: PlinthSize.sm),
                PlinthText('Alice Nguyen',
                    size: PlinthSize.xs, weight: FontWeight.w600),
                PlinthText('· 3 min read', size: PlinthSize.xs, color: 'gray'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleListItemExample extends StatelessWidget {
  const ArticleListItemExample({super.key});

  static const _articles = [
    (n: '01', title: 'Why the theme is a ThemeExtension', read: '4 min'),
    (n: '02', title: 'Controlled components, and when not to', read: '7 min'),
    (n: '03', title: 'Goldens catch what assertions cannot', read: '5 min'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return SizedBox(
      width: 420,
      child: PlinthPaper(
        p: PlinthSize.md,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.xs,
          children: [
            const PlinthText('Most read', weight: FontWeight.w700),
            // Dense rows rather than cards: a "related articles" list
            // is scanned, not browsed, so every pixel of chrome per
            // item is one fewer item on screen.
            for (final a in _articles) ...[
              const PlinthDivider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: PlinthText(
                      a.n,
                      size: PlinthSize.lg,
                      weight: FontWeight.w700,
                      color: 'gray',
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PlinthText(a.title, size: PlinthSize.sm),
                        PlinthText(
                          a.read,
                          size: PlinthSize.xs,
                          color: 'gray',
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: theme.textMuted),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Application UI: Sliders (depth) ─────────────────────────

class SliderWithMarksExample extends StatefulWidget {
  const SliderWithMarksExample({super.key});

  @override
  State<SliderWithMarksExample> createState() => _SliderWithMarksExampleState();
}

class _SliderWithMarksExampleState extends State<SliderWithMarksExample> {
  double _value = 2;

  static const _marks = ['Off', 'Low', 'Medium', 'High', 'Max'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: PlinthPaper(
        p: PlinthSize.md,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.xs,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlinthText('Compression', weight: FontWeight.w600),
            // The labels were a hand-aligned Row of spaceBetween text
            // until 0.19.0, when PlinthSlider learned marks — which
            // place each label over the position it names rather than
            // spreading them evenly and hoping.
            PlinthSlider(
              value: _value,
              max: 4,
              // Discrete rather than continuous: the marks are the real
              // scale, so a value between them would be a position no
              // label can name.
              divisions: 4,
              label: _marks[_value.round()],
              marks: [
                for (var i = 0; i < _marks.length; i++)
                  PlinthSliderMark(value: i.toDouble(), label: _marks[i]),
              ],
              onChanged: (v) => setState(() => _value = v),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetSliderExample extends StatefulWidget {
  const BudgetSliderExample({super.key});

  @override
  State<BudgetSliderExample> createState() => _BudgetSliderExampleState();
}

class _BudgetSliderExampleState extends State<BudgetSliderExample> {
  double _budget = 2400;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: PlinthPaper(
        p: PlinthSize.md,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: PlinthText('Monthly budget', weight: FontWeight.w600),
                ),
                // Formatted rather than raw: a slider reporting "2400"
                // leaves the reader to supply the currency and
                // separators the figure means nothing without.
                PlinthNumberFormatter(
                  value: _budget.round(),
                  prefix: r'$',
                  size: PlinthSize.lg,
                  weight: FontWeight.w700,
                ),
              ],
            ),
            PlinthSlider(
              value: _budget,
              min: 500,
              max: 10000,
              divisions: 19,
              onChanged: (v) => setState(() => _budget = v),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlinthText(r'$500', size: PlinthSize.xs, color: 'gray'),
                PlinthText(r'$10,000', size: PlinthSize.xs, color: 'gray'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ColourControlsExample extends StatefulWidget {
  const ColourControlsExample({super.key});

  @override
  State<ColourControlsExample> createState() => _ColourControlsExampleState();
}

class _ColourControlsExampleState extends State<ColourControlsExample> {
  double _hue = 210;
  double _alpha = 1;

  @override
  Widget build(BuildContext context) {
    final colour = HSVColor.fromAHSV(_alpha, _hue, 0.8, 0.9).toColor();

    return SizedBox(
      width: 420,
      child: PlinthPaper(
        p: PlinthSize.md,
        withBorder: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Two slider types driving one preview. On their own the
            // colour sliders look like decoration; the swatch is what
            // makes them read as controls.
            Expanded(
              child: PlinthStack(
                gap: PlinthSize.sm,
                children: [
                  PlinthHueSlider(
                    value: _hue,
                    onChanged: (h) => setState(() => _hue = h),
                  ),
                  PlinthAlphaSlider(
                    color: colour,
                    value: _alpha,
                    onChanged: (a) => setState(() => _alpha = a),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 96,
              height: 72,
              decoration: BoxDecoration(
                color: colour,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.plinth.border),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Application UI: Buttons (depth) ─────────────────────────

class SplitButtonExample extends StatefulWidget {
  const SplitButtonExample({super.key});

  @override
  State<SplitButtonExample> createState() => _SplitButtonExampleState();
}

class _SplitButtonExampleState extends State<SplitButtonExample> {
  final PlinthDisclosureController _menu = PlinthDisclosureController();

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlinthButtonGroup(
      children: [
        // The common action stays one tap away; the alternatives hide
        // behind the caret. A plain menu would cost a tap for the
        // thing people pick nine times in ten.
        PlinthButton(onPressed: () {}, child: const Text('Deploy')),
        PlinthMenu(
          controller: _menu,
          items: [
            PlinthMenuItem(label: 'Deploy to staging', onTap: () {}),
            PlinthMenuItem(label: 'Deploy and tag', onTap: () {}),
            PlinthMenuItem(label: 'Dry run', onTap: () {}),
          ],
          target: PlinthButton(
            onPressed: _menu.toggle,
            child: const Icon(Icons.keyboard_arrow_down, size: 16),
          ),
        ),
      ],
    );
  }
}

class AsyncButtonExample extends StatefulWidget {
  const AsyncButtonExample({super.key});

  @override
  State<AsyncButtonExample> createState() => _AsyncButtonExampleState();
}

class _AsyncButtonExampleState extends State<AsyncButtonExample> {
  bool _busy = false;
  bool _done = false;

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _done = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlinthGroup(
      gap: PlinthSize.sm,
      children: [
        PlinthButton(
          // Null while busy rather than a flag: the button is disabled
          // for the same reason it shows a spinner, so one piece of
          // state drives both and they cannot disagree.
          onPressed: _busy ? null : _run,
          leadingIcon: _busy
              ? const PlinthLoader(size: PlinthSize.xs)
              : const Icon(Icons.cloud_upload_outlined, size: 16),
          child: Text(_busy ? 'Publishing…' : 'Publish'),
        ),
        if (_done) const PlinthBadge('Published', color: 'green'),
      ],
    );
  }
}

class ConfirmInlineExample extends StatefulWidget {
  const ConfirmInlineExample({super.key});

  @override
  State<ConfirmInlineExample> createState() => _ConfirmInlineExampleState();
}

class _ConfirmInlineExampleState extends State<ConfirmInlineExample> {
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    // Two steps in place rather than a modal. A modal is right when
    // the consequence needs explaining; for a single reversible row it
    // costs a dialog to answer a question the button can ask itself.
    if (!_confirming) {
      return PlinthButton(
        variant: PlinthVariant.subtle,
        color: 'red',
        onPressed: () => setState(() => _confirming = true),
        leadingIcon: const Icon(Icons.delete_outline, size: 16),
        child: const Text('Delete project'),
      );
    }

    return PlinthGroup(
      gap: PlinthSize.xs,
      children: [
        const PlinthText('Delete permanently?', size: PlinthSize.sm),
        PlinthButton(
          size: PlinthSize.sm,
          color: 'red',
          onPressed: () => setState(() => _confirming = false),
          child: const Text('Delete'),
        ),
        PlinthButton(
          size: PlinthSize.sm,
          variant: PlinthVariant.subtle,
          onPressed: () => setState(() => _confirming = false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// ───────────────────────── Page Sections: Heroes (depth) ─────────────────────────

class HeroWithImageExample extends StatelessWidget {
  const HeroWithImageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      // The photograph is the hero rather than sitting beside it. The
      // scrim is doing real work here: over the light half of this
      // image the headline would otherwise disappear.
      child: PlinthBackgroundImage(
        src: 'https://picsum.photos/seed/plinth-hero/1200/600',
        height: 240,
        scrimOpacity: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: PlinthStack(
            gap: PlinthSize.sm,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const PlinthTitle('Build it once',
                  order: 2, textAlign: TextAlign.center),
              const PlinthText(
                'A themeable component library for Flutter.',
                textAlign: TextAlign.center,
              ),
              PlinthGroup(
                gap: PlinthSize.sm,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlinthButton(
                      onPressed: () {}, child: const Text('Get started')),
                  PlinthButton(
                    variant: PlinthVariant.outline,
                    onPressed: () {},
                    child: const Text('Docs'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroWithSignupExample extends StatelessWidget {
  const HeroWithSignupExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PlinthTitle('Ship your design system',
              order: 2, textAlign: TextAlign.center),
          const PlinthText(
            'One install, 111 components, no lock-in.',
            color: 'gray',
            textAlign: TextAlign.center,
          ),
          // The conversion control lives in the hero rather than
          // behind a button: one fewer step between reading the claim
          // and acting on it.
          Row(
            children: [
              const Expanded(
                child: PlinthTextInput(placeholder: 'you@example.com'),
              ),
              const SizedBox(width: 8),
              PlinthButton(onPressed: () {}, child: const Text('Start free')),
            ],
          ),
          const PlinthText(
            'No card required. Cancel whenever.',
            size: PlinthSize.xs,
            color: 'gray',
          ),
        ],
      ),
    );
  }
}

class HeroWithProofExample extends StatelessWidget {
  const HeroWithProofExample({super.key});

  static const _proof = [
    (value: '111', label: 'components'),
    (value: '82', label: 'blocks'),
    (value: '160', label: 'pub points'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: PlinthStack(
        gap: PlinthSize.md,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PlinthTitle('Trusted where it counts',
              order: 2, textAlign: TextAlign.center),
          PlinthButton(onPressed: () {}, child: const Text('Read the docs')),
          const PlinthDivider(),
          // Evidence under the claim rather than a second paragraph
          // asserting it. Numbers are the part a reader can check.
          PlinthGroup(
            gap: PlinthSize.xl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final p in _proof)
                PlinthStack(
                  gap: PlinthSize.xs,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PlinthText(p.value,
                        size: PlinthSize.xl, weight: FontWeight.w700),
                    PlinthText(p.label, size: PlinthSize.xs, color: 'gray'),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Page Sections: FAQ / Contact / Banners (depth) ───────────────────

class FaqTwoColumnExample extends StatelessWidget {
  const FaqTwoColumnExample({super.key});

  static const _faqs = [
    (q: 'Is it free?', a: 'Yes, MIT licensed, including commercial use.'),
    (
      q: 'Does it do dark mode?',
      a: 'Register darkTheme and the library follows.'
    ),
    (q: 'Can I retheme it?', a: 'Every colour prop is a key into the palette.'),
    (
      q: 'Which platforms?',
      a: 'Anywhere Flutter runs; the demo is on the web.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlinthStack(
        gap: PlinthSize.md,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PlinthTitle('Common questions', order: 3),
          // Everything open in two columns rather than an accordion.
          // For four short answers, hiding them behind a click costs
          // more than the vertical space it saves.
          PlinthSimpleGrid(
            columns: 2,
            children: [
              for (final f in _faqs)
                PlinthStack(
                  gap: PlinthSize.xs,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlinthText(f.q, weight: FontWeight.w700),
                    PlinthText(f.a, size: PlinthSize.sm, color: 'gray'),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class FaqSearchExample extends StatefulWidget {
  const FaqSearchExample({super.key});

  @override
  State<FaqSearchExample> createState() => _FaqSearchExampleState();
}

class _FaqSearchExampleState extends State<FaqSearchExample> {
  String _query = '';

  static const _faqs = [
    (id: 'billing', q: 'When am I billed?', a: 'On the same day each month.'),
    (id: 'cancel', q: 'How do I cancel?', a: 'From Settings, any time.'),
    (id: 'refund', q: 'Do you refund?', a: 'Within 30 days, no questions.'),
  ];

  @override
  Widget build(BuildContext context) {
    final matches = _faqs
        .where((f) => f.q.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return SizedBox(
      width: 520,
      child: PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthTextInput(
            placeholder: 'Search questions…',
            leadingIcon: const Icon(Icons.search, size: 18),
            onChanged: (v) => setState(() => _query = v),
          ),
          if (matches.isEmpty)
            // A search that can return nothing needs to say so; an
            // empty accordion just looks broken.
            const PlinthEmptyState(
              title: 'No matching questions',
              description: 'Try a different word, or contact support.',
            )
          else
            PlinthAccordion(
              items: [
                for (final f in matches)
                  PlinthAccordionItem(
                    value: f.id,
                    title: f.q,
                    content: PlinthText(f.a, size: PlinthSize.sm),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class SupportChannelsExample extends StatelessWidget {
  const SupportChannelsExample({super.key});

  static const _channels = [
    (
      icon: Icons.chat_bubble_outline,
      title: 'Live chat',
      detail: 'Weekdays, 9–17 UTC',
      colour: 'blue'
    ),
    (
      icon: Icons.mail_outline,
      title: 'Email',
      detail: 'Replies within a day',
      colour: 'teal'
    ),
    (
      icon: Icons.menu_book_outlined,
      title: 'Docs',
      detail: 'Answers most questions',
      colour: 'grape'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      // Routing rather than a form: when several channels exist, the
      // reader's first decision is which one, and a form presumes that
      // answer for them.
      child: PlinthSimpleGrid(
        columns: 3,
        children: [
          for (final c in _channels)
            PlinthPaper(
              p: PlinthSize.md,
              withBorder: true,
              child: PlinthStack(
                gap: PlinthSize.xs,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlinthThemeIcon(
                    icon: Icon(c.icon),
                    variant: PlinthVariant.light,
                    color: c.colour,
                  ),
                  PlinthText(c.title, weight: FontWeight.w700),
                  PlinthText(c.detail, size: PlinthSize.xs, color: 'gray'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ContactWithHoursExample extends StatelessWidget {
  const ContactWithHoursExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PlinthStack(
              gap: PlinthSize.sm,
              children: [
                const PlinthTitle('Talk to us', order: 4),
                const PlinthTextInput(label: 'Email'),
                const PlinthTextarea(label: 'How can we help?', minLines: 3),
                PlinthButton(onPressed: () {}, child: const Text('Send')),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Setting expectations beside the form rather than after it:
          // knowing the reply window before writing changes what people
          // write, and whether they wait.
          const Expanded(
            child: PlinthStack(
              gap: PlinthSize.sm,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlinthText('When we reply', weight: FontWeight.w700),
                PlinthDataList(
                  orientation: PlinthDataListOrientation.vertical,
                  items: [
                    PlinthDataListItem.text('Weekdays', 'Within 4 hours'),
                    PlinthDataListItem.text('Weekends', 'Next working day'),
                    PlinthDataListItem.text('Timezone', 'UTC+0'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PromoBannerExample extends StatefulWidget {
  const PromoBannerExample({super.key});

  @override
  State<PromoBannerExample> createState() => _PromoBannerExampleState();
}

class _PromoBannerExampleState extends State<PromoBannerExample> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return PlinthButton(
        variant: PlinthVariant.subtle,
        size: PlinthSize.sm,
        onPressed: () => setState(() => _visible = true),
        child: const Text('Show the banner again'),
      );
    }

    final theme = context.plinth;

    return SizedBox(
      width: 560,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing[PlinthSize.md]!,
          vertical: theme.spacing[PlinthSize.sm]!,
        ),
        decoration: BoxDecoration(
          color: theme.shaded('grape', 0),
          borderRadius:
              BorderRadius.circular(theme.radius[theme.defaultRadius]!),
        ),
        child: Row(
          children: [
            const PlinthBadge('Offer', color: 'grape'),
            const SizedBox(width: 12),
            const Expanded(
              child: PlinthText(
                'Annual plans are 20% off until Friday.',
                size: PlinthSize.sm,
              ),
            ),
            PlinthButton(
              size: PlinthSize.xs,
              color: 'grape',
              onPressed: () {},
              child: const Text('See plans'),
            ),
            // Dismissible, unlike the consent banner: a promo the
            // reader has declined should not keep asking.
            PlinthCloseButton(
              size: PlinthSize.xs,
              onPressed: () => setState(() => _visible = false),
              semanticLabel: 'Dismiss offer',
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateBannerExample extends StatelessWidget {
  const UpdateBannerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlinthAlert(
        title: 'Version 0.17.0 is available',
        color: 'blue',
        icon: const Icon(Icons.system_update_alt),
        child: PlinthStack(
          gap: PlinthSize.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlinthText(
              'Adds four components and fixes a marquee overflow.',
              size: PlinthSize.sm,
            ),
            // Two actions, and the passive one is not a dismissal:
            // an update banner that can only be closed teaches people
            // to close it.
            PlinthGroup(
              gap: PlinthSize.xs,
              children: [
                PlinthButton(
                  size: PlinthSize.xs,
                  onPressed: () {},
                  child: const Text('Update now'),
                ),
                PlinthButton(
                  size: PlinthSize.xs,
                  variant: PlinthVariant.subtle,
                  onPressed: () {},
                  child: const Text('Release notes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────── Page Sections: Features (depth) ────────────────────────

class FeatureWithScreenshotExample extends StatelessWidget {
  const FeatureWithScreenshotExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      // Text and image alternating sides down the page. Showing one
      // pair is the point: the arrangement is the repeat, not the
      // single row.
      child: PlinthStack(
        gap: PlinthSize.lg,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: PlinthStack(
                  gap: PlinthSize.xs,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlinthBadge('Theming', color: 'violet'),
                    PlinthTitle('One token, every component', order: 4),
                    PlinthText(
                      'Change the primary colour and the whole library '
                      'follows, dark mode included.',
                      size: PlinthSize.sm,
                      color: 'gray',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const PlinthImage(
                    src: 'https://picsum.photos/seed/plinth-f1/600/360',
                    height: 130,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const PlinthImage(
                    src: 'https://picsum.photos/seed/plinth-f2/600/360',
                    height: 130,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: PlinthStack(
                  gap: PlinthSize.xs,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlinthBadge('Testing', color: 'teal'),
                    PlinthTitle('Goldens where they matter', order: 4),
                    PlinthText(
                      'Visual coverage for the components that compute '
                      'their own layout.',
                      size: PlinthSize.sm,
                      color: 'gray',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeatureComparisonExample extends StatelessWidget {
  const FeatureComparisonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 480,
      child: PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthTitle('Compare plans', order: 4),
          // A matrix rather than three cards: the reader's question is
          // what differs between plans, and columns answer it directly
          // where cards make them hold three lists in their head.
          PlinthTable(
            columns: ['Feature', 'Free', 'Pro'],
            rows: [
              [
                PlinthText('Components'),
                PlinthText('All'),
                PlinthText('All'),
              ],
              [
                PlinthText('Private themes'),
                Icon(Icons.close, size: 16),
                Icon(Icons.check, size: 16),
              ],
              [
                PlinthText('Support'),
                PlinthText('Community'),
                PlinthBadge('Priority', color: 'violet'),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class FeatureLogoStripExample extends StatelessWidget {
  const FeatureLogoStripExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 480,
      child: PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PlinthText(
            'BUILT WITH PLINTH',
            size: PlinthSize.xs,
            color: 'gray',
            weight: FontWeight.w700,
          ),
          // A marquee rather than a static row: a logo strip usually
          // has more names than fit, and this is the arrangement that
          // shows them all without a second line. It stops under the
          // pointer and never starts under reduce-motion.
          PlinthMarquee(
            speed: 25,
            child: PlinthGroup(
              wrap: false,
              gap: PlinthSize.xl,
              children: [
                PlinthText('ACME', weight: FontWeight.w700),
                PlinthText('GLOBEX', weight: FontWeight.w700),
                PlinthText('INITECH', weight: FontWeight.w700),
                PlinthText('UMBRELLA', weight: FontWeight.w700),
                PlinthText('SOYLENT', weight: FontWeight.w700),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Application UI: Footers & Grids (depth) ───────────────────

class FooterWithNewsletterExample extends StatelessWidget {
  const FooterWithNewsletterExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return SizedBox(
      width: 560,
      child: PlinthStack(
        gap: PlinthSize.md,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: PlinthStack(
                  gap: PlinthSize.xs,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlinthText('Plinth UI', weight: FontWeight.w700),
                    PlinthText(
                      'A themeable component library for Flutter.',
                      size: PlinthSize.sm,
                      color: 'gray',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // The signup lives in the footer because that is where
              // someone who read the whole page ends up. Putting it
              // only in the hero asks before they have a reason.
              Expanded(
                child: PlinthStack(
                  gap: PlinthSize.xs,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PlinthText('Release notes by email',
                        size: PlinthSize.sm, weight: FontWeight.w600),
                    Row(
                      children: [
                        const Expanded(
                          child: PlinthTextInput(
                            placeholder: 'you@example.com',
                            size: PlinthSize.sm,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PlinthButton(
                          size: PlinthSize.sm,
                          onPressed: () {},
                          child: const Text('Subscribe'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 1, color: theme.surfaceSunken),
          Row(
            children: [
              const Expanded(
                child: PlinthText('© 2026 Plinth',
                    size: PlinthSize.xs, color: 'gray'),
              ),
              PlinthGroup(
                gap: PlinthSize.xs,
                children: [
                  // Paired with their labels rather than looped over
                  // bare: an icon-only button announces as nothing
                  // without one, and three of them in a row announce as
                  // nothing three times.
                  for (final (icon, label) in [
                    (Icons.code, 'Source'),
                    (Icons.chat_bubble_outline, 'Chat'),
                    (Icons.alternate_email, 'Email'),
                  ])
                    PlinthActionIcon(
                      semanticLabel: label,
                      icon: Icon(icon, size: 16),
                      variant: PlinthVariant.subtle,
                      onPressed: () {},
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FooterMinimalExample extends StatelessWidget {
  const FooterMinimalExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return SizedBox(
      // Wider than the other blocks on purpose: a single row of status
      // plus three links needs the room, and squeezing the links would
      // misrepresent how much space the arrangement actually takes.
      width: 640,
      // One line, for an app rather than a marketing page: the footer
      // of a tool should take a row, not a screen, and status belongs
      // where it can be glanced at rather than hunted for.
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing[PlinthSize.md]!,
          vertical: theme.spacing[PlinthSize.xs]!,
        ),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.surfaceSunken)),
        ),
        child: Row(
          children: [
            const PlinthIndicator(
              color: 'green',
              child: SizedBox(width: 8, height: 8),
            ),
            const SizedBox(width: 12),
            const PlinthText('All systems normal',
                size: PlinthSize.xs, color: 'gray'),
            const Spacer(),
            PlinthGroup(
              gap: PlinthSize.md,
              children: [
                PlinthAnchor('Privacy', onTap: () {}),
                PlinthAnchor('Terms', onTap: () {}),
                PlinthAnchor('Status', onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AsymmetricGridExample extends StatelessWidget {
  const AsymmetricGridExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 560,
      // PlinthGrid rather than PlinthSimpleGrid: this is the case the
      // twelve-column one exists for, where cells take different
      // widths. A simple grid can only give every cell the same share.
      child: PlinthGrid(
        gutter: PlinthSize.sm,
        children: [
          PlinthGridCol(
            span: 8,
            child: PlinthPaper(
              p: PlinthSize.md,
              withBorder: true,
              child: PlinthText('Main content · span 8'),
            ),
          ),
          PlinthGridCol(
            span: 4,
            child: PlinthPaper(
              p: PlinthSize.md,
              withBorder: true,
              child: PlinthText('Sidebar · 4'),
            ),
          ),
          PlinthGridCol(
            span: 12,
            child: PlinthPaper(
              p: PlinthSize.md,
              withBorder: true,
              child: PlinthText('Full width · span 12'),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageGalleryGridExample extends StatelessWidget {
  const ImageGalleryGridExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      // Fixed ratios rather than fixed heights: images arrive at
      // whatever size the server sends, and a grid of mismatched
      // heights is the usual result of forgetting that.
      child: PlinthSimpleGrid(
        columns: 4,
        children: [
          for (var i = 1; i <= 8; i++)
            PlinthAspectRatio(
              ratio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: PlinthImage(
                  src: 'https://picsum.photos/seed/plinth-g$i/240/240',
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ────────────────────── Application UI: Inputs (depth) ──────────────────────

class PasswordStrengthExample extends StatefulWidget {
  const PasswordStrengthExample({super.key});

  @override
  State<PasswordStrengthExample> createState() =>
      _PasswordStrengthExampleState();
}

class _PasswordStrengthExampleState extends State<PasswordStrengthExample> {
  String _value = 'plinth';

  // Not const: a record holding a closure can't be. Keeping the rule
  // and its test together is what stops the checklist from drifting
  // out of step with what actually passes.
  static final _rules = <({String label, bool Function(String) met})>[
    (label: 'At least 8 characters', met: (v) => v.length >= 8),
    (label: 'Includes a number', met: (v) => v.contains(RegExp(r'\d'))),
    (
      label: 'Includes a capital letter',
      met: (v) => v.contains(RegExp('[A-Z]')),
    ),
    (
      label: 'Includes a symbol',
      met: (v) => v.contains(RegExp(r'[!@#$%^&*(),.?:{}|<>]')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final met = _rules.where((r) => r.met(_value)).length;
    final strength = met / _rules.length;

    return SizedBox(
      width: 460,
      child: PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthPasswordInput(
            label: 'Password',
            placeholder: 'Choose a password',
            onChanged: (v) => setState(() => _value = v),
          ),
          PlinthProgress(
            value: strength,
            size: PlinthSize.xs,
            // Three bands rather than a gradient: the useful question
            // is whether this will be accepted, and a colour that
            // creeps toward green answers it less clearly than one
            // that changes when the answer changes.
            color: strength == 1
                ? 'green'
                : strength >= 0.5
                    ? 'yellow'
                    : 'red',
          ),
          // Every rule stays on screen, met or not. A checklist that
          // hides what you have satisfied leaves you re-reading the
          // remainder to work out what changed.
          for (final rule in _rules)
            Row(
              children: [
                Icon(
                  rule.met(_value) ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: rule.met(_value)
                      ? context.plinth.shaded('green', 6)
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                PlinthText(
                  rule.label,
                  size: PlinthSize.sm,
                  color: rule.met(_value) ? null : 'gray',
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class VerificationCodeExample extends StatefulWidget {
  const VerificationCodeExample({super.key});

  @override
  State<VerificationCodeExample> createState() =>
      _VerificationCodeExampleState();
}

class _VerificationCodeExampleState extends State<VerificationCodeExample> {
  static const _expected = '123456';

  String _code = '';
  bool? _accepted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: PlinthPaper(
        p: PlinthSize.lg,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.sm,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const PlinthTitle('Enter your code', order: 4),
            const PlinthText(
              'We sent six digits to hello@example.com. Try 123456.',
              size: PlinthSize.sm,
              color: 'gray',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            PlinthPinInput(
              length: 6,
              value: _code,
              // Checked on completion rather than per keystroke: a
              // half-typed code is not a wrong code, and marking it
              // red while someone is still typing says otherwise.
              onChanged: (v) => setState(() {
                _code = v;
                if (v.length < _expected.length) _accepted = null;
              }),
              onCompleted: (v) => setState(() => _accepted = v == _expected),
              error: _accepted == false,
            ),
            if (_accepted == true)
              const PlinthText('Verified', size: PlinthSize.sm, color: 'green')
            else if (_accepted == false)
              const PlinthText('That code has expired or is wrong',
                  size: PlinthSize.sm, color: 'red')
            else
              const PlinthText('Code expires in 9:58',
                  size: PlinthSize.sm, color: 'gray'),
            PlinthAnchor('Send a new code',
                size: PlinthSize.sm, onTap: () => setState(() => _code = '')),
          ],
        ),
      ),
    );
  }
}

class SecretFieldExample extends StatefulWidget {
  const SecretFieldExample({super.key});

  @override
  State<SecretFieldExample> createState() => _SecretFieldExampleState();
}

class _SecretFieldExampleState extends State<SecretFieldExample> {
  // A field nobody types into: the value arrives from the server, and
  // the whole arrangement exists to get it back out again intact.
  final _controller = TextEditingController(text: 'pk_live_4f8Xq2Lm90Zt');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _regenerate() {
    final stamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    _controller.text = 'pk_live_$stamp';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: PlinthStack(
        gap: PlinthSize.xs,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                // A password field for its reveal toggle rather than
                // for secrecy — the point is that a key on screen in a
                // shared window is a key in a screenshot.
                child: PlinthPasswordInput(
                  label: 'Publishable key',
                  controller: _controller,
                ),
              ),
              const SizedBox(width: 8),
              PlinthCopyButton(value: _controller.text),
              const SizedBox(width: 4),
              PlinthButton(
                variant: PlinthVariant.outline,
                onPressed: _regenerate,
                child: const Text('Regenerate'),
              ),
            ],
          ),
          const PlinthText(
            'Regenerating takes effect immediately. Existing calls with the '
            'old key will start failing.',
            size: PlinthSize.xs,
            color: 'gray',
          ),
        ],
      ),
    );
  }
}

class AddressFormExample extends StatefulWidget {
  const AddressFormExample({super.key});

  @override
  State<AddressFormExample> createState() => _AddressFormExampleState();
}

class _AddressFormExampleState extends State<AddressFormExample> {
  String? _country = 'il';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      // A fieldset rather than a heading above the fields: it names
      // the group for a screen reader too, so the field is announced
      // as "Shipping address, City" rather than a bare "City".
      child: PlinthFieldset(
        legend: 'Shipping address',
        child: PlinthGrid(
          gutter: PlinthSize.sm,
          children: [
            // Spans rather than a stack of full-width fields: a
            // postcode box as wide as the street line invites the
            // wrong thing to be typed into it.
            const PlinthGridCol(
              span: 12,
              child: PlinthTextInput(label: 'Street address'),
            ),
            const PlinthGridCol(
              span: 12,
              spanXs: 7,
              child: PlinthTextInput(label: 'City'),
            ),
            PlinthGridCol(
              span: 12,
              spanXs: 5,
              child: PlinthMaskInput(
                mask: '#######',
                label: 'Postcode',
                onChanged: (_) {},
              ),
            ),
            PlinthGridCol(
              span: 12,
              spanXs: 7,
              child: PlinthSelect<String>(
                label: 'Country',
                value: _country,
                onChanged: (v) => setState(() => _country = v),
                options: const [
                  PlinthSelectOption('il', 'Israel'),
                  PlinthSelectOption('uk', 'United Kingdom'),
                  PlinthSelectOption('us', 'United States'),
                ],
              ),
            ),
            const PlinthGridCol(
              span: 12,
              spanXs: 5,
              child: PlinthTextInput(
                label: 'Phone',
                placeholder: 'For delivery only',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────── Application UI: Navbars, Stats, User info (depth) ─────────────

class NavbarWithSublevelsExample extends StatefulWidget {
  const NavbarWithSublevelsExample({super.key});

  @override
  State<NavbarWithSublevelsExample> createState() =>
      _NavbarWithSublevelsExampleState();
}

class _NavbarWithSublevelsExampleState
    extends State<NavbarWithSublevelsExample> {
  static const _sections = [
    (
      label: 'Analytics',
      icon: Icons.insights_outlined,
      children: ['Traffic', 'Conversions', 'Retention'],
    ),
    (
      label: 'Content',
      icon: Icons.article_outlined,
      children: ['Posts', 'Pages', 'Media'],
    ),
  ];

  String _open = 'Analytics';
  String _active = 'Conversions';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: PlinthPaper(
        p: PlinthSize.sm,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.xs,
          children: [
            // A hierarchy you navigate *into*, where the sectioned
            // navbar's headings are flat destinations that merely
            // group. The difference shows in the state: only one
            // branch is open at a time, and the parent is not itself
            // a place you can be — which is why it takes
            // onOpenedChanged and no onTap.
            for (final section in _sections)
              PlinthNavLink(
                label: section.label,
                leadingIcon: Icon(section.icon, size: 18),
                opened: _open == section.label,
                onOpenedChanged: (opened) => setState(
                  () => _open = opened ? section.label : '',
                ),
                children: [
                  for (final child in section.children)
                    PlinthNavLink(
                      label: child,
                      active: _active == child,
                      onTap: () => setState(() => _active = child),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class NavbarWithFooterUserExample extends StatelessWidget {
  const NavbarWithFooterUserExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return SizedBox(
      width: 240,
      // A real height rather than shrink-wrapping: the arrangement
      // being shown is what a navbar does with the space *between*
      // its two ends, which a card sized to its content can't show.
      height: 340,
      child: PlinthPaper(
        p: PlinthSize.sm,
        withBorder: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Workspace at the top, account at the bottom, links in
            // between: the two things you switch rarely bracket the
            // one you use constantly.
            PlinthUnstyledButton(
              onPressed: () {},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.surfaceSunken,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    PlinthAvatar(initials: 'AC', size: PlinthSize.sm),
                    SizedBox(width: 8),
                    Expanded(
                      child: PlinthText('Acme Corp',
                          size: PlinthSize.sm, weight: FontWeight.w600),
                    ),
                    Icon(Icons.unfold_more, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            PlinthNavLink(
              label: 'Overview',
              leadingIcon: const Icon(Icons.dashboard_outlined, size: 18),
              active: true,
              onTap: () {},
            ),
            PlinthNavLink(
              label: 'Inbox',
              leadingIcon: const Icon(Icons.inbox_outlined, size: 18),
              trailing: const PlinthBadge('12', color: 'red'),
              onTap: () {},
            ),
            PlinthNavLink(
              label: 'Projects',
              leadingIcon: const Icon(Icons.folder_outlined, size: 18),
              onTap: () {},
            ),
            const Spacer(),
            Divider(height: 17, color: theme.surfaceSunken),
            Row(
              children: [
                const PlinthAvatar(initials: 'YL', size: PlinthSize.sm),
                const SizedBox(width: 8),
                const Expanded(
                  child: PlinthStack(
                    gap: PlinthSize.xs,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlinthText('Yair Lahav',
                          size: PlinthSize.sm, weight: FontWeight.w600),
                      PlinthText('yair@example.com',
                          size: PlinthSize.xs, color: 'gray'),
                    ],
                  ),
                ),
                PlinthActionIcon(
                  semanticLabel: 'Log out',
                  icon: const Icon(Icons.logout, size: 16),
                  variant: PlinthVariant.subtle,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws [values] as a single trend line with a soft fill beneath it.
///
/// Deliberately not a chart: no axes, no ticks, no labels. A sparkline
/// answers "which way, and how steadily" beside a number that already
/// answers "how much" — anything more turns the card into a report.
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    // A flat series would divide by zero; drawing it down the middle
    // is the honest answer rather than a line at the top or bottom.
    final span = max - min;
    final stepX = size.width / (values.length - 1);

    Offset pointAt(int i) {
      final t = span == 0 ? 0.5 : (values[i] - min) / span;
      return Offset(stepX * i, size.height - t * size.height);
    }

    final line = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      line.lineTo(pointAt(i).dx, pointAt(i).dy);
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.12));
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}

class StatWithSparklineExample extends StatelessWidget {
  const StatWithSparklineExample({super.key});

  static const _series = <double>[
    12,
    15,
    14,
    19,
    18,
    24,
    22,
    28,
    31,
    29,
    35,
    38,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return SizedBox(
      width: 360,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: PlinthStack(
          gap: PlinthSize.xs,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlinthText('Monthly revenue',
                size: PlinthSize.sm, color: 'gray'),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PlinthNumberFormatter(
                  value: 38400,
                  prefix: r'$',
                  size: PlinthSize.xl,
                  weight: FontWeight.w700,
                ),
                SizedBox(width: 8),
                PlinthBadge('+9%',
                    color: 'green', variant: PlinthVariant.light),
              ],
            ),
            const SizedBox(height: 4),
            // The shape carries what the percentage can't: whether the
            // rise was steady or one good month with a dip either side.
            SizedBox(
              height: 48,
              width: double.infinity,
              child: CustomPaint(
                painter: _SparklinePainter(
                  values: _series,
                  color: theme.shaded('teal', 6),
                ),
              ),
            ),
            const PlinthText('Last 12 months',
                size: PlinthSize.xs, color: 'gray'),
          ],
        ),
      ),
    );
  }
}

class StatLeaderboardExample extends StatelessWidget {
  const StatLeaderboardExample({super.key});

  static const _rows = [
    (label: '/docs/getting-started', views: 8420),
    (label: '/components/button', views: 5310),
    (label: '/blog/0-17-0', views: 3980),
    (label: '/pricing', views: 1240),
  ];

  @override
  Widget build(BuildContext context) {
    // Shares are measured against the leader, not the total: the
    // question a ranking answers is "how far behind is second", and
    // dividing by a total nobody sees makes every bar look small.
    final top = _rows.first.views;

    return SizedBox(
      width: 420,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: PlinthStack(
          gap: PlinthSize.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlinthText('Top pages', weight: FontWeight.w700),
            for (final row in _rows)
              PlinthStack(
                gap: PlinthSize.xs,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: PlinthText(
                          row.label,
                          size: PlinthSize.sm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PlinthNumberFormatter(
                        value: row.views.toDouble(),
                        size: PlinthSize.sm,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  PlinthProgress(
                    value: row.views / top,
                    size: PlinthSize.xs,
                    color: 'blue',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class AccountSwitcherExample extends StatefulWidget {
  const AccountSwitcherExample({super.key});

  @override
  State<AccountSwitcherExample> createState() => _AccountSwitcherExampleState();
}

class _AccountSwitcherExampleState extends State<AccountSwitcherExample> {
  static const _accounts = [
    (initials: 'YL', name: 'Yair Lahav', detail: 'yair@example.com'),
    (initials: 'AC', name: 'Acme Support', detail: 'support@acme.test'),
    (initials: 'PB', name: 'Plinth Bot', detail: 'bot@plinth.dev'),
  ];

  String _current = 'Yair Lahav';

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return SizedBox(
      width: 320,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.sm,
        child: PlinthStack(
          gap: PlinthSize.xs,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Every account stays listed, the current one marked,
            // rather than one row you press to cycle: switching
            // identity is the kind of action worth seeing before you
            // commit to it.
            for (final account in _accounts)
              PlinthUnstyledButton(
                onPressed: () => setState(() => _current = account.name),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _current == account.name
                        ? theme.surfaceSunken
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      PlinthAvatar(
                          initials: account.initials, size: PlinthSize.sm),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PlinthStack(
                          gap: PlinthSize.xs,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PlinthText(account.name,
                                size: PlinthSize.sm, weight: FontWeight.w600),
                            PlinthText(account.detail,
                                size: PlinthSize.xs, color: 'gray'),
                          ],
                        ),
                      ),
                      if (_current == account.name)
                        Icon(Icons.check,
                            size: 16, color: theme.shaded('blue', 6)),
                    ],
                  ),
                ),
              ),
            const PlinthDivider(),
            PlinthButton(
              fullWidth: true,
              variant: PlinthVariant.subtle,
              size: PlinthSize.sm,
              leadingIcon: const Icon(Icons.add, size: 16),
              onPressed: () {},
              child: const Text('Add another account'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserContactCardExample extends StatelessWidget {
  const UserContactCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 340,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.md,
        child: PlinthStack(
          gap: PlinthSize.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PlinthAvatar(initials: 'CD', size: PlinthSize.lg),
                SizedBox(width: 12),
                Expanded(
                  child: PlinthStack(
                    gap: PlinthSize.xs,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlinthText('Cara Diaz', weight: FontWeight.w700),
                      PlinthText('Field engineer · Lisbon',
                          size: PlinthSize.xs, color: 'gray'),
                    ],
                  ),
                ),
              ],
            ),
            PlinthDivider(),
            // A person as a set of facts you need to *use*, rather
            // than a profile you look at — so each row carries the
            // action that goes with it instead of being plain text.
            _ContactRow(
              icon: Icons.alternate_email,
              value: 'cara@example.com',
            ),
            _ContactRow(icon: Icons.phone_outlined, value: '+351 912 345 678'),
            _ContactRow(icon: Icons.schedule, value: 'WEST · 2 hours ahead'),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Application UI: Carousels ─────────────────────────

class ImageCarouselExample extends StatefulWidget {
  const ImageCarouselExample({super.key});

  @override
  State<ImageCarouselExample> createState() => _ImageCarouselExampleState();
}

class _ImageCarouselExampleState extends State<ImageCarouselExample> {
  static const _photos = [
    (id: 1015, caption: 'Cliffside, Norway'),
    (id: 1016, caption: 'Dunes at dawn'),
    (id: 1018, caption: 'Lake and pines'),
    (id: 1020, caption: 'Bear crossing'),
  ];

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: PlinthPaper(
        withBorder: true,
        p: PlinthSize.sm,
        child: PlinthStack(
          gap: PlinthSize.xs,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlinthCarousel(
              height: 240,
              loop: true,
              withIndicators: true,
              // The caption lives outside the carousel and follows it,
              // rather than being baked into each slide: text over a
              // photograph is the arrangement that goes wrong on a
              // light image, and this one can't.
              onSlideChanged: (i) => setState(() => _index = i),
              slides: [
                for (final photo in _photos)
                  PlinthImage(
                    src: 'https://picsum.photos/id/${photo.id}/720/480',
                    fit: BoxFit.cover,
                    radius: PlinthSize.sm,
                  ),
              ],
            ),
            PlinthText(
              '${_photos[_index].caption} · ${_index + 1} of ${_photos.length}',
              size: PlinthSize.sm,
              color: 'gray',
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCarouselExample extends StatelessWidget {
  const ProductCarouselExample({super.key});

  static const _products = [
    (name: 'Standing desk', price: r'$540', badge: 'New', id: 1073),
    (name: 'Task chair', price: r'$310', badge: null, id: 1076),
    (name: 'Monitor arm', price: r'$120', badge: 'Sale', id: 1080),
    (name: 'Desk lamp', price: r'$85', badge: null, id: 1082),
    (name: 'Cable tray', price: r'$40', badge: null, id: 1084),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      // A row of cards that runs past the edge rather than a grid that
      // wraps: this is a shelf you browse sideways, and slideSize
      // below 1 leaves the next card half-visible so it reads as one.
      child: PlinthCarousel(
        // Tall enough for the card's own padding as well as its
        // content: a slide clips rather than growing to fit.
        height: 224,
        slideSize: 0.38,
        withIndicators: false,
        slides: [
          for (final product in _products)
            PlinthCard(
              withBorder: true,
              // A fixed thumbnail height rather than a `Spacer`: a
              // slide shrink-wraps its content, so a flex child inside
              // one has no remaining space to claim and throws.
              child: PlinthStack(
                gap: PlinthSize.xs,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      PlinthImage(
                        src: 'https://picsum.photos/id/${product.id}/240/240',
                        height: 96,
                        fit: BoxFit.cover,
                        radius: PlinthSize.xs,
                      ),
                      if (product.badge != null)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: PlinthBadge(
                            product.badge!,
                            color: product.badge == 'Sale' ? 'red' : 'blue',
                          ),
                        ),
                    ],
                  ),
                  PlinthText(product.name,
                      size: PlinthSize.sm, weight: FontWeight.w600),
                  PlinthText(product.price, size: PlinthSize.sm, color: 'gray'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: PlinthText(value,
              size: PlinthSize.sm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        PlinthCopyButton(value: value, size: PlinthSize.sm),
      ],
    );
  }
}
