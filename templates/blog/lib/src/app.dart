/// List or article, and the chrome around both.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import 'content.dart';
import 'screens/post_detail.dart';
import 'screens/post_list.dart';

class BlogApp extends StatelessWidget {
  const BlogApp({super.key, required this.light, required this.dark});

  final ThemeData light;
  final ThemeData dark;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Writing',
        theme: light,
        darkTheme: dark,
        debugShowCheckedModeBanner: false,
        home: const BlogShell(),
      );
}

class BlogShell extends StatefulWidget {
  const BlogShell({super.key});

  @override
  State<BlogShell> createState() => _BlogShellState();
}

class _BlogShellState extends State<BlogShell> {
  Post? _open;

  void _openPost(Post post) {
    setState(() => _open = post);

    // The body was replaced under a reader who was in the list. Nothing
    // about a body swap announces itself, so say what happened.
    PlinthAnnounce.say(context, '${post.title}, article');
  }

  @override
  Widget build(BuildContext context) {
    final open = _open;

    // The brand and a call to action do not both fit beside each other
    // on a phone. The brand wins, because it is also the way back to
    // the index.
    final roomForActions = MediaQuery.sizeOf(context).width >= 520;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlinthTopBar(
              brand: PlinthTopBarBrand(
                title: 'Writing',
                icon: const Icon(Icons.edit_note),
                onTap: () => setState(() => _open = null),
              ),
              actions: [
                if (roomForActions)
                  PlinthButton(
                    variant: PlinthVariant.subtle,
                    onPressed: () {},
                    child: const Text('Subscribe'),
                  ),
              ],
            ),
            Expanded(
              child: open == null
                  ? SingleChildScrollView(
                      padding: EdgeInsets.all(context.plinth.space(6)),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: PostListScreen(onOpen: _openPost),
                        ),
                      ),
                    )
                  : PostDetailScreen(
                      post: open,
                      onBack: () => setState(() => _open = null),
                    ),
            ),
            const PlinthFooter(
              brand: 'Keystone',
              copyright: '© 2026. Written by people.',
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
}
