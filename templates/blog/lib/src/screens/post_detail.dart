/// One article, with a table of contents that follows the scroll.
///
/// The TOC is derived from `post.sections` rather than written beside
/// it. There is no second list to keep in step, so a renamed heading
/// cannot leave the contents pointing at something that no longer
/// exists — which is the failure mode of every hand-maintained TOC.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import '../content.dart';

/// The width below which the contents stop being worth a column.
const _tocBreakpoint = 900.0;

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({
    super.key,
    required this.post,
    required this.onBack,
  });

  final Post post;
  final VoidCallback onBack;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late List<GlobalKey> _keys;
  final _scrollController = ScrollController();
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _keys = [for (final _ in widget.post.sections) GlobalKey()];
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(PostDetailScreen old) {
    super.didUpdateWidget(old);
    if (old.post.slug != widget.post.slug) {
      _keys = [for (final _ in widget.post.sections) GlobalKey()];
      _active = 0;
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Which heading is on screen — the caller's job, deliberately.
  ///
  /// `PlinthTableOfContents` takes `activeIndex` rather than working it
  /// out, because "on screen" means something different in a sticky
  /// header than in a plain scroll view, and a widget that guessed
  /// would be wrong in one of them.
  void _onScroll() {
    var next = 0;
    for (var i = 0; i < _keys.length; i++) {
      final box = _keys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      if (top <= 160) next = i;
    }
    if (next != _active) setState(() => _active = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final post = widget.post;
    final wide = MediaQuery.sizeOf(context).width >= _tocBreakpoint;

    final toc = PlinthTableOfContents(
      activeIndex: _active,
      items: [
        for (var i = 0; i < post.sections.length; i++)
          PlinthTocItem(
            label: post.sections[i].heading,
            order: post.sections[i].order,
            targetKey: _keys[i],
          ),
      ],
    );

    final article = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlinthBadge(
          post.section,
          color: theme.semanticColors[post.section]?.ramp,
        ),
        SizedBox(height: theme.space(3)),
        PlinthTitle(post.title, order: 1),
        SizedBox(height: theme.space(3)),
        PlinthUserTile(
          name: post.author,
          detail: '${post.published} · ${post.readingTime}',
          size: PlinthSize.sm,
        ),
        SizedBox(height: theme.space(6)),
        for (var i = 0; i < post.sections.length; i++) ...[
          PlinthTitle(
            post.sections[i].heading,
            order: post.sections[i].order,
            key: _keys[i],
          ),
          SizedBox(height: theme.space(3)),
          PlinthText(post.sections[i].body),
          SizedBox(height: theme.space(6)),
        ],
        PlinthDivider(),
        SizedBox(height: theme.space(5)),
        PlinthTitle('${post.comments.length} comments', order: 3),
        SizedBox(height: theme.space(4)),
        PlinthCommentThread(
          comments: [
            for (final comment in post.comments) _toData(comment),
          ],
        ),
      ],
    );

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(theme.space(6)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlinthButton(
                variant: PlinthVariant.subtle,
                leadingIcon: const Icon(Icons.arrow_back, size: 16),
                onPressed: widget.onBack,
                child: const Text('All posts'),
              ),
              SizedBox(height: theme.space(5)),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: article),
                    SizedBox(width: theme.space(8)),
                    SizedBox(width: 220, child: toc),
                  ],
                )
              else ...[
                // Above the article when narrow, because contents you
                // have to scroll past the article to reach are not
                // contents.
                toc,
                SizedBox(height: theme.space(6)),
                article,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

PlinthCommentData _toData(Comment comment) => PlinthCommentData(
      author: comment.author,
      body: comment.body,
      when: comment.when,
      replies: [for (final reply in comment.replies) _toData(reply)],
    );
