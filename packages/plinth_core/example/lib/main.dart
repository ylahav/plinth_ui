// Registering PlinthTheme and reading design tokens from it.
//
// plinth_core is the token layer on its own — no widgets. Everything
// below is plain Flutter, styled entirely from the theme, which is the
// point: the same tokens are what plinth_components reads.
//
// For a full app using the widgets, see the example/ app at the root of
// https://github.com/ylahav/plinth_ui.

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

void main() => runApp(const TokenExampleApp());

class TokenExampleApp extends StatefulWidget {
  const TokenExampleApp({super.key});

  @override
  State<TokenExampleApp> createState() => _TokenExampleAppState();
}

class _TokenExampleAppState extends State<TokenExampleApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _mode,
      // Register the theme once, as a ThemeData extension. Everything
      // below reaches it through `context.plinth`.
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme]),
      home: TokenDemoPage(
        onToggleTheme: () => setState(
          () => _mode =
              _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
        ),
      ),
    );
  }
}

class TokenDemoPage extends StatelessWidget {
  const TokenDemoPage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing[PlinthSize.lg]!),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Design tokens',
                style: TextStyle(
                  fontSize: theme.fontSizes[PlinthSize.xl],
                  fontWeight: FontWeight.w700,
                  // Surface, text, and border colours flip with the
                  // theme; the palette ramps below do not.
                  color: theme.text,
                ),
              ),
              SizedBox(height: theme.spacing[PlinthSize.sm]),
              Text(
                'Light and dark share one palette. What changes is the '
                'neutral chrome around it.',
                style: TextStyle(
                  fontSize: theme.fontSizes[PlinthSize.sm],
                  color: theme.textMuted,
                ),
              ),
              SizedBox(height: theme.spacing[PlinthSize.lg]),

              // A filled swatch per palette colour. `shaded` mirrors the
              // shade for the active brightness, and `contrastingOn`
              // picks a label colour the fill can actually carry —
              // white on yellow is unreadable, so it comes out dark.
              Wrap(
                spacing: theme.spacing[PlinthSize.xs]!,
                runSpacing: theme.spacing[PlinthSize.xs]!,
                children: [
                  for (final name in theme.colors.keys)
                    Builder(
                      builder: (context) {
                        final fill = theme.shaded(name, 6);
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: theme.spacing[PlinthSize.sm]!,
                            vertical: theme.spacing[PlinthSize.xs]! * 0.5,
                          ),
                          decoration: BoxDecoration(
                            color: fill,
                            borderRadius: BorderRadius.circular(
                              theme.radius[PlinthSize.sm]!,
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              color: theme.contrastingOn(fill),
                              fontSize: theme.fontSizes[PlinthSize.xs],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              SizedBox(height: theme.spacing[PlinthSize.lg]),

              // `readableOn` walks the ramp for a shade that actually
              // contrasts with the background — no single shade index
              // works for every hue.
              Container(
                padding: EdgeInsets.all(theme.spacing[PlinthSize.md]!),
                decoration: BoxDecoration(
                  color: theme.surfaceMuted,
                  border: Border.all(color: theme.border),
                  borderRadius:
                      BorderRadius.circular(theme.radius[PlinthSize.md]!),
                ),
                child: Text(
                  'Accent text stays legible on any surface',
                  style: TextStyle(
                    color: theme.readableOn('cyan', theme.surfaceMuted),
                    fontSize: theme.fontSizes[PlinthSize.md],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),

              TextButton(
                onPressed: onToggleTheme,
                child: Text(
                  'Toggle light / dark',
                  style: TextStyle(color: theme.shaded(theme.primaryColor, 6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
