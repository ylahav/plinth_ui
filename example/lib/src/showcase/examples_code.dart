// GENERATED FILE — DO NOT EDIT BY HAND.
//
// Written by `tool/generate_example_code.dart` from the real
// source of each block in `examples.dart`, so the "Show code"
// panel cannot drift from the widget it claims to describe.
//
// To change what a panel shows, change the block. Then run:
//
//     cd example && dart run tool/generate_example_code.dart
//
// `test/examples_code_fresh_test.dart` fails if you forget,
// which is the whole point of generating it.

/// Source of every showcase block, keyed by class name.
const Map<String, String> exampleCode = {
  'AccountSwitcherExample': r'''
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
              PlinthUserTile(
                initials: account.initials,
                name: account.name,
                detail: account.detail,
                onTap: () => setState(() => _current = account.name),
                trailing: account.name == _current
                    ? const Icon(Icons.check, size: 16)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
''',
  'ActivityCardExample': r'''
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
''',
  'AddressFormExample': r'''
class AddressFormExample extends StatelessWidget {
  const AddressFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    // 640 rather than 560: the grid's `xs` breakpoint is 576, and the
    // fieldset's padding comes off before the grid measures — at 560
    // every column was full width, so the 7/5 split this block exists
    // to show had never actually rendered here.
    return PlinthAddressForm(
      width: 640,
      legend: 'Shipping address',
      initialCountry: 'il',
      onChanged: (values) {},
      countries: const [
        PlinthAddressCountry(
            code: 'il', label: 'Israel', postcodeMask: '#######'),
        PlinthAddressCountry(code: 'gb', label: 'United Kingdom'),
        PlinthAddressCountry(
            code: 'pt', label: 'Portugal', postcodeMask: '####-###'),
      ],
    );
  }
}
''',
  'AnnouncementBannerExample': r'''
class AnnouncementBannerExample extends StatelessWidget {
  const AnnouncementBannerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthBannerBlock(
      title: 'Plinth UI 1.2.0 is out',
      message: 'Dark mode, contrast-aware colours, and three new form '
          'components.',
      color: 'grape',
      icon: const Icon(Icons.campaign_outlined),
      onClose: () {},
      actions: [
        PlinthAnchor('Read the changelog', size: PlinthSize.sm, onTap: () {}),
      ],
    );
  }
}
''',
  'ArticleCardWithAuthorExample': r'''
class ArticleCardWithAuthorExample extends StatelessWidget {
  const ArticleCardWithAuthorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthArticleCard(
      width: 300,
      category: const PlinthBadge('Engineering', color: 'blue'),
      title: 'Why the contrast floor is checked at lookup time',
      excerpt: 'Resolving colour when it is asked for, not when it is '
          'defined.',
      author: const PlinthUserTile(
        initials: 'YL',
        name: 'Yair Lahav',
        size: PlinthSize.sm,
      ),
      meta: '6 min',
      onTap: () {},
    );
  }
}
''',
  'ArticleContentsExample': r'''
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
              items: [
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
''',
  'ArticleListItemExample': r'''
class ArticleListItemExample extends StatelessWidget {
  const ArticleListItemExample({super.key});

  static const _articles = [
    'Building a design system from scratch',
    'Why the contrast floor is checked at lookup time',
    'Shade mirroring, and why dark mode is not an inversion',
  ];

  @override
  Widget build(BuildContext context) {
    // A dense feed: the same card with no picture, which is what a
    // list of headlines actually is.
    return SizedBox(
      width: 460,
      child: PlinthStack(
        gap: PlinthSize.xs,
        children: [
          for (final article in _articles)
            PlinthArticleCard(
              layout: PlinthArticleLayout.horizontal,
              title: article,
              meta: '5 min',
              onTap: () {},
            ),
        ],
      ),
    );
  }
}
''',
  'ArticleWithContentsRailExample': r'''
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
''',
  'AsymmetricGridExample': r'''
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
''',
  'AsyncButtonExample': r'''
class AsyncButtonExample extends StatelessWidget {
  const AsyncButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The busy state and the disabling come from one piece of state, so
    // they cannot disagree — and a second press while it runs cannot
    // start a second run.
    return PlinthAsyncButton(
      onPressed: () => Future<void>.delayed(const Duration(milliseconds: 900)),
      doneChild: const Text('Saved'),
      doneLabel: 'Saved',
      child: const Text('Save changes'),
    );
  }
}
''',
  'AuthorCardExample': r'''
class AuthorCardExample extends StatelessWidget {
  const AuthorCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The profile card, centred, with a bio instead of counts.
    return PlinthProfileCard(
      width: 260,
      initials: 'YL',
      name: 'Yair Lahav',
      nameOrder: 5,
      bio: 'Building Plinth UI, a Flutter component library.',
      actions: [
        PlinthButton(
          variant: PlinthVariant.outline,
          size: PlinthSize.sm,
          onPressed: () {},
          child: const Text('Follow'),
        ),
      ],
    );
  }
}
''',
  'AuthorInlineExample': r'''
class AuthorInlineExample extends StatelessWidget {
  const AuthorInlineExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Already a block: an author byline is the same row as a team
    // member and an account, so it is the same widget.
    return const SizedBox(
      width: 260,
      child: PlinthUserTile(
        initials: 'YL',
        name: 'Yair Lahav',
        detail: 'Package maintainer',
      ),
    );
  }
}
''',
  'AvatarUploadExample': r'''
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
''',
  'BarChartExample': r'''
class BarChartExample extends StatelessWidget {
  const BarChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Horizontal, because category names are words. Every bar is its
    // own semantics node, so a reader walks the figures rather than
    // hearing one sentence about all of them.
    return PlinthBarChart(
      width: 420,
      label: 'Sessions by source',
      describeValue: (v) => '${(v / 1000).toStringAsFixed(1)}k',
      bars: const [
        PlinthBar(label: 'Direct', value: 5200, seriesKey: 'direct'),
        PlinthBar(label: 'Search', value: 3100, seriesKey: 'search'),
        PlinthBar(label: 'Social', value: 1400, seriesKey: 'social'),
        PlinthBar(label: 'Referral', value: 820, seriesKey: 'referral'),
      ],
    );
  }
}
''',
  'BudgetSliderExample': r'''
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
''',
  'CardGalleryGridExample': r'''
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
''',
  'CenteredHeaderExample': r'''
class CenteredHeaderExample extends StatelessWidget {
  const CenteredHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlinthPageHeader(
      centered: true,
      title: 'Settings',
      subtitle: 'Manage your account preferences and integrations',
    );
  }
}
''',
  'CollapsibleNavbarExample': r'''
class CollapsibleNavbarExample extends StatefulWidget {
  const CollapsibleNavbarExample({super.key});

  @override
  State<CollapsibleNavbarExample> createState() =>
      _CollapsibleNavbarExampleState();
}

class _CollapsibleNavbarExampleState extends State<CollapsibleNavbarExample> {
  bool _collapsed = false;
  String _active = 'Home';

  @override
  Widget build(BuildContext context) {
    // The whole point of this variant: the rail changes width rather
    // than disappearing, so the icons stay reachable — and collapsed,
    // each one keeps the name a screen reader reads.
    return PlinthSidebar(
      height: 220,
      width: 200,
      collapsed: _collapsed,
      onToggleCollapsed: () => setState(() => _collapsed = !_collapsed),
      activeValue: _active,
      onSelect: (value) => setState(() => _active = value),
      sections: const [
        PlinthNavSection(
          items: [
            PlinthNavItem(
                label: 'Home', icon: Icon(Icons.home_outlined, size: 18)),
            PlinthNavItem(
                label: 'Projects', icon: Icon(Icons.folder_outlined, size: 18)),
            PlinthNavItem(
                label: 'Team', icon: Icon(Icons.people_outline, size: 18)),
          ],
        ),
      ],
    );
  }
}
''',
  'ColourControlsExample': r'''
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
''',
  'CommentThreadExample': r'''
class CommentThreadExample extends StatelessWidget {
  const CommentThreadExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Indent marks the reply as a reply — the whole reason a thread
    // reads differently to a list. It is also only visual, so the
    // nesting is announced as well as shown.
    return const PlinthCommentThread(
      width: 460,
      comments: [
        PlinthCommentData(
          initials: 'AB',
          author: 'Ada Byron',
          when: '2 hours ago',
          body: 'Does the shade mirroring apply to custom palettes too, '
              'or only the built-in ramps?',
          replies: [
            PlinthCommentData(
              initials: 'YL',
              author: 'Yair Lahav',
              when: '1 hour ago',
              body: 'Any ramp registered on the theme — mirroring is by '
                  'shade index, not by colour name.',
            ),
          ],
        ),
      ],
    );
  }
}
''',
  'ConfirmInlineExample': r'''
class ConfirmInlineExample extends StatelessWidget {
  const ConfirmInlineExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Two steps in place rather than a modal. A modal is right when the
    // consequence needs explaining; for a single reversible row it
    // costs a dialog to answer a question the button can ask itself.
    return PlinthConfirmButton(
      label: 'Delete project',
      icon: const Icon(Icons.delete_outline, size: 16),
      question: 'Delete permanently?',
      confirmLabel: 'Delete',
      onConfirm: () {},
    );
  }
}
''',
  'ConsentBannerExample': r'''
class ConsentBannerExample extends StatelessWidget {
  const ConsentBannerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthBannerBlock(
      layout: PlinthBannerLayout.bar,
      elevated: true,
      message: 'We use a single cookie to remember your theme. Nothing is '
          'shared with anyone.',
      // No onClose: a consent prompt somebody can wave away has not
      // obtained consent.
      actions: [
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
    );
  }
}
''',
  'ContactFormExample': r'''
class ContactFormExample extends StatelessWidget {
  const ContactFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthContactBlock(
      width: 420,
      subtitle: 'We usually reply within a working day.',
      onSubmit: (values) {},
    );
  }
}
''',
  'ContactWithDetailsExample': r'''
class ContactWithDetailsExample extends StatelessWidget {
  const ContactWithDetailsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthContactBlock(
      width: 560,
      title: 'Contact us',
      titleOrder: 4,
      onSubmit: (values) {},
      // The address beside the form rather than under it: somebody who
      // wanted the postal address never needed the form at all.
      aside: const PlinthSupportChannels(
        channels: [
          PlinthSupportChannel(
            icon: Icon(Icons.mail_outline),
            title: 'Email',
            detail: 'hello@plinth.dev',
          ),
          PlinthSupportChannel(
            icon: Icon(Icons.phone_outlined),
            title: 'Phone',
            detail: '+44 20 7946 0958',
          ),
          PlinthSupportChannel(
            icon: Icon(Icons.location_on_outlined),
            title: 'Office',
            detail: 'London, UK',
          ),
        ],
        columns: 1,
      ),
    );
  }
}
''',
  'ContactWithHoursExample': r'''
class ContactWithHoursExample extends StatelessWidget {
  const ContactWithHoursExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthContactBlock(
      width: 560,
      title: 'Talk to us',
      titleOrder: 4,
      showName: false,
      messageLabel: 'How can we help?',
      onSubmit: (values) {},
      // Setting expectations beside the form rather than after it:
      // knowing the reply window before writing changes what people
      // write, and whether they wait.
      aside: const PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthText('When we are around', weight: FontWeight.w600),
          PlinthDataList(
            items: [
              PlinthDataListItem.text('Mon–Fri', '9–17 UTC'),
              PlinthDataListItem.text('Saturday', '10–14 UTC'),
              PlinthDataListItem.text('Sunday', 'Closed'),
            ],
          ),
        ],
      ),
    );
  }
}
''',
  'DashboardGridExample': r'''
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
''',
  'DestructiveActionsExample': r'''
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
''',
  'DonutChartExample': r'''
class DonutChartExample extends StatelessWidget {
  const DonutChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // A ring rather than a bar because the total is the headline, which
    // is the one thing a segmented bar has nowhere to put. For every
    // other part-to-whole question, PlinthProgress.sections reads
    // better.
    return PlinthDonutChart(
      width: 320,
      label: 'Sessions by source',
      centreLabel: '10.5k',
      centreCaption: 'sessions',
      describeValue: (v) => '${(v / 1000).toStringAsFixed(1)}k',
      segments: const [
        PlinthDonutSegment(label: 'Direct', value: 5200, seriesKey: 'direct'),
        PlinthDonutSegment(label: 'Search', value: 3100, seriesKey: 'search'),
        PlinthDonutSegment(label: 'Social', value: 1400, seriesKey: 'social'),
        PlinthDonutSegment(
          label: 'Referral',
          value: 820,
          seriesKey: 'referral',
        ),
      ],
    );
  }
}
''',
  'FaqAccordionExample': r'''
class FaqAccordionExample extends StatelessWidget {
  const FaqAccordionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlinthFaqBlock(
      title: 'Frequently asked questions',
      width: 520,
      items: [
        PlinthFaqItem(
          question: 'When am I billed?',
          answer: 'On the same day each month, starting the day you upgrade. '
              'Downgrades take effect at the end of the current period.',
        ),
        PlinthFaqItem(
          question: 'Can I cancel at any time?',
          answer: 'Yes. Your plan stays active until the end of the period '
              'you have already paid for.',
        ),
        PlinthFaqItem(
          question: 'Do you offer a free tier?',
          answer: 'Everything in Plinth UI is MIT licensed, including for '
              'commercial use.',
        ),
      ],
    );
  }
}
''',
  'FaqSearchExample': r'''
class FaqSearchExample extends StatelessWidget {
  const FaqSearchExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlinthFaqBlock(
      title: 'Help centre',
      searchable: true,
      items: [
        PlinthFaqItem(
          question: 'When am I billed?',
          answer: 'On the same day each month, starting the day you upgrade. '
              'Downgrades take effect at the end of the current period.',
        ),
        PlinthFaqItem(
          question: 'Can I cancel at any time?',
          answer: 'Yes. Your plan stays active until the end of the period '
              'you have already paid for.',
        ),
        PlinthFaqItem(
          question: 'Do you offer a free tier?',
          answer: 'Everything in Plinth UI is MIT licensed, including for '
              'commercial use.',
        ),
      ],
    );
  }
}
''',
  'FaqTwoColumnExample': r'''
class FaqTwoColumnExample extends StatelessWidget {
  const FaqTwoColumnExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlinthFaqBlock(
      layout: PlinthFaqLayout.twoColumn,
      title: 'Common questions',
      items: [
        PlinthFaqItem(
          question: 'When am I billed?',
          answer: 'On the same day each month, starting the day you upgrade. '
              'Downgrades take effect at the end of the current period.',
        ),
        PlinthFaqItem(
          question: 'Can I cancel at any time?',
          answer: 'Yes. Your plan stays active until the end of the period '
              'you have already paid for.',
        ),
        PlinthFaqItem(
          question: 'Do you offer a free tier?',
          answer: 'Everything in Plinth UI is MIT licensed, including for '
              'commercial use.',
        ),
      ],
    );
  }
}
''',
  'FaqWithContactExample': r'''
class FaqWithContactExample extends StatelessWidget {
  const FaqWithContactExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthFaqBlock(
      title: 'Questions',
      subtitle: 'If yours is not here, we answer email within a day.',
      items: [
        PlinthFaqItem(
          question: 'When am I billed?',
          answer: 'On the same day each month, starting the day you upgrade. '
              'Downgrades take effect at the end of the current period.',
        ),
        PlinthFaqItem(
          question: 'Can I cancel at any time?',
          answer: 'Yes. Your plan stays active until the end of the period '
              'you have already paid for.',
        ),
        PlinthFaqItem(
          question: 'Do you offer a free tier?',
          answer: 'Everything in Plinth UI is MIT licensed, including for '
              'commercial use.',
        ),
      ],
      footer: PlinthButton(
        leadingIcon: const Icon(Icons.mail_outline, size: 16),
        onPressed: () {},
        child: const Text('Email support'),
      ),
    );
  }
}
''',
  'FeatureComparisonExample': r'''
class FeatureComparisonExample extends StatelessWidget {
  const FeatureComparisonExample({super.key});

  @override
  Widget build(BuildContext context) {
    // A matrix rather than three cards: the reader's question is what
    // differs between plans, and columns answer it directly where cards
    // make them hold three lists in their head.
    return PlinthComparisonBlock(
      width: 480,
      title: 'Compare plans',
      plans: const ['Free', 'Pro'],
      rows: const [
        PlinthComparisonRow(label: 'Components', values: ['All', 'All']),
        PlinthComparisonRow(label: 'Private themes', values: [false, true]),
        PlinthComparisonRow(label: 'Support', values: ['Community', 'Email']),
      ],
    );
  }
}
''',
  'FeatureGridExample': r'''
class FeatureGridExample extends StatelessWidget {
  const FeatureGridExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlinthFeatureBlock(
      features: [
        PlinthFeature(
          icon: Icon(Icons.bolt_outlined),
          title: 'Fast',
          description: 'Optimized rebuilds with no unnecessary widget churn.',
        ),
        PlinthFeature(
          icon: Icon(Icons.palette_outlined),
          title: 'Themeable',
          description: 'Every color, spacing, and radius token is overridable.',
        ),
        PlinthFeature(
          icon: Icon(Icons.accessibility_new),
          title: 'Accessible',
          description: 'Semantics built in, not bolted on afterward.',
        ),
      ],
    );
  }
}
''',
  'FeatureListExample': r'''
class FeatureListExample extends StatelessWidget {
  const FeatureListExample({super.key});

  @override
  Widget build(BuildContext context) {
    // No icons passed, so each row gets the default tick — resolved
    // against the surface rather than frozen at one hex, which is what
    // this block used to do.
    return const PlinthFeatureBlock(
      layout: PlinthFeatureLayout.list,
      features: [
        PlinthFeature(
          title: '117 themeable components, zero design-system lock-in',
        ),
        PlinthFeature(
          title: 'Widgetbook gallery for isolated visual development',
        ),
        PlinthFeature(title: 'Published on pub.dev, versioned semantically'),
      ],
    );
  }
}
''',
  'FeatureLogoStripExample': r'''
class FeatureLogoStripExample extends StatelessWidget {
  const FeatureLogoStripExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlinthLogoStrip(
      width: 480,
      label: 'BUILT WITH PLINTH',
      logos: [
        PlinthText('ACME', weight: FontWeight.w700),
        PlinthText('Globex', weight: FontWeight.w700),
        PlinthText('Initech', weight: FontWeight.w700),
        PlinthText('Umbrella', weight: FontWeight.w700),
      ],
    );
  }
}
''',
  'FeatureWithScreenshotExample': r'''
class FeatureWithScreenshotExample extends StatelessWidget {
  const FeatureWithScreenshotExample({super.key});

  static Widget _shot(String seed) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: PlinthImage(
          src: 'https://picsum.photos/seed/$seed/600/360',
          height: 130,
        ),
      );

  @override
  Widget build(BuildContext context) {
    // The sides alternate on their own. Doing it by hand is where a
    // row ends up on the same side as the one above it.
    return PlinthFeatureBlock(
      width: 560,
      layout: PlinthFeatureLayout.alternating,
      features: [
        PlinthFeature(
          eyebrow: 'Theming',
          title: 'One token, every component',
          description: 'Change the primary colour and the whole library '
              'follows, dark mode included.',
          media: _shot('plinth-f1'),
        ),
        PlinthFeature(
          eyebrow: 'Testing',
          title: 'Pinned where it matters',
          description: 'Golden images for the components that place things '
              'by arithmetic rather than by layout.',
          media: _shot('plinth-f2'),
        ),
      ],
    );
  }
}
''',
  'FileDropzoneExample': r'''
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
''',
  'FilterFieldsExample': r'''
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
''',
  'FooterMinimalExample': r'''
class FooterMinimalExample extends StatelessWidget {
  const FooterMinimalExample({super.key});

  @override
  Widget build(BuildContext context) {
    // One line, for an app rather than a marketing page: the footer of
    // a tool should take a row, not a screen, and status belongs where
    // it can be glanced at rather than hunted for.
    return PlinthFooter(
      width: 640,
      dense: true,
      leading: const PlinthIndicator(
        color: 'green',
        child: SizedBox(width: 8, height: 8),
      ),
      brand: 'All systems normal',
      copyright: 'v1.3.0',
      links: [
        PlinthAnchor('Status', size: PlinthSize.xs, onTap: () {}),
        PlinthAnchor('Docs', size: PlinthSize.xs, onTap: () {}),
        PlinthAnchor('Support', size: PlinthSize.xs, onTap: () {}),
      ],
    );
  }
}
''',
  'FooterWithLinkColumnsExample': r'''
class FooterWithLinkColumnsExample extends StatelessWidget {
  const FooterWithLinkColumnsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthFooter(
      width: 560,
      brand: 'Acme',
      copyright: '© 2026',
      columns: [
        PlinthFooterColumn(
          title: 'Product',
          links: [
            for (final link in ['Features', 'Pricing', 'Changelog'])
              PlinthAnchor(link, size: PlinthSize.sm, onTap: () {}),
          ],
        ),
        PlinthFooterColumn(
          title: 'Company',
          links: [
            for (final link in ['About', 'Careers', 'Blog'])
              PlinthAnchor(link, size: PlinthSize.sm, onTap: () {}),
          ],
        ),
        PlinthFooterColumn(
          title: 'Support',
          links: [
            for (final link in ['Docs', 'Status', 'Contact'])
              PlinthAnchor(link, size: PlinthSize.sm, onTap: () {}),
          ],
        ),
      ],
    );
  }
}
''',
  'FooterWithNewsletterExample': r'''
class FooterWithNewsletterExample extends StatelessWidget {
  const FooterWithNewsletterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthFooter(
      width: 560,
      brand: 'Plinth UI',
      copyright: 'A themeable component library for Flutter.',
      trailing: SizedBox(
        width: 260,
        child: Row(
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
      ),
    );
  }
}
''',
  'FormattedFieldsExample': r'''
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
''',
  'HeaderWithBreadcrumbsExample': r'''
class HeaderWithBreadcrumbsExample extends StatelessWidget {
  const HeaderWithBreadcrumbsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthPageHeader(
      title: 'Plinth UI',
      breadcrumbs: PlinthBreadcrumbs(
        items: [
          PlinthBreadcrumbItem(label: 'Home', onTap: () {}),
          PlinthBreadcrumbItem(label: 'Projects', onTap: () {}),
          const PlinthBreadcrumbItem(label: 'Plinth UI'),
        ],
      ),
      actions: [
        PlinthButton(
          onPressed: () {},
          leadingIcon: const Icon(Icons.add, size: 16),
          child: const Text('New release'),
        ),
      ],
    );
  }
}
''',
  'HeaderWithFiltersExample': r'''
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
    return PlinthPageHeader(
      title: 'Issues',
      // The count sits with the name rather than in the actions: it is
      // a fact about the page, and a reader hears "Issues, 128".
      titleTrailing: const PlinthBadge('128', color: 'gray'),
      actions: [
        PlinthButton(
          onPressed: () {},
          leadingIcon: const Icon(Icons.add, size: 16),
          child: const Text('New issue'),
        ),
      ],
      below: PlinthGroup(
        children: [
          PlinthSegmentedControl<String>(
            value: _view,
            onChanged: (v) => setState(() => _view = v),
            items: [
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
    );
  }
}
''',
  'HeaderWithTabsExample': r'''
class HeaderWithTabsExample extends StatefulWidget {
  const HeaderWithTabsExample({super.key});

  @override
  State<HeaderWithTabsExample> createState() => _HeaderWithTabsExampleState();
}

class _HeaderWithTabsExampleState extends State<HeaderWithTabsExample> {
  String _tab = 'overview';

  @override
  Widget build(BuildContext context) {
    return PlinthPageHeader(
      title: 'Plinth UI',
      actions: [
        PlinthButton(
          variant: PlinthVariant.outline,
          onPressed: () {},
          child: const Text('Share'),
        ),
      ],
      // Tabs belong to the header rather than the body: the title stays
      // put while the section below it changes.
      below: PlinthTabs<String>(
        value: _tab,
        onChanged: (t) => setState(() => _tab = t),
        tabs: const [
          PlinthTabItem('overview', 'Overview'),
          PlinthTabItem('activity', 'Activity'),
          PlinthTabItem('settings', 'Settings'),
        ],
      ),
    );
  }
}
''',
  'HeroCenteredExample': r'''
class HeroCenteredExample extends StatelessWidget {
  const HeroCenteredExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthHeroBlock(
      eyebrow: const PlinthBadge('New', color: 'grape'),
      headline: 'Build interfaces faster',
      subhead: 'A themeable Flutter component library for teams that ship.',
      actions: [
        PlinthButton(onPressed: () {}, child: const Text('Get started')),
        PlinthButton(
          onPressed: () {},
          variant: PlinthVariant.outline,
          child: const Text('Documentation'),
        ),
      ],
    );
  }
}
''',
  'HeroSplitExample': r'''
class HeroSplitExample extends StatelessWidget {
  const HeroSplitExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthHeroBlock(
      layout: PlinthHeroLayout.split,
      headline: 'Ship your product today',
      subhead: 'Every component is themeable, accessible, and tested.',
      actions: [
        PlinthButton(onPressed: () {}, child: const Text('Try it now')),
      ],
      aside: PlinthAspectRatio(
        ratio: 4 / 3,
        child: Container(
          decoration: BoxDecoration(
            color: context.plinth.shaded('blue', 0),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
''',
  'HeroWithImageExample': r'''
class HeroWithImageExample extends StatelessWidget {
  const HeroWithImageExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The photograph is the hero rather than sitting beside it. The
    // scrim is doing real work: over the light half of this image the
    // headline would otherwise disappear.
    return const PlinthHeroBlock(
      width: 560,
      backgroundImage: 'https://picsum.photos/seed/plinth-hero/1200/600',
      headline: 'Build it once',
      subhead: 'A themeable component library for Flutter.',
    );
  }
}
''',
  'HeroWithProofExample': r'''
class HeroWithProofExample extends StatelessWidget {
  const HeroWithProofExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthHeroBlock(
      width: 520,
      headline: 'Trusted where it counts',
      actions: [
        PlinthButton(onPressed: () {}, child: const Text('Read the docs')),
      ],
      // Evidence under the claim rather than a second paragraph
      // asserting it. Numbers are the part a reader can check.
      footer: const PlinthStatStrip(
        divider: true,
        stats: [
          PlinthStat(value: '117', label: 'components'),
          PlinthStat(value: '110', label: 'blocks'),
          PlinthStat(value: '160', label: 'pub points'),
        ],
      ),
    );
  }
}
''',
  'HeroWithSignupExample': r'''
class HeroWithSignupExample extends StatelessWidget {
  const HeroWithSignupExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthHeroBlock(
      width: 520,
      headline: 'Ship your design system',
      subhead: 'One install, 117 components, no lock-in.',
      // The conversion control lives in the hero rather than behind a
      // button: one fewer step between reading the claim and acting.
      footer: Row(
        children: [
          const Expanded(
            child: PlinthTextInput(placeholder: 'you@example.com'),
          ),
          const SizedBox(width: 8),
          PlinthButton(onPressed: () {}, child: const Text('Start free')),
        ],
      ),
    );
  }
}
''',
  'HorizontalArticleCardExample': r'''
class HorizontalArticleCardExample extends StatelessWidget {
  const HorizontalArticleCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Horizontal rather than stacked: a feed of these fits far more
    // articles on screen, and the image can shrink without the
    // headline reflowing.
    return const PlinthArticleCard(
      width: 460,
      layout: PlinthArticleLayout.horizontal,
      title: 'Shade mirroring, and why dark mode is not an inversion',
      excerpt: 'The ramps are shared between the themes; only the '
          'chrome flips.',
      meta: '4 min read',
      image: PlinthImage(src: 'https://picsum.photos/seed/plinth-row/480/480'),
    );
  }
}
''',
  'ImageCarouselExample': r'''
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
''',
  'ImageGalleryGridExample': r'''
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
''',
  'InvoiceTableExample': r'''
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
''',
  'KanbanDropExample': r'''
class KanbanDropExample extends StatefulWidget {
  const KanbanDropExample({super.key});

  @override
  State<KanbanDropExample> createState() => _KanbanDropExampleState();
}

class _KanbanDropExampleState extends State<KanbanDropExample> {
  final Map<String, List<String>> _cards = {
    'todo': ['Write tests'],
    'done': ['Set up CI'],
  };

  void _move(String card, String from, String to) {
    setState(() {
      _cards[from]!.remove(card);
      _cards[to]!.add(card);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Every move is available without a drag: each card is a button
    // that lists the other columns. A board that only accepts a pointer
    // gesture cannot be operated by keyboard at all.
    return PlinthKanbanBoard(
      onMove: _move,
      columns: [
        PlinthKanbanColumn(
          id: 'todo',
          title: 'To do',
          cards: _cards['todo']!,
        ),
        PlinthKanbanColumn(id: 'done', title: 'Done', cards: _cards['done']!),
      ],
    );
  }
}
''',
  'LineChartExample': r'''
class LineChartExample extends StatelessWidget {
  const LineChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Each line carries its own dash pattern as well as its own colour,
    // so the legend maps shape to name and not only hue — and the faint
    // series colours are lifted to the 3:1 non-text floor.
    return const PlinthLineChart(
      width: 460,
      label: 'Sessions by source',
      showArea: true,
      series: [
        PlinthChartSeries(
          name: 'Direct',
          seriesKey: 'direct',
          values: [820, 910, 880, 1040, 1180, 1120, 1310],
        ),
        PlinthChartSeries(
          name: 'Search',
          seriesKey: 'search',
          values: [540, 600, 720, 690, 810, 900, 980],
        ),
        PlinthChartSeries(
          name: 'Social',
          seriesKey: 'social',
          values: [210, 260, 240, 330, 300, 380, 420],
        ),
      ],
    );
  }
}
''',
  'LiveMetricsExample': r'''
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
''',
  'MaintenanceExample': r'''
class MaintenanceExample extends StatelessWidget {
  const MaintenanceExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlinthErrorPageBlock.maintenance(
      description: 'We are upgrading the database. Back by about 14:00 UTC.',
    );
  }
}
''',
  'MediaCardExample': r'''
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
''',
  'MemberListExample': r'''
class MemberListExample extends StatelessWidget {
  const MemberListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlinthMemberList(
      width: 360,
      title: 'Members',
      members: [
        PlinthMember(
          initials: 'AN',
          name: 'Alice Nguyen',
          role: 'Owner',
          roleColor: 'green',
        ),
        PlinthMember(
          initials: 'BK',
          name: 'Ben Kaur',
          role: 'Editor',
          roleColor: 'blue',
        ),
        PlinthMember(
          initials: 'CD',
          name: 'Cara Diaz',
          role: 'Viewer',
          roleColor: 'gray',
        ),
      ],
      // The people beyond the first few, without a second row.
      overflowAvatars: [
        PlinthAvatar(initials: 'AN', size: PlinthSize.sm),
        PlinthAvatar(initials: 'BK', size: PlinthSize.sm),
        PlinthAvatar(initials: 'CD', size: PlinthSize.sm),
        PlinthAvatar(initials: 'EF', size: PlinthSize.sm),
        PlinthAvatar(initials: 'GH', size: PlinthSize.sm),
      ],
    );
  }
}
''',
  'MemberTableExample': r'''
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
''',
  'NavbarWithAvatarExample': r'''
class NavbarWithAvatarExample extends StatelessWidget {
  const NavbarWithAvatarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthTopBar(
      brand: const PlinthTopBarBrand(
        title: 'Dashboard',
        icon: Icon(Icons.hexagon),
      ),
      actions: [
        PlinthActionIcon(
          semanticLabel: 'Notifications',
          icon: const Icon(Icons.notifications_none, size: 18),
          onPressed: () {},
          variant: PlinthVariant.subtle,
        ),
        const PlinthAvatar(initials: 'YL', size: PlinthSize.sm),
      ],
    );
  }
}
''',
  'NavbarWithFooterUserExample': r'''
class NavbarWithFooterUserExample extends StatelessWidget {
  const NavbarWithFooterUserExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Workspace at the top, account at the bottom, links in between:
    // the two things you switch rarely bracket the one you use
    // constantly. A real height rather than shrink-wrapping, because
    // the arrangement being shown is what a navbar does with the space
    // *between* its two ends.
    return PlinthSidebar(
      width: 240,
      height: 340,
      activeValue: 'Overview',
      header: PlinthUnstyledButton(
        onPressed: () {},
        child: PlinthPaper(
          p: PlinthSize.xs,
          child: const Row(
            children: [
              PlinthAvatar(initials: 'AC', size: PlinthSize.sm),
              SizedBox(width: 8),
              Expanded(
                child: PlinthText(
                  'Acme Corp',
                  size: PlinthSize.sm,
                  weight: FontWeight.w600,
                ),
              ),
              Icon(Icons.unfold_more, size: 16),
            ],
          ),
        ),
      ),
      footer: const PlinthUserTile(
        initials: 'YL',
        name: 'Yair Lahav',
        size: PlinthSize.sm,
      ),
      sections: const [
        PlinthNavSection(
          items: [
            PlinthNavItem(
              label: 'Overview',
              icon: Icon(Icons.dashboard_outlined, size: 18),
            ),
            PlinthNavItem(
              label: 'Inbox',
              icon: Icon(Icons.inbox_outlined, size: 18),
              trailing: PlinthBadge('12', color: 'red'),
            ),
            PlinthNavItem(
              label: 'Projects',
              icon: Icon(Icons.folder_outlined, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}
''',
  'NavbarWithSearchExample': r'''
class NavbarWithSearchExample extends StatelessWidget {
  const NavbarWithSearchExample({super.key});

  @override
  Widget build(BuildContext context) {
    // A navbar that carries a control rather than only links — the
    // arrangement most app shells actually need.
    return PlinthTopBar(
      brand: const PlinthTopBarBrand(title: 'Acme'),
      center: const PlinthTextInput(
        placeholder: 'Search projects…',
        size: PlinthSize.sm,
        leadingIcon: Icon(Icons.search, size: 16),
      ),
      actions: [
        const PlinthKbd('Ctrl'),
        const PlinthKbd('K'),
        PlinthActionIcon(
          semanticLabel: 'Settings',
          icon: const Icon(Icons.settings_outlined, size: 18),
          variant: PlinthVariant.subtle,
          onPressed: () {},
        ),
      ],
    );
  }
}
''',
  'NavbarWithSublevelsExample': r'''
class NavbarWithSublevelsExample extends StatefulWidget {
  const NavbarWithSublevelsExample({super.key});

  @override
  State<NavbarWithSublevelsExample> createState() =>
      _NavbarWithSublevelsExampleState();
}

class _NavbarWithSublevelsExampleState
    extends State<NavbarWithSublevelsExample> {
  Set<String> _open = {'Analytics'};
  String _active = 'Traffic';

  @override
  Widget build(BuildContext context) {
    return PlinthSidebar(
      width: 240,
      activeValue: _active,
      onSelect: (value) => setState(() => _active = value),
      openValues: _open,
      onOpenedChanged: (value, opened) => setState(() {
        _open = opened ? {..._open, value} : (_open.toSet()..remove(value));
      }),
      sections: const [
        PlinthNavSection(
          items: [
            PlinthNavItem(
              label: 'Analytics',
              icon: Icon(Icons.insights_outlined, size: 18),
              children: [
                PlinthNavItem(label: 'Traffic'),
                PlinthNavItem(label: 'Conversions'),
              ],
            ),
            PlinthNavItem(
              label: 'Content',
              icon: Icon(Icons.article_outlined, size: 18),
              children: [
                PlinthNavItem(label: 'Posts'),
                PlinthNavItem(label: 'Media'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
''',
  'NotFoundPageExample': r'''
class NotFoundPageExample extends StatelessWidget {
  const NotFoundPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthErrorPageBlock.notFound(
      actions: [
        PlinthButton(
          variant: PlinthVariant.defaultVariant,
          onPressed: () {},
          child: const Text('Go back'),
        ),
        PlinthButton(onPressed: () {}, child: const Text('Take me home')),
      ],
    );
  }
}
''',
  'OfflineExample': r'''
class OfflineExample extends StatelessWidget {
  const OfflineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthOfflineNotice(
      onRetry: () {},
      details: const [
        PlinthDataListItem.text('Queued changes', '3'),
        PlinthDataListItem.text('Last synced', '11:42'),
      ],
      actions: [
        PlinthButton(
          variant: PlinthVariant.subtle,
          onPressed: () {},
          child: const Text('Work offline'),
        ),
      ],
    );
  }
}
''',
  'OverlayArticleCardExample': r'''
class OverlayArticleCardExample extends StatelessWidget {
  const OverlayArticleCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The scrim is doing real work: a headline over a photograph is
    // legible or not depending on which photograph.
    return const PlinthArticleCard(
      width: 320,
      layout: PlinthArticleLayout.overlay,
      category: PlinthBadge('Field notes', color: 'grape'),
      title: 'A week of listening to the library',
      image: PlinthImage(
        src: 'https://picsum.photos/seed/plinth-overlay/640/360',
        fit: BoxFit.cover,
      ),
    );
  }
}
''',
  'PasswordResetExample': r'''
class PasswordResetExample extends StatefulWidget {
  const PasswordResetExample({super.key});

  @override
  State<PasswordResetExample> createState() => _PasswordResetExampleState();
}

class _PasswordResetExampleState extends State<PasswordResetExample> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return PlinthPasswordResetBlock(
      sent: _sent,
      onSubmit: (email) => setState(() => _sent = true),
      onBack: () => setState(() => _sent = false),
    );
  }
}
''',
  'PasswordStrengthExample': r'''
class PasswordStrengthExample extends StatefulWidget {
  const PasswordStrengthExample({super.key});

  @override
  State<PasswordStrengthExample> createState() =>
      _PasswordStrengthExampleState();
}

class _PasswordStrengthExampleState extends State<PasswordStrengthExample> {
  String _value = 'plinth';

  @override
  Widget build(BuildContext context) {
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
          // The meter is display only, so the field stays yours. Three
          // bands rather than a gradient, and every rule on screen
          // whether or not it is met.
          PlinthPasswordStrength(value: _value),
        ],
      ),
    );
  }
}
''',
  'PermissionDeniedExample': r'''
class PermissionDeniedExample extends StatelessWidget {
  const PermissionDeniedExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthErrorPageBlock.permissionDenied(
      actions: [
        PlinthButton(
          variant: PlinthVariant.defaultVariant,
          onPressed: () {},
          child: const Text('Switch account'),
        ),
        PlinthButton(onPressed: () {}, child: const Text('Request access')),
      ],
    );
  }
}
''',
  'PriceRangeFilterExample': r'''
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
''',
  'PricingCardExample': r'''
class PricingCardExample extends StatelessWidget {
  const PricingCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The price is the thing being compared, so it carries the weight
    // rather than the plan name above it — and it is the card's
    // heading, which is how a reader tells three identical "Start
    // trial" buttons apart.
    return PlinthPricingCard(
      width: 260,
      plan: 'Pro',
      price: r'$24',
      period: '/ month',
      badge: const PlinthBadge('Popular', color: 'violet'),
      features: const [
        'Unlimited projects',
        'Priority support',
        'Custom themes',
      ],
      action: PlinthButton(
        fullWidth: true,
        onPressed: () {},
        child: const Text('Start trial'),
      ),
    );
  }
}
''',
  'ProductCarouselExample': r'''
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
''',
  'ProjectCardExample': r'''
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
''',
  'PromoBannerExample': r'''
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

    return PlinthBannerBlock(
      layout: PlinthBannerLayout.bar,
      color: 'grape',
      leading: const PlinthBadge('Offer', color: 'grape'),
      message: 'Annual plans are 20% off until Friday.',
      onClose: () => setState(() => _visible = false),
      actions: [
        PlinthButton(
          size: PlinthSize.xs,
          color: 'grape',
          onPressed: () {},
          child: const Text('See plans'),
        ),
      ],
    );
  }
}
''',
  'QuoteArticleCardExample': r'''
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
''',
  'ReorderableListExample': r'''
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
''',
  'SearchBarExample': r'''
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
''',
  'SecretFieldExample': r'''
class SecretFieldExample extends StatefulWidget {
  const SecretFieldExample({super.key});

  @override
  State<SecretFieldExample> createState() => _SecretFieldExampleState();
}

class _SecretFieldExampleState extends State<SecretFieldExample> {
  // A field nobody types into: the value arrives from the server, and
  // the whole arrangement exists to get it back out again intact.
  String _key = 'pk_live_4f8Xq2Lm90Zt';

  void _regenerate() {
    final stamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    setState(() => _key = 'pk_live_$stamp');
  }

  @override
  Widget build(BuildContext context) {
    return PlinthSecretField(
      width: 520,
      label: 'Publishable key',
      value: _key,
      onRegenerate: _regenerate,
      warning: 'Regenerating takes effect immediately. Existing calls with '
          'the old key will start failing.',
    );
  }
}
''',
  'SectionedNavbarExample': r'''
class SectionedNavbarExample extends StatelessWidget {
  const SectionedNavbarExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Headings rather than a tree: these are flat destinations that
    // happen to group, not a hierarchy you navigate into.
    return const PlinthSidebar(
      activeValue: 'Overview',
      sections: [
        PlinthNavSection(
          title: 'Workspace',
          items: [
            PlinthNavItem(
              label: 'Overview',
              icon: Icon(Icons.dashboard_outlined, size: 18),
            ),
            PlinthNavItem(
              label: 'Projects',
              icon: Icon(Icons.folder_outlined, size: 18),
            ),
          ],
        ),
        PlinthNavSection(
          title: 'Account',
          items: [
            PlinthNavItem(
              label: 'Settings',
              icon: Icon(Icons.settings_outlined, size: 18),
            ),
            PlinthNavItem(
              label: 'Billing',
              icon: Icon(Icons.credit_card_outlined, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}
''',
  'ServerErrorPageExample': r'''
class ServerErrorPageExample extends StatelessWidget {
  const ServerErrorPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthErrorPageBlock.serverError(
      actions: [
        PlinthButton(
          leadingIcon: const Icon(Icons.refresh, size: 16),
          onPressed: () {},
          child: const Text('Try again'),
        ),
      ],
    );
  }
}
''',
  'SettingSlidersExample': r'''
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
''',
  'SignInFormExample': r'''
class SignInFormExample extends StatelessWidget {
  const SignInFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthSignInBlock(
      onSubmit: (values) {},
      onForgotPassword: () {},
      alternatives: [
        PlinthButton(
          variant: PlinthVariant.defaultVariant,
          fullWidth: true,
          leadingIcon: const Icon(Icons.g_mobiledata, size: 20),
          onPressed: () {},
          child: const Text('Continue with Google'),
        ),
      ],
      subtitle: 'Sign in to continue to your dashboard.',
    );
  }
}
''',
  'SignUpFormExample': r'''
class SignUpFormExample extends StatelessWidget {
  const SignUpFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthSignUpBlock(
      onSubmit: (values) {},
      passwordDescription: 'At least 12 characters.',
      footer: PlinthAnchor('Already have an account?', onTap: () {}),
    );
  }
}
''',
  'SimpleArticleCardExample': r'''
class SimpleArticleCardExample extends StatelessWidget {
  const SimpleArticleCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The headline is a heading, not bold text: a feed is a list of
    // documents, and a reader skims it by heading.
    return PlinthArticleCard(
      width: 280,
      category: const PlinthBadge('Design', color: 'orange'),
      title: 'Building a design system from scratch',
      excerpt: 'What we learned shipping one set of tokens to three '
          'applications.',
      meta: '12 Aug',
      image: PlinthAspectRatio(
        ratio: 16 / 9,
        child: Container(color: context.plinth.shaded('orange', 0)),
      ),
      onTap: () {},
    );
  }
}
''',
  'SimpleFooterExample': r'''
class SimpleFooterExample extends StatelessWidget {
  const SimpleFooterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthFooter(
      width: 560,
      brand: 'Acme',
      copyright: '© 2026',
      links: [
        PlinthAnchor('Privacy', size: PlinthSize.sm, onTap: () {}),
        PlinthAnchor('Terms', size: PlinthSize.sm, onTap: () {}),
        PlinthAnchor('Contact', size: PlinthSize.sm, onTap: () {}),
      ],
    );
  }
}
''',
  'SimpleNavbarExample': r'''
class SimpleNavbarExample extends StatelessWidget {
  const SimpleNavbarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthTopBar(
      brand: const PlinthTopBarBrand(title: 'Acme'),
      links: [
        PlinthAnchor('Product', onTap: () {}),
        PlinthAnchor('Pricing', onTap: () {}),
        PlinthAnchor('About', onTap: () {}),
      ],
      actions: [
        PlinthButton(onPressed: () {}, child: const Text('Sign in')),
      ],
    );
  }
}
''',
  'SingleCommentExample': r'''
class SingleCommentExample extends StatelessWidget {
  const SingleCommentExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthCommentThread(
      width: 460,
      comments: [
        PlinthCommentData(
          initials: 'AB',
          author: 'Ada Byron',
          when: '2 hours ago',
          body: 'Does the shade mirroring apply to custom palettes too, '
              'or only the built-in ramps?',
          actions: [
            PlinthAnchor('Reply', size: PlinthSize.xs, onTap: () {}),
          ],
        ),
      ],
    );
  }
}
''',
  'SliderWithMarksExample': r'''
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
''',
  'SortableTableExample': r'''
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
''',
  'SplitAuthExample': r'''
class SplitAuthExample extends StatelessWidget {
  const SplitAuthExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthSplitAuthBlock(
      width: 620,
      height: 380,
      decoration: const PlinthBackgroundImage(
        src: 'https://picsum.photos/seed/plinth-auth/600/600',
        height: double.infinity,
        child: PlinthTitle('Build faster', order: 3),
      ),
      child: PlinthSignInBlock(
        width: null,
        titleOrder: 4,
        showRememberMe: false,
        onSubmit: (values) {},
      ),
    );
  }
}
''',
  'SplitButtonExample': r'''
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
''',
  'StatBreakdownExample': r'''
class StatBreakdownExample extends StatelessWidget {
  const StatBreakdownExample({super.key});

  static const _segments = [
    (label: 'Direct', share: 5, color: 'blue'),
    (label: 'Search', share: 3, color: 'teal'),
    (label: 'Social', share: 2, color: 'grape'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: PlinthStatTile(
        label: 'Sessions',
        uppercaseLabel: false,
        value: '18,420',
        // A part-to-whole bar rather than three separate figures: the
        // point of this arrangement is the proportion, which separate
        // numbers make you compute yourself.
        //
        // This was a hand-rolled Row of Expandeds until 0.19.0, when
        // PlinthProgress learned sections — the audit found the gap by
        // noticing this block routing around it.
        visual: PlinthProgress.sections(
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
        action: PlinthGroup(
          gap: PlinthSize.md,
          children: [
            for (final s in _segments)
              PlinthGroup(
                gap: PlinthSize.xs,
                wrap: false,
                children: [
                  PlinthColorSwatch(color: s.color, size: PlinthSize.xs),
                  PlinthText(s.label, size: PlinthSize.xs, color: 'gray'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
''',
  'StatGoalRingsExample': r'''
class StatGoalRingsExample extends StatelessWidget {
  const StatGoalRingsExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Rings rather than bars: these are three unrelated targets, not
    // parts of one total, and a row of bars would imply they add up.
    return const PlinthGoalRings(
      width: 420,
      goals: [
        PlinthGoal(label: 'Signups', value: 0.82, color: 'teal'),
        PlinthGoal(label: 'Activation', value: 0.46, color: 'blue'),
        PlinthGoal(label: 'Retention', value: 0.91, color: 'grape'),
      ],
    );
  }
}
''',
  'StatLeaderboardExample': r'''
class StatLeaderboardExample extends StatelessWidget {
  const StatLeaderboardExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Shares are measured against the leader, not the total: the
    // question a ranking answers is "how far behind is second", and
    // dividing by a total nobody sees makes every bar look small.
    return const PlinthLeaderboard(
      width: 420,
      title: 'Top pages',
      rows: [
        PlinthLeaderboardRow(
          label: '/docs/getting-started',
          value: 8420,
          display: '8,420',
        ),
        PlinthLeaderboardRow(
          label: '/components/button',
          value: 5310,
          display: '5,310',
        ),
        PlinthLeaderboardRow(
          label: '/blog/0-17-0',
          value: 3980,
          display: '3,980',
        ),
        PlinthLeaderboardRow(label: '/pricing', value: 1240, display: '1,240'),
      ],
    );
  }
}
''',
  'StatTileRowExample': r'''
class StatTileRowExample extends StatelessWidget {
  const StatTileRowExample({super.key});

  @override
  Widget build(BuildContext context) {
    // `higherIsBetter: false` on churn is the whole point: a falling
    // churn number is the best news on the board, and the version of
    // this block before the move painted it red.
    return const PlinthStatGrid(
      width: 560,
      tiles: [
        PlinthStatTile(
          label: 'Revenue',
          value: r'$13,456',
          delta: '12.4%',
          trend: PlinthTrend.up,
        ),
        PlinthStatTile(
          label: 'Active users',
          value: '2,340',
          delta: '3.1%',
          trend: PlinthTrend.up,
        ),
        PlinthStatTile(
          label: 'Churn',
          value: '1.8%',
          delta: '0.4%',
          trend: PlinthTrend.down,
          higherIsBetter: false,
        ),
      ],
    );
  }
}
''',
  'StatWithPeriodExample': r'''
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
              items: [
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
''',
  'StatWithProgressExample': r'''
class StatWithProgressExample extends StatelessWidget {
  const StatWithProgressExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: PlinthStatTile(
        label: 'Storage used',
        uppercaseLabel: false,
        value: '68 GB',
        caption: 'of 100 GB',
        badge: const PlinthBadge('Pro', color: 'grape'),
        visual: const PlinthProgress(value: 0.68),
        action: PlinthAnchor('Manage plan', size: PlinthSize.sm, onTap: () {}),
      ),
    );
  }
}
''',
  'StatWithSparklineExample': r'''
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
    38
  ];

  @override
  Widget build(BuildContext context) {
    // The sparkline carries a sentence built from its own data, so a
    // reader who cannot see it still hears where the series went.
    return PlinthStatTile(
      label: 'Monthly revenue',
      uppercaseLabel: false,
      value: r'$38.4k',
      delta: '9.2%',
      trend: PlinthTrend.up,
      visual: const PlinthSparkline(
        label: 'Monthly revenue',
        values: _series,
      ),
    );
  }
}
''',
  'StickyHeaderExample': r'''
class StickyHeaderExample extends StatelessWidget {
  const StickyHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    // A fixed row plus a scrolling body, rather than a SliverAppBar:
    // the header never moves, so there is no collapse behaviour to
    // tune and the list needs no CustomScrollView around it.
    return PlinthStickyHeader(
      height: 220,
      header: Row(
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
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 12,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: PlinthText('Release 0.${16 - i}.0', size: PlinthSize.sm),
        ),
      ),
    );
  }
}
''',
  'SupportChannelsExample': r'''
class SupportChannelsExample extends StatelessWidget {
  const SupportChannelsExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Routing rather than a form: when several channels exist, the
    // reader's first decision is which one, and a form presumes that
    // answer for them.
    return PlinthSupportChannels(
      width: 560,
      channels: [
        PlinthSupportChannel(
          icon: const Icon(Icons.chat_bubble_outline),
          title: 'Live chat',
          detail: 'Weekdays, 9–17 UTC',
          color: 'blue',
          onTap: () {},
        ),
        PlinthSupportChannel(
          icon: const Icon(Icons.mail_outline),
          title: 'Email',
          detail: 'Replies within a day',
          color: 'teal',
          onTap: () {},
        ),
        PlinthSupportChannel(
          icon: const Icon(Icons.menu_book_outlined),
          title: 'Docs',
          detail: 'Answers most questions',
          color: 'grape',
          onTap: () {},
        ),
      ],
    );
  }
}
''',
  'TaskCardExample': r'''
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
''',
  'ToolbarActionsExample': r'''
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
''',
  'TwoFactorExample': r'''
class TwoFactorExample extends StatelessWidget {
  const TwoFactorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthTwoFactorBlock(
      onSubmit: (code) {},
      onResend: () {},
    );
  }
}
''',
  'UpdateBannerExample': r'''
class UpdateBannerExample extends StatelessWidget {
  const UpdateBannerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthBannerBlock(
      title: 'Version 1.3.0 is available',
      message: 'Adds four components and fixes a marquee overflow.',
      icon: const Icon(Icons.system_update_alt),
      // Two actions, and the passive one is not a dismissal: an update
      // banner that can only be closed teaches people to close it.
      actions: [
        PlinthButton(
          size: PlinthSize.xs,
          onPressed: () {},
          child: const Text('Update now'),
        ),
        PlinthButton(
          size: PlinthSize.xs,
          variant: PlinthVariant.subtle,
          onPressed: () {},
          child: const Text('What changed?'),
        ),
      ],
    );
  }
}
''',
  'UserButtonExample': r'''
class UserButtonExample extends StatelessWidget {
  const UserButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthUserTile(
      width: 260,
      withBorder: true,
      initials: 'YL',
      name: 'Yair Lahav',
      detail: 'yair@example.com',
      trailing: PlinthActionIcon(
        semanticLabel: 'Expand',
        icon: const Icon(Icons.unfold_more, size: 16),
        variant: PlinthVariant.subtle,
        onPressed: () {},
      ),
    );
  }
}
''',
  'UserContactCardExample': r'''
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
''',
  'UserMenuExample': r'''
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
''',
  'UserProfileCardExample': r'''
class UserProfileCardExample extends StatelessWidget {
  const UserProfileCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PlinthProfileCard(
      width: 300,
      initials: 'YL',
      name: 'Yair Lahav',
      badge: const PlinthBadge('Maintainer', color: 'grape'),
      // The counts come from PlinthStatStrip, which merges each value
      // with its label — "128 posts" rather than a number and a
      // caption that happen to be stacked.
      stats: const [
        PlinthStat(value: '128', label: 'Posts'),
        PlinthStat(value: '2.4k', label: 'Followers'),
        PlinthStat(value: '312', label: 'Following'),
      ],
      actions: [
        PlinthButton(
          fullWidth: true,
          onPressed: () {},
          child: const Text('Follow'),
        ),
      ],
    );
  }
}
''',
  'UserStatusExample': r'''
class UserStatusExample extends StatefulWidget {
  const UserStatusExample({super.key});

  @override
  State<UserStatusExample> createState() => _UserStatusExampleState();
}

class _UserStatusExampleState extends State<UserStatusExample> {
  PlinthPresence _status = PlinthPresence.online;

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
          // The dot rides the avatar rather than sitting beside it,
          // which is what makes presence readable at a glance — and the
          // word travels with it, so it is readable without colour too.
          PlinthUserTile(
            initials: 'YL',
            name: 'Yair Lahav',
            detail: _status.label,
            presence: _status,
          ),
          PlinthSegmentedControl<PlinthPresence>(
            size: PlinthSize.sm,
            value: _status,
            onChanged: (s) => setState(() => _status = s),
            items: const [
              PlinthSegmentedControlItem(PlinthPresence.online, 'Online'),
              PlinthSegmentedControlItem(PlinthPresence.away, 'Away'),
              PlinthSegmentedControlItem(PlinthPresence.busy, 'Busy'),
            ],
          ),
        ],
      ),
    );
  }
}
''',
  'VerificationCodeExample': r'''
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
              // The result belongs *to* the pin input rather than
              // beside it. statusText is a live region, so it is spoken
              // when it appears; this example used to render its own
              // PlinthText sibling, which looks identical and announces
              // nothing -- the demo bypassing the very fix B0c made,
              // and reported as a library failure because there was no
              // way to tell the two apart from outside.
              statusText: switch (_accepted) {
                true => 'Verified',
                false => 'That code has expired or is wrong',
                null => 'Code expires in 9:58',
              },
            ),
            PlinthAnchor('Send a new code',
                size: PlinthSize.sm, onTap: () => setState(() => _code = '')),
          ],
        ),
      ),
    );
  }
}
''',
};
