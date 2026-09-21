/// The index: four posts as article cards.
///
/// The section tag is a word first and a colour second. Four sections
/// is already past where a reader can tell them apart by hue, which is
/// the argument one of the posts makes at length.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import '../content.dart';

class PostListScreen extends StatelessWidget {
  const PostListScreen({super.key, required this.onOpen});

  final ValueChanged<Post> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PlinthPageHeader(
          title: 'Writing',
          subtitle: 'Notes on building interfaces that survive a rebrand',
        ),
        SizedBox(height: theme.space(6)),
        for (final post in posts) ...[
          PlinthArticleCard(
            title: post.title,
            excerpt: post.excerpt,
            category: PlinthBadge(
              post.section,
              color: theme.semanticColors[post.section]?.ramp,
            ),
            author: PlinthUserTile(
              name: post.author,
              detail: post.published,
              size: PlinthSize.sm,
            ),
            meta: post.readingTime,
            onTap: () => onOpen(post),
          ),
          SizedBox(height: theme.space(4)),
        ],
      ],
    );
  }
}
