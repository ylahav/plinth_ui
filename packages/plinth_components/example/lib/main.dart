// A small sign-up form built from Plinth components.
//
// plinth_components re-exports plinth_core, so this one import brings
// both the widgets and the theme.
//
// For every component in one place, see the example/ app and the
// widgetbook/ gallery at the root of
// https://github.com/ylahav/plinth_ui.

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

void main() => runApp(const PlinthExampleApp());

class PlinthExampleApp extends StatefulWidget {
  const PlinthExampleApp({super.key});

  @override
  State<PlinthExampleApp> createState() => _PlinthExampleAppState();
}

class _PlinthExampleAppState extends State<PlinthExampleApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _mode,
      // Register the theme once. Every component reads from it, so a
      // single swap restyles the whole app — including dark mode.
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme]),
      home: SignUpPage(
        onToggleTheme: () => setState(
          () => _mode =
              _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String _email = '';
  bool _agreed = false;
  List<String> _interests = ['flutter'];
  bool _submitting = false;

  // A null error hides the message; a non-null one also turns the
  // field's border red, and takes precedence over the focus colour.
  String? get _emailError {
    if (_email.isEmpty || _email.contains('@')) return null;
    return 'Enter a valid email address';
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _submitting = false);
    PlinthNotification.show(
      context,
      title: 'Welcome aboard',
      color: 'green',
      icon: const Icon(Icons.check_circle_outline),
      child: const Text('Check your inbox to confirm your address.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: PlinthCenter(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 380,
              child: PlinthLoadingOverlay(
                visible: _submitting,
                child: PlinthCard(
                  withBorder: true,
                  p: PlinthSize.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: PlinthTitle('Create an account', order: 3),
                          ),
                          PlinthActionIcon(
                            icon:
                                const Icon(Icons.dark_mode_outlined, size: 18),
                            variant: PlinthVariant.subtle,
                            onPressed: widget.onToggleTheme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      PlinthTextInput(
                        label: 'Email',
                        placeholder: 'you@example.com',
                        error: _emailError,
                        onChanged: (v) => setState(() => _email = v),
                      ),
                      const SizedBox(height: 12),

                      PlinthPasswordInput(
                        label: 'Password',
                        description: 'At least 12 characters.',
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 12),

                      // Free-text chips: Enter or a comma commits one.
                      PlinthTagsInput(
                        label: 'Interests',
                        placeholder: 'Add a tag',
                        value: _interests,
                        onChanged: (v) => setState(() => _interests = v),
                      ),
                      const SizedBox(height: 16),

                      PlinthCheckbox(
                        label: 'I agree to the terms of service',
                        value: _agreed,
                        size: PlinthSize.sm,
                        onChanged: (v) => setState(() => _agreed = v),
                      ),
                      const SizedBox(height: 20),

                      // A null callback is how every interactive
                      // component here expresses "disabled".
                      PlinthButton(
                        fullWidth: true,
                        onPressed:
                            _agreed && _emailError == null ? _submit : null,
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
