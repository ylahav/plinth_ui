/// The posts, standing in for a CMS.
///
/// No Flutter import. Sections are named — `'engineering'` — and the
/// widget layer resolves them through the theme, so swapping this file
/// for a real client does not drag colour decisions along.
library;

/// One heading inside an article. The list of these *is* the table of
/// contents; there is no second list to keep in step, which is the
/// usual way a TOC ends up pointing at a heading that was renamed.
class Section {
  const Section({
    required this.heading,
    required this.body,
    this.order = 2,
  });

  final String heading;
  final String body;

  /// Heading level, driving both the rendered title and the TOC indent.
  final int order;
}

class Post {
  const Post({
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.section,
    required this.author,
    required this.published,
    required this.readingTime,
    required this.sections,
    this.comments = const [],
  });

  final String slug;
  final String title;
  final String excerpt;

  /// A key in `sectionRoles`, not a colour.
  final String section;
  final String author;
  final String published;
  final String readingTime;
  final List<Section> sections;
  final List<Comment> comments;
}

class Comment {
  const Comment({
    required this.author,
    required this.body,
    required this.when,
    this.replies = const [],
  });

  final String author;
  final String body;
  final String when;
  final List<Comment> replies;
}

const posts = <Post>[
  Post(
    slug: 'contrast-at-lookup',
    title: 'Resolving contrast at lookup time',
    excerpt: 'A palette chosen once is a palette that stops being readable the '
        'first time somebody rebrands it.',
    section: 'engineering',
    author: 'Ada Okafor',
    published: '18 September 2026',
    readingTime: '7 min read',
    sections: [
      Section(
        heading: 'The problem with a chosen palette',
        body: 'Design systems hand you a ramp and a rule: use shade 6 for '
            'text on white. That holds exactly as long as nobody changes '
            'the ramp. The moment a brand colour arrives from marketing, '
            'shade 6 is whatever the generator produced, and the rule is '
            'a rule about a number rather than about readability.',
      ),
      Section(
        heading: 'Anchoring the ramp',
        order: 3,
        body: 'Generating shades around the brand colour so that shade 6 '
            'is exactly the colour given means a filled button paints the '
            'brand and not an approximation of it. That part is easy and '
            'most systems do it.',
      ),
      Section(
        heading: 'Walking it at lookup',
        order: 3,
        body: 'The part most systems skip: when something asks for text '
            'in a role, walk the ramp until the contrast against the '
            'surface clears the floor, and return that. The caller asked '
            'for a role and got a readable colour. It never learns which '
            'shade, because it never needed to.',
      ),
      Section(
        heading: 'What it costs',
        body: 'A lookup instead of a constant, and the discipline of '
            'naming roles rather than hues. In exchange, a rebrand is one '
            'line and the floor holds without anyone re-auditing a screen.',
      ),
    ],
    comments: [
      Comment(
        author: 'Jun Park',
        when: '2 days ago',
        body: 'The amber case is the one that convinced me. Every system '
            'I have used ships amber-on-white somewhere.',
        replies: [
          Comment(
            author: 'Ada Okafor',
            when: '2 days ago',
            body: 'It is about 1.9:1 at shade 6. Nobody picks it on '
                'purpose — it just looks like the colour for "pending".',
          ),
        ],
      ),
      Comment(
        author: 'Mira Haddad',
        when: '1 day ago',
        body: 'Does this interact badly with dark mode?',
        replies: [
          Comment(
            author: 'Ada Okafor',
            when: '22 hours ago',
            body: 'The opposite — the surface changes and the walk finds '
                'a different shade. Nothing in the screen changes.',
          ),
        ],
      ),
    ],
  ),
  Post(
    slug: 'colour-is-not-meaning',
    title: 'Colour is not meaning',
    excerpt: 'Four statuses is already past the point where a hue can '
        'carry the difference on its own.',
    section: 'design',
    author: 'Mira Haddad',
    published: '11 September 2026',
    readingTime: '5 min read',
    sections: [
      Section(
        heading: 'Two is fine, four is not',
        body: 'Red and green survive as a pair because the shapes and '
            'positions around them differ. Add amber and grey and the '
            'reader is being asked to distinguish four hues in a badge '
            'eleven pixels tall.',
      ),
      Section(
        heading: 'Say the word',
        body: 'The fix is not a better palette. It is putting the status '
            'in the badge as text, and letting colour be the second '
            'signal it is good at being.',
      ),
    ],
    comments: [
      Comment(
        author: 'Tom Ellery',
        when: '5 days ago',
        body: 'We shipped a dashboard with six statuses as dots. Took a '
            'support ticket to find out.',
      ),
    ],
  ),
  Post(
    slug: 'testing-what-you-cannot-see',
    title: 'Testing the thing you cannot see',
    excerpt: 'Every accessibility test here walks the semantics tree. '
        'The tree was correct and the app was unreachable by Tab.',
    section: 'research',
    author: 'Jun Park',
    published: '3 September 2026',
    readingTime: '9 min read',
    sections: [
      Section(
        heading: 'A passing suite',
        body: 'Two components were clickable, announceable, and could '
            'not be reached with the keyboard. Every test passed, '
            'because every test asked the semantics tree and the tree '
            'was right about everything it described.',
      ),
      Section(
        heading: 'What the tree does not know',
        body: 'Focus order is not in it. Passing tests are evidence '
            'about the tree, not about the app — which is an argument '
            'for hearing it, not for writing more of them.',
      ),
    ],
  ),
  Post(
    slug: 'release-notes-september',
    title: 'What shipped in September',
    excerpt: 'Charts, blocks as a package, and four starters.',
    section: 'notes',
    author: 'Ada Okafor',
    published: '21 September 2026',
    readingTime: '3 min read',
    sections: [
      Section(
        heading: 'Charts',
        body: 'Line, bar, donut and sparkline, on the colour-blind-safe '
            'categorical palette, each carrying a text alternative built '
            'from its own data.',
      ),
      Section(
        heading: 'Starters',
        body: 'Four apps that compile in CI, so a template that has '
            'stopped working fails here rather than in your hands.',
      ),
    ],
  ),
];

Post postBySlug(String slug) => posts.firstWhere((p) => p.slug == slug);
