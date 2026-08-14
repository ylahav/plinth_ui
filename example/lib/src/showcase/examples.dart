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
                    icon: const Icon(Icons.code, size: 16),
                    onPressed: () {},
                    variant: PlinthVariant.subtle,
                  ),
                  PlinthActionIcon(
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
                      icon: const Icon(Icons.code, size: 16),
                      onPressed: () {},
                      variant: PlinthVariant.subtle,
                    ),
                    PlinthActionIcon(
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
                  icon: const Icon(Icons.undo, size: 16),
                  variant: PlinthVariant.subtle,
                  onPressed: () {},
                ),
                const PlinthActionIcon(
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
                size: 120,
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
                  icon: Icon(item.icon, size: 18),
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
              icon: const Icon(Icons.dashboard_outlined, size: 18),
              active: true,
              onTap: () {},
            ),
            PlinthNavLink(
              label: 'Reports',
              icon: const Icon(Icons.insights_outlined, size: 18),
              onTap: () {},
            ),
            _heading('Settings'),
            PlinthNavLink(
              label: 'Members',
              icon: const Icon(Icons.people_outline, size: 18),
              trailing: const PlinthBadge('4'),
              onTap: () {},
            ),
            PlinthNavLink(
              label: 'Billing',
              icon: const Icon(Icons.credit_card, size: 18),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    for (final s in _segments)
                      Expanded(
                        flex: s.share,
                        child: ColoredBox(color: theme.shaded(s.color, 6)),
                      ),
                  ],
                ),
              ),
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
                    size: 72,
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
