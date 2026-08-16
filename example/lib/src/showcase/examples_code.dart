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
  'FooterWithNewsletterExample': r'''
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
              for (final icon in [
                Icons.code,
                Icons.chat_bubble_outline,
                Icons.alternate_email,
              ])
                PlinthActionIcon(
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
''',
  'FooterMinimalExample': r'''
// One line, for an app rather than a marketing page.
return Container(
  padding: EdgeInsets.symmetric(
    horizontal: theme.spacing[PlinthSize.md]!,
    vertical: theme.spacing[PlinthSize.xs]!,
  ),
  decoration: BoxDecoration(
    border: Border(top: BorderSide(color: theme.surfaceSunken)),
  ),
  child: Row(
    children: [
      PlinthIndicator(
        color: 'green',
        child: const SizedBox(width: 8, height: 8),
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
);
''',
  'AsymmetricGridExample': r'''
// PlinthGrid, not PlinthSimpleGrid: cells take different widths.
return const PlinthGrid(
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
);
''',
  'ImageGalleryGridExample': r'''
// Fixed ratios rather than fixed heights: images arrive at whatever
// size the server sends, and mismatched heights are the usual result.
return PlinthSimpleGrid(
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
  'FaqAccordionExample': r'''
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
''',
  'FaqWithContactExample': r'''
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
''',
  'UserButtonExample': r'''
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
''',
  'UserProfileCardExample': r'''
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
''',
  'ProjectCardExample': r'''
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
''',
  'TaskCardExample': r'''
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
''',
  'SingleCommentExample': r'''
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
''',
  'CommentThreadExample': r'''
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
''',
  'AnnouncementBannerExample': r'''
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
''',
  'ConsentBannerExample': r'''
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
''',
  'MemberTableExample': r'''
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
''',
  'InvoiceTableExample': r'''
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
                PlinthText(invoice.due,
                    size: PlinthSize.xs, color: 'gray'),
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
''',
  'SearchBarExample': r'''
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
''',
  'FilterFieldsExample': r'''
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
''',
  'ToolbarActionsExample': r'''
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
''',
  'DestructiveActionsExample': r'''
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
''',
  'PriceRangeFilterExample': r'''
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
''',
  'SettingSlidersExample': r'''
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
''',
  'DashboardGridExample': r'''
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
''',
  'CardGalleryGridExample': r'''
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
''',
  'ContactFormExample': r'''
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
''',
  'ContactWithDetailsExample': r'''
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
''',
  'FileDropzoneExample': r'''
PlinthFileInput<String>(
  label: 'Documents',
  description: 'PDF or PNG, up to 5 MB each',
  multiple: true,
  value: _files,
  // A real app opens file_picker here.
  onPick: () async => ['contract-${_files.length + 1}.pdf'],
  onChanged: (files) => setState(() => _files = files),
  labelBuilder: (file) => file,
)
''',
  'AvatarUploadExample': r'''
PlinthGroup(
  gap: PlinthSize.md,
  children: [
    PlinthAvatar(initials: 'AN', size: PlinthSize.xl),
    PlinthFileButton<String>(
      size: PlinthSize.sm,
      variant: PlinthVariant.outline,
      onPick: () async => ['avatar.png'],
      onChanged: (f) => setState(() => _picked = f.first),
      child: const Text('Upload'),
    ),
  ],
)
''',
  'ReorderableListExample': r'''
ReorderableListView(
  // onReorderItem hands back an index already adjusted for the
  // removed item, so the usual off-by-one dance isn't needed.
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
)
''',
  'KanbanDropExample': r'''
DragTarget<({String card, String from})>(
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
          weight: FontWeight.w700,
          // Highlighting the target is the whole feedback loop.
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
      ],
    ),
  ),
)
''',
  'ArticleContentsExample': r'''
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
)
''',
  'ArticleWithContentsRailExample': r'''
PlinthGroup(
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
      // SingleChildScrollView, not ListView: ensureVisible needs the
      // target already built.
      child: SingleChildScrollView(
        controller: _scroll,
        child: PlinthStack(
          children: [
            for (var i = 0; i < _sections.length; i++)
              PlinthTitle(_sections[i], key: _keys[i], order: 4),
          ],
        ),
      ),
    ),
  ],
)
''',
  'LiveMetricsExample': r'''
PlinthGroup(
  gap: PlinthSize.xl,
  children: [
    PlinthRollingNumber(
      value: _revenue,
      prefix: r'$',
      size: PlinthSize.xl,
      weight: FontWeight.w700,
    ),
    PlinthSemiCircleProgress(
      value: 0.62,
      size: 120,
      label: const PlinthText('62%', weight: FontWeight.w700),
    ),
  ],
)
''',
  'SortableTableExample': r'''
PlinthStack(
  gap: PlinthSize.sm,
  children: [
    PlinthTextInput(
      placeholder: 'Filter members…',
      leadingIcon: const Icon(Icons.search, size: 18),
      onChanged: (v) => setState(() => _query = v),
    ),
    PlinthTable.text(
      columns: const ['Name', 'Role', 'Commits'],
      // Sortable and filterable because the values are strings — a
      // widget-cell table needs sortValues alongside.
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
)
''',
  'PasswordStrengthExample': r'''
// Not const: a record holding a closure can't be. Keeping each rule
// beside its test is what stops the checklist from drifting out of
// step with what actually passes.
static final _rules = <({String label, bool Function(String) met})>[
  (label: 'At least 8 characters', met: (v) => v.length >= 8),
  (label: 'Includes a number', met: (v) => v.contains(RegExp(r'\d'))),
  (label: 'Includes a capital letter', met: (v) => v.contains(RegExp('[A-Z]'))),
  (label: 'Includes a symbol', met: (v) => v.contains(RegExp(r'[!@#$%^&*]'))),
];

final met = _rules.where((r) => r.met(_value)).length;
final strength = met / _rules.length;

return PlinthStack(
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
      // Three bands rather than a gradient: the useful question is
      // whether this will be accepted.
      color: strength == 1
          ? 'green'
          : strength >= 0.5
              ? 'yellow'
              : 'red',
    ),
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
);
''',
  'VerificationCodeExample': r'''
return PlinthPaper(
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
      PlinthPinInput(
        length: 6,
        value: _code,
        // Checked on completion rather than per keystroke: a
        // half-typed code is not a wrong code, and marking it red
        // while someone is still typing says otherwise.
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
);
''',
  'SecretFieldExample': r'''
// A field nobody types into: the value arrives from the server, and
// the arrangement exists to get it back out again intact.
final _controller = TextEditingController(text: 'pk_live_4f8Xq2Lm90Zt');

return PlinthStack(
  gap: PlinthSize.xs,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          // A password field for its reveal toggle rather than for
          // secrecy — a key on screen in a shared window is a key in
          // a screenshot.
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
);
''',
  'AddressFormExample': r'''
// A fieldset rather than a heading above the fields: it names the
// group for a screen reader too, so the field is announced as
// "Shipping address, City" rather than a bare "City".
return PlinthFieldset(
  legend: 'Shipping address',
  child: PlinthGrid(
    gutter: PlinthSize.sm,
    children: [
      // Spans rather than a stack of full-width fields: a postcode box
      // as wide as the street line invites the wrong thing to be typed
      // into it.
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
);
''',
  'FormattedFieldsExample': r'''
PlinthStack(
  gap: PlinthSize.sm,
  children: [
    PlinthMaskInput(
      mask: '(###) ###-####',
      label: 'Support line',
      onChanged: (_) {},
    ),
    PlinthColorInput(
      label: 'Brand colour',
      value: _brand,
      onChanged: (c) => setState(() => _brand = c),
      swatches: const [Color(0xFF2F9E44), Color(0xFF1971C2)],
    ),
    const PlinthJsonInput(
      label: 'Webhook payload',
      description: 'Validated when you click away',
      minLines: 3,
    ),
  ],
)
''',
  'CollapsibleNavbarExample': r'''
SizedBox(
  // The rail changes width rather than disappearing, so the icons
  // stay reachable while collapsed.
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
)
''',
  'NavbarWithSublevelsExample': r'''
// A hierarchy you navigate *into*, where the sectioned navbar's
// headings are flat destinations that merely group. The difference
// shows in the state: one branch open at a time, and the parent is
// not itself a place you can be.
return PlinthPaper(
  p: PlinthSize.sm,
  withBorder: true,
  child: PlinthStack(
    gap: PlinthSize.xs,
    children: [
      for (final section in _sections) ...[
        PlinthNavLink(
          label: section.label,
          icon: Icon(section.icon, size: 18),
          trailing: Icon(
            _open == section.label ? Icons.expand_less : Icons.expand_more,
            size: 16,
          ),
          onTap: () => setState(
            () => _open = _open == section.label ? '' : section.label,
          ),
        ),
        PlinthCollapse(
          opened: _open == section.label,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: PlinthStack(
              gap: PlinthSize.xs,
              children: [
                for (final child in section.children)
                  PlinthNavLink(
                    label: child,
                    active: _active == child,
                    onTap: () => setState(() => _active = child),
                  ),
              ],
            ),
          ),
        ),
      ],
    ],
  ),
);
''',
  'NavbarWithFooterUserExample': r'''
// A real height rather than shrink-wrapping: the arrangement is what
// a navbar does with the space *between* its two ends.
return SizedBox(
  width: 240,
  height: 340,
  child: PlinthPaper(
    p: PlinthSize.sm,
    withBorder: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Workspace at the top, account at the bottom, links between:
        // the two things you switch rarely bracket the one you use
        // constantly.
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
          icon: const Icon(Icons.dashboard_outlined, size: 18),
          active: true,
          onTap: () {},
        ),
        PlinthNavLink(
          label: 'Inbox',
          icon: const Icon(Icons.inbox_outlined, size: 18),
          trailing: const PlinthBadge('12', color: 'red'),
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
''',
  'SectionedNavbarExample': r'''
PlinthStack(
  gap: PlinthSize.xs,
  children: [
    // Headings rather than a tree: flat destinations that happen to
    // group, not a hierarchy you navigate into.
    _heading('Workspace'),
    PlinthNavLink(
      label: 'Overview',
      icon: const Icon(Icons.dashboard_outlined, size: 18),
      active: true,
      onTap: () {},
    ),
    _heading('Settings'),
    PlinthNavLink(
      label: 'Members',
      icon: const Icon(Icons.people_outline, size: 18),
      trailing: const PlinthBadge('4'),
      onTap: () {},
    ),
  ],
)
''',
  'NavbarWithSearchExample': r'''
Row(
  children: [
    const PlinthText('Acme', size: PlinthSize.lg, weight: FontWeight.w700),
    const SizedBox(width: 24),
    // A navbar carrying a control rather than only links.
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
    const PlinthAvatar(initials: 'YL', size: PlinthSize.sm),
  ],
)
''',
  'HeaderWithTabsExample': r'''
PlinthStack(
  gap: PlinthSize.sm,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const PlinthText('Plinth UI', size: PlinthSize.xl, weight: FontWeight.w700),
    // Tabs belong to the header: the title stays put while the
    // section below it changes.
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
)
''',
  'HeaderWithFiltersExample': r'''
PlinthStack(
  gap: PlinthSize.sm,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        const PlinthText('Issues', size: PlinthSize.xl, weight: FontWeight.w700),
        const SizedBox(width: 8),
        const PlinthBadge('128', color: 'gray'),
        const Spacer(),
        PlinthButton(onPressed: () {}, child: const Text('New issue')),
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
          child: PlinthTextInput(placeholder: 'Filter…', size: PlinthSize.sm),
        ),
      ],
    ),
  ],
)
''',
  'StickyHeaderExample': r'''
// A fixed row plus a scrolling Expanded, rather than a SliverAppBar:
// the header never moves, so there is no collapse behaviour to tune.
Column(
  children: [
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.plinth.surfaceSunken),
        ),
      ),
      child: const PlinthText('Changelog', weight: FontWeight.w700),
    ),
    Expanded(
      child: ListView.builder(
        itemCount: 12,
        itemBuilder: (context, i) => PlinthText('Release 0.${16 - i}.0'),
      ),
    ),
  ],
)
''',
  'UserMenuExample': r'''
PlinthMenu(
  controller: _menu,
  items: [
    PlinthMenuItem(label: 'Profile', onTap: () {}),
    PlinthMenuItem(label: 'Settings', onTap: () {}),
    PlinthMenuItem(label: 'Sign out', onTap: () {}),
  ],
  // The whole control is the trigger, not a separate caret — the
  // avatar and name are what people aim at.
  target: const PlinthGroup(
    gap: PlinthSize.xs,
    children: [
      PlinthAvatar(initials: 'YL', size: PlinthSize.sm),
      PlinthStack(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthText('Yair Lahav', weight: FontWeight.w600),
          PlinthText('Owner', size: PlinthSize.xs, color: 'gray'),
        ],
      ),
      Icon(Icons.keyboard_arrow_down, size: 16),
    ],
  ),
)
''',
  'MemberListExample': r'''
PlinthStack(
  gap: PlinthSize.sm,
  children: [
    const Row(
      children: [
        Expanded(child: PlinthText('Members', weight: FontWeight.w700)),
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
      PlinthGroup(
        gap: PlinthSize.sm,
        children: [
          PlinthAvatar(initials: m.initials, size: PlinthSize.sm),
          Expanded(child: PlinthText(m.name, size: PlinthSize.sm)),
          PlinthBadge(m.role, color: m.color),
        ],
      ),
  ],
)
''',
  'ImageCarouselExample': r'''
return PlinthPaper(
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
        // photograph is the arrangement that goes wrong on a light
        // image, and this one can't.
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
);
''',
  'ProductCarouselExample': r'''
// A row of cards that runs past the edge rather than a grid that
// wraps: this is a shelf you browse sideways, and slideSize below 1
// leaves the next card half-visible so it reads as one.
return PlinthCarousel(
  // Tall enough for the card's own padding as well as its content: a
  // slide clips rather than growing to fit.
  height: 224,
  slideSize: 0.38,
  withIndicators: false,
  slides: [
    for (final product in _products)
      PlinthCard(
        withBorder: true,
        // A fixed thumbnail height rather than a Spacer: a slide
        // shrink-wraps its content, so a flex child inside one has no
        // remaining space to claim and throws.
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
);
''',
  'AccountSwitcherExample': r'''
// Every account stays listed with the current one marked, rather than
// one row you press to cycle: switching identity is worth seeing
// before you commit to it.
return PlinthPaper(
  withBorder: true,
  p: PlinthSize.sm,
  child: PlinthStack(
    gap: PlinthSize.xs,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
                PlinthAvatar(initials: account.initials, size: PlinthSize.sm),
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
                  Icon(Icons.check, size: 16, color: theme.shaded('blue', 6)),
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
);
''',
  'UserContactCardExample': r'''
// A person as a set of facts you need to *use*, rather than a profile
// you look at — so each row carries the action that goes with it
// instead of being plain text.
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

// …used beneath the identity block:
const PlinthDivider(),
_ContactRow(icon: Icons.alternate_email, value: 'cara@example.com'),
_ContactRow(icon: Icons.phone_outlined, value: '+351 912 345 678'),
_ContactRow(icon: Icons.schedule, value: 'WEST · 2 hours ahead'),
''',
  'UserStatusExample': r'''
PlinthStack(
  gap: PlinthSize.sm,
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
        PlinthText(_status, size: PlinthSize.xs, color: 'gray'),
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
)
''',
  'PricingCardExample': r'''
PlinthCard(
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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // The price is what's being compared, so it carries the weight
      // rather than the plan name above it.
      PlinthGroup(
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
        ],
      ),
    ],
  ),
)
''',
  'MediaCardExample': r'''
PlinthCard(
  withBorder: true,
  // The image is the header rather than a child, so it runs to the
  // card's edges instead of sitting inside its padding.
  header: const PlinthBackgroundImage(
    src: 'https://picsum.photos/seed/plinth-card/600/240',
    height: 120,
    child: PlinthTitle('Kyoto', order: 4),
  ),
  child: PlinthStack(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PlinthText('Twelve temples, two days.', size: PlinthSize.sm),
      PlinthGroup(
        children: [
          const PlinthBadge('Travel'),
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
)
''',
  'ActivityCardExample': r'''
PlinthCard(
  withBorder: true,
  header: const PlinthText('Deployment', weight: FontWeight.w700),
  // A card whose body is a sequence rather than a paragraph — the
  // arrangement a status panel actually needs.
  child: PlinthTimeline(
    items: [
      PlinthTimelineItem(title: 'Queued', description: '14:02', active: true),
      PlinthTimelineItem(title: 'Building', description: '14:03', active: true),
      PlinthTimelineItem(title: 'Deploying', description: 'Pending'),
    ],
  ),
)
''',
  'StatWithPeriodExample': r'''
PlinthStack(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const PlinthText('Revenue', size: PlinthSize.sm, color: 'gray'),
    // The number rolls between periods rather than swapping, which is
    // the one place an animated figure earns itself: it shows the two
    // values are the same measure.
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
)
''',
  'StatBreakdownExample': r'''
PlinthStack(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const PlinthNumberFormatter(
      value: 18420,
      size: PlinthSize.xl,
      weight: FontWeight.w700,
    ),
    // A part-to-whole bar rather than three separate figures: the
    // point here is the proportion, which separate numbers make you
    // compute yourself.
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
  ],
)
''',
  'FaqTwoColumnExample': r'''
// Everything open in two columns rather than an accordion. For four
// short answers, hiding them behind a click costs more than the
// vertical space it saves.
PlinthSimpleGrid(
  columns: 2,
  children: [
    for (final f in _faqs)
      PlinthStack(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthText(f.q, weight: FontWeight.w700),
          PlinthText(f.a, size: PlinthSize.sm, color: 'gray'),
        ],
      ),
  ],
)
''',
  'FaqSearchExample': r'''
PlinthStack(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    PlinthTextInput(
      placeholder: 'Search questions…',
      onChanged: (v) => setState(() => _query = v),
    ),
    if (matches.isEmpty)
      // A search that can return nothing needs to say so; an empty
      // accordion just looks broken.
      const PlinthEmptyState(title: 'No matching questions')
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
)
''',
  'SupportChannelsExample': r'''
// Routing rather than a form: when several channels exist, the
// reader's first decision is which one, and a form presumes that
// answer for them.
PlinthSimpleGrid(
  columns: 3,
  children: [
    for (final c in _channels)
      PlinthPaper(
        p: PlinthSize.md,
        withBorder: true,
        child: PlinthStack(
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
)
''',
  'ContactWithHoursExample': r'''
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: PlinthStack(
        children: [
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
      child: PlinthDataList(
        orientation: PlinthDataListOrientation.vertical,
        items: [
          PlinthDataListItem.text('Weekdays', 'Within 4 hours'),
          PlinthDataListItem.text('Timezone', 'UTC+0'),
        ],
      ),
    ),
  ],
)
''',
  'PromoBannerExample': r'''
Row(
  children: [
    const PlinthBadge('Offer', color: 'grape'),
    const Expanded(
      child: PlinthText('Annual plans are 20% off until Friday.'),
    ),
    PlinthButton(
      size: PlinthSize.xs,
      color: 'grape',
      onPressed: () {},
      child: const Text('See plans'),
    ),
    // Dismissible, unlike the consent banner: a promo the reader has
    // declined should not keep asking.
    PlinthCloseButton(
      size: PlinthSize.xs,
      onPressed: () => setState(() => _visible = false),
      semanticLabel: 'Dismiss offer',
    ),
  ],
)
''',
  'UpdateBannerExample': r'''
PlinthAlert(
  title: 'Version 0.17.0 is available',
  icon: const Icon(Icons.system_update_alt),
  child: PlinthGroup(
    children: [
      // Two actions, and the passive one is not a dismissal: an update
      // banner that can only be closed teaches people to close it.
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
)
''',
  'HeroWithImageExample': r'''
// The photograph is the hero rather than sitting beside it. The scrim
// is doing real work: over the light half of this image the headline
// would otherwise disappear.
PlinthBackgroundImage(
  src: 'https://picsum.photos/seed/plinth-hero/1200/600',
  height: 240,
  scrimOpacity: 0.5,
  child: PlinthStack(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const PlinthTitle('Build it once', order: 2),
      PlinthButton(onPressed: () {}, child: const Text('Get started')),
    ],
  ),
)
''',
  'HeroWithSignupExample': r'''
PlinthStack(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const PlinthTitle('Ship your design system', order: 2),
    // The conversion control lives in the hero rather than behind a
    // button: one fewer step between reading the claim and acting.
    Row(
      children: [
        const Expanded(
          child: PlinthTextInput(placeholder: 'you@example.com'),
        ),
        const SizedBox(width: 8),
        PlinthButton(onPressed: () {}, child: const Text('Start free')),
      ],
    ),
  ],
)
''',
  'HeroWithProofExample': r'''
PlinthStack(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const PlinthTitle('Trusted where it counts', order: 2),
    const PlinthDivider(),
    // Evidence under the claim rather than a second paragraph
    // asserting it. Numbers are the part a reader can check.
    PlinthGroup(
      gap: PlinthSize.xl,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final p in _proof)
          PlinthStack(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PlinthText(p.value, size: PlinthSize.xl, weight: FontWeight.w700),
              PlinthText(p.label, size: PlinthSize.xs, color: 'gray'),
            ],
          ),
      ],
    ),
  ],
)
''',
  'FeatureWithScreenshotExample': r'''
// Text and image alternating sides down the page. Showing one pair is
// the point: the arrangement is the repeat, not the single row.
Row(
  children: [
    const Expanded(
      child: PlinthStack(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthBadge('Theming', color: 'violet'),
          PlinthTitle('One token, every component', order: 4),
          PlinthText('Change the primary colour and the library follows.',
              size: PlinthSize.sm, color: 'gray'),
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
)
''',
  'FeatureComparisonExample': r'''
// A matrix rather than three cards: the reader's question is what
// differs between plans, and columns answer it directly where cards
// make them hold three lists in their head.
const PlinthTable(
  columns: ['Feature', 'Free', 'Pro'],
  rows: [
    [PlinthText('Components'), PlinthText('All'), PlinthText('All')],
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
)
''',
  'FeatureLogoStripExample': r'''
// A marquee rather than a static row: a logo strip usually has more
// names than fit, and this shows them all without a second line. It
// stops under the pointer and never starts under reduce-motion.
const PlinthMarquee(
  speed: 25,
  child: PlinthGroup(
    wrap: false,
    gap: PlinthSize.xl,
    children: [
      PlinthText('ACME', weight: FontWeight.w700),
      PlinthText('GLOBEX', weight: FontWeight.w700),
      PlinthText('INITECH', weight: FontWeight.w700),
    ],
  ),
)
''',
  'SliderWithMarksExample': r'''
PlinthSlider(
  value: _value,
  max: 4,
  // Discrete rather than continuous: the marks below are the real
  // scale, so a value between them would be a position no label can
  // name.
  divisions: 4,
  label: _marks[_value.round()],
  onChanged: (v) => setState(() => _value = v),
)
''',
  'BudgetSliderExample': r'''
PlinthStack(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Formatted rather than raw: a slider reporting "2400" leaves the
    // reader to supply the currency and separators the figure means
    // nothing without.
    PlinthNumberFormatter(
      value: _budget.round(),
      prefix: r'$',
      size: PlinthSize.lg,
      weight: FontWeight.w700,
    ),
    PlinthSlider(
      value: _budget,
      min: 500,
      max: 10000,
      divisions: 19,
      onChanged: (v) => setState(() => _budget = v),
    ),
  ],
)
''',
  'ColourControlsExample': r'''
// Two slider types driving one preview. On their own the colour
// sliders look like decoration; the swatch is what makes them read as
// controls.
Row(
  children: [
    Expanded(
      child: PlinthStack(
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
    Container(
      width: 96,
      height: 72,
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ],
)
''',
  'SplitButtonExample': r'''
// The common action stays one tap away; the alternatives hide behind
// the caret. A plain menu would cost a tap for the thing people pick
// nine times in ten.
PlinthButtonGroup(
  children: [
    PlinthButton(onPressed: () {}, child: const Text('Deploy')),
    PlinthMenu(
      controller: _menu,
      items: [
        PlinthMenuItem(label: 'Deploy to staging', onTap: () {}),
        PlinthMenuItem(label: 'Dry run', onTap: () {}),
      ],
      target: PlinthButton(
        onPressed: _menu.toggle,
        child: const Icon(Icons.keyboard_arrow_down, size: 16),
      ),
    ),
  ],
)
''',
  'AsyncButtonExample': r'''
PlinthButton(
  // Null while busy rather than a separate flag: the button is
  // disabled for the same reason it shows a spinner, so one piece of
  // state drives both and they cannot disagree.
  onPressed: _busy ? null : _run,
  leadingIcon: _busy
      ? const PlinthLoader(size: PlinthSize.xs)
      : const Icon(Icons.cloud_upload_outlined, size: 16),
  child: Text(_busy ? 'Publishing…' : 'Publish'),
)
''',
  'ConfirmInlineExample': r'''
// Two steps in place rather than a modal. A modal is right when the
// consequence needs explaining; for a single reversible row it costs a
// dialog to answer a question the button can ask itself.
if (!_confirming) {
  return PlinthButton(
    variant: PlinthVariant.subtle,
    color: 'red',
    onPressed: () => setState(() => _confirming = true),
    child: const Text('Delete project'),
  );
}

return PlinthGroup(
  children: [
    const PlinthText('Delete permanently?', size: PlinthSize.sm),
    PlinthButton(
      size: PlinthSize.sm,
      color: 'red',
      onPressed: _delete,
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
''',
  'HorizontalArticleCardExample': r'''
// Horizontal rather than stacked: a feed of these fits far more
// articles on screen, and the image can shrink without the headline
// reflowing.
Row(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthBadge('Engineering', color: 'blue'),
          PlinthText('What a render object is actually for',
              weight: FontWeight.w700),
          PlinthText(
            'Most layout problems are solved by composition.',
            size: PlinthSize.sm,
            color: 'gray',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  ],
)
''',
  'OverlayArticleCardExample': r'''
// Text over the photograph rather than beneath it. This only works
// because PlinthBackgroundImage lays a scrim between the two — over a
// light photo the same text would be unreadable.
const PlinthBackgroundImage(
  src: 'https://picsum.photos/seed/plinth-overlay/600/400',
  height: 200,
  alignment: Alignment.bottomLeft,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: PlinthStack(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlinthBadge('Travel', color: 'teal'),
        PlinthText('Two days in Kyoto',
            size: PlinthSize.lg, weight: FontWeight.w700),
        PlinthText('12 August · 4 min read', size: PlinthSize.xs),
      ],
    ),
  ),
)
''',
  'QuoteArticleCardExample': r'''
const PlinthStack(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // The pull-quote is the card. A headline would compete with it, so
    // the attribution does the naming instead.
    PlinthBlockquote(
      quote: 'A component library is a set of decisions you only have '
          'to make once.',
      citation: 'Design systems, in practice',
    ),
    PlinthGroup(
      children: [
        PlinthAvatar(initials: 'AN', size: PlinthSize.sm),
        PlinthText('Alice Nguyen',
            size: PlinthSize.xs, weight: FontWeight.w600),
      ],
    ),
  ],
)
''',
  'ArticleListItemExample': r'''
// Dense rows rather than cards: a "related articles" list is scanned,
// not browsed, so every pixel of chrome per item is one fewer item on
// screen.
PlinthStack(
  gap: PlinthSize.xs,
  children: [
    const PlinthText('Most read', weight: FontWeight.w700),
    for (final a in _articles) ...[
      const PlinthDivider(),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: PlinthText(a.n,
                size: PlinthSize.lg, weight: FontWeight.w700, color: 'gray'),
          ),
          Expanded(child: PlinthText(a.title, size: PlinthSize.sm)),
          Icon(Icons.chevron_right, size: 16, color: theme.textMuted),
        ],
      ),
    ],
  ],
)
''',
  'PasswordResetExample': r'''
PlinthStack(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const PlinthTitle('Reset your password', order: 4),
    const PlinthTextInput(label: 'Email', placeholder: 'you@example.com'),
    PlinthButton(
      fullWidth: true,
      onPressed: () {},
      child: const Text('Send reset link'),
    ),
    // The way back matters as much as the way forward: a reset screen
    // with no exit strands anyone who mistyped the URL.
    Center(child: PlinthAnchor('Back to sign in', onTap: () {})),
  ],
)
''',
  'TwoFactorExample': r'''
PlinthStack(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const PlinthTitle('Two-factor code', order: 4),
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
  ],
)
''',
  'SplitAuthExample': r'''
Row(
  children: [
    // The brand half is decoration: first in the tree but carrying no
    // focusable content, so a screen reader reaches the form directly.
    const Expanded(
      child: PlinthBackgroundImage(
        src: 'https://picsum.photos/seed/plinth-auth/600/600',
        height: double.infinity,
        child: PlinthTitle('Build faster', order: 3),
      ),
    ),
    Expanded(
      child: PlinthStack(
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
  ],
)
''',
  'MaintenanceExample': r'''
PlinthEmptyState(
  icon: const Icon(Icons.build_outlined),
  title: 'Down for maintenance',
  description: 'We are upgrading the database. Back at 14:30 UTC.',
  // The one error state where the useful action is elsewhere, so it
  // points at status rather than offering a retry that cannot succeed.
  action: PlinthButton(
    variant: PlinthVariant.outline,
    onPressed: () {},
    child: const Text('Status page'),
  ),
)
''',
  'PermissionDeniedExample': r'''
PlinthStack(
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
    // Naming who can help turns a dead end into a next step —
    // "contact an administrator" rarely says which one.
    const PlinthDataList(
      items: [
        PlinthDataListItem.text('Workspace', 'Acme design'),
        PlinthDataListItem.text('Owner', 'alice@acme.com'),
      ],
    ),
  ],
)
''',
  'OfflineExample': r'''
PlinthStack(
  children: [
    const PlinthAlert(
      title: 'You are offline',
      color: 'yellow',
      icon: Icon(Icons.wifi_off),
      child: Text('Changes are saved locally and will sync later.'),
    ),
    // Unlike the other error states this one resolves itself, so the
    // page keeps working rather than replacing itself with an apology.
    const PlinthDataList(
      items: [
        PlinthDataListItem.text('Queued changes', '3'),
        PlinthDataListItem.text('Last synced', '11:42'),
      ],
    ),
    PlinthButton(
      variant: PlinthVariant.outline,
      onPressed: () {},
      child: const Text('Retry now'),
    ),
  ],
)
''',
  'StatWithSparklineExample': r'''
/// No axes, no ticks, no labels. A sparkline answers "which way, and
/// how steadily" beside a number that already answers "how much" —
/// anything more turns the card into a report.
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
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}

// …and in the card, beneath the figure:
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
''',
  'StatLeaderboardExample': r'''
// Shares are measured against the leader, not the total: the question
// a ranking answers is "how far behind is second", and dividing by a
// total nobody sees makes every bar look small.
final top = _rows.first.views;

return PlinthPaper(
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
);
''',
  'StatGoalRingsExample': r'''
PlinthGroup(
  gap: PlinthSize.xl,
  children: [
    for (final g in _goals)
      PlinthStack(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rings rather than bars: these are three unrelated targets,
          // not parts of one total, and a row of bars would imply they
          // add up.
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
)
''',
};
