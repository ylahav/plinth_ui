/// Source snippets for each example's "Show code" panel, transcribed
/// from the matching widget classes in `examples.dart`.
///
/// Keyed by class name (e.g. 'SimpleNavbarExample'), referenced
/// from showcase_data.dart's ExampleEntry.code.
///
/// These are hand-maintained string literals, not extracted at build
/// time — nothing enforces that they match, so **edit the snippet
/// here whenever you change the example it mirrors**. A stale snippet
/// still compiles and still renders a working code panel, which is
/// exactly why the drift is easy to miss.
const Map<String, String> exampleCode = {
  'SimpleNavbarExample': r'''
PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: Row(
        children: [
          const PlinthText('Acme', size: PlinthSize.lg, weight: FontWeight.w700),
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
''',
  'NavbarWithAvatarExample': r'''
PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: Row(
        children: [
          const PlinthThemeIcon(icon: Icon(Icons.hexagon), variant: PlinthVariant.filled),
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
''',
  'CenteredHeaderExample': r'''
const PlinthCenter(
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
''',
  'HeaderWithBreadcrumbsExample': r'''
Column(
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
              child: PlinthText('Plinth UI', size: PlinthSize.xl, weight: FontWeight.w700),
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
''',
  'HeroCenteredExample': r'''
PlinthCenter(
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
''',
  'HeroSplitExample': r'''
Row(
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
''',
  'FeatureGridExample': r'''
PlinthSimpleGrid(
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
''',
  'FeatureListExample': r'''
const PlinthList(
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
''',
  'SimpleArticleCardExample': r'''
SizedBox(
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
            const PlinthText('Building a design system from scratch', weight: FontWeight.w600),
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
''',
  'ArticleCardWithAuthorExample': r'''
const SizedBox(
      width: 280,
      child: PlinthCard(
        withBorder: true,
        footer: PlinthGroup(
          gap: PlinthSize.xs,
          children: [
            PlinthAvatar(initials: 'YL', size: PlinthSize.sm),
            PlinthText('Yair Lahav', size: PlinthSize.xs, weight: FontWeight.w600),
            PlinthText('· Jan 12', size: PlinthSize.xs, color: 'gray'),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlinthText('Publishing your first Flutter package', weight: FontWeight.w600),
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
''',
  'AuthorInlineExample': r'''
const PlinthGroup(
      gap: PlinthSize.sm,
      children: [
        PlinthAvatar(initials: 'YL', size: PlinthSize.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PlinthText('Yair Lahav', weight: FontWeight.w600),
            PlinthText('Package maintainer', size: PlinthSize.xs, color: 'gray'),
          ],
        ),
      ],
    );
''',
  'AuthorCardExample': r'''
SizedBox(
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
''',
  'SignInFormExample': r'''
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
''',
  'SignUpFormExample': r'''
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
''',
  'StatTileRowExample': r'''
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
''',
  'StatWithProgressExample': r'''
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
''',
  'NotFoundPageExample': r'''
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
''',
  'ServerErrorPageExample': r'''
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
''',
  'SimpleFooterExample': r'''
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
''',
  'FooterWithLinkColumnsExample': r'''
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
''',
};
