import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_close_button.dart';
import 'plinth_text.dart';

/// A file-selection field matching Mantine's `FileInput`, sharing
/// [PlinthTextInput]'s label/description/error chrome.
///
/// **This does not open a file picker.** Flutter has no built-in one,
/// and every package that provides it (`file_picker`, `file_selector`,
/// `image_picker`) would become a dependency of `plinth_components` and
/// therefore of every app using any part of this library — a
/// disproportionate cost for one component, and a choice each app is
/// better placed to make than a design system is.
///
/// So [onPick] is yours: open whichever picker you use, and return what
/// it gives you. This renders the field, the selected files, the
/// remove affordances, and the error state.
///
/// [T] is your own file type — `PlatformFile`, `XFile`, `File`, a
/// record, whatever the picker returns — and [labelBuilder] says how to
/// show one.
///
/// ```dart
/// PlinthFileInput<PlatformFile>(
///   label: 'Attachments',
///   multiple: true,
///   value: _files,
///   labelBuilder: (file) => file.name,
///   onPick: () async {
///     final result = await FilePicker.platform.pickFiles(allowMultiple: true);
///     return result?.files ?? const [];
///   },
///   onChanged: (files) => setState(() => _files = files),
/// )
/// ```
class PlinthFileInput<T> extends StatelessWidget {
  const PlinthFileInput({
    super.key,
    required this.value,
    required this.onPick,
    required this.onChanged,
    required this.labelBuilder,
    this.label,
    this.description,
    this.placeholder,
    this.error,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.enabled = true,
    this.clearable = false,
    this.multiple = false,
    this.leadingIcon,
  });

  /// The currently selected files. Owned by the caller, like every
  /// other controlled component here.
  final List<T> value;

  /// Opens your picker and returns what the user chose. Returning an
  /// empty list or null (a cancelled dialog) leaves [value] untouched
  /// rather than clearing it — cancelling a picker should not discard
  /// a previous selection.
  final Future<List<T>?> Function() onPick;

  final ValueChanged<List<T>> onChanged;

  /// How to display one file. Usually its name.
  final String Function(T file) labelBuilder;

  final String? label;
  final String? description;

  /// Shown when nothing is selected.
  final String? placeholder;

  final String? error;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;
  final bool enabled;

  /// Shows a button that drops every chosen file at once. Each file
  /// chip can already remove itself; this is for starting over.
  final bool clearable;

  /// Whether picking replaces the selection or adds to it. The picker
  /// itself also needs telling — this only governs what happens to what
  /// it returns.
  final bool multiple;

  /// Leading icon. Defaults to a paperclip.
  final Widget? leadingIcon;

  Future<void> _pick() async {
    final picked = await onPick();
    if (picked == null || picked.isEmpty) return;
    onChanged(multiple ? [...value, ...picked] : [picked.first]);
  }

  void _remove(T file) {
    onChanged([...value]..remove(file));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final hasError = error != null && error!.isNotEmpty;
    final resolvedRadius = theme.radius[radius ?? theme.defaultRadius]!;
    final borderColor =
        hasError ? theme.roleShaded(PlinthRole.error, 6) : theme.border;
    final fontSize = theme.fontSizes[size]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          PlinthText(label!, size: size, weight: FontWeight.w600),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        if (description != null) ...[
          PlinthText(description!,
              size: PlinthSize.xs, color: theme.rampFor(PlinthRole.neutral)),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        Semantics(
          button: true,
          enabled: enabled,
          label: label == null ? 'Choose files' : 'Choose files for $label',
          child: InkWell(
            key: const Key('plinth_file_input_field'),
            onTap: enabled ? _pick : null,
            borderRadius: BorderRadius.circular(resolvedRadius),
            child: Container(
              constraints:
                  BoxConstraints(minHeight: theme.spacing[size]! * 2.2),
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing[size]!,
                vertical: theme.spacing[PlinthSize.xs]! * 0.6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(resolvedRadius),
                border: Border.all(color: borderColor, width: hasError ? 2 : 1),
                color: enabled ? theme.surface : theme.surfaceMuted,
              ),
              child: Row(
                children: [
                  IconTheme(
                    data: IconThemeData(
                      color: enabled ? theme.textMuted : theme.textDisabled,
                      size: fontSize + 2,
                    ),
                    child: leadingIcon ?? const Icon(Icons.attach_file),
                  ),
                  SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.8),
                  Expanded(
                    child: value.isEmpty
                        ? Text(
                            placeholder ?? 'Choose a file',
                            style: TextStyle(
                              color: enabled
                                  ? theme.textMuted
                                  : theme.textDisabled,
                              fontSize: fontSize,
                            ),
                          )
                        : Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              for (final file in value)
                                _FileChip(
                                  label: labelBuilder(file),
                                  fontSize: fontSize - 2,
                                  // Removing a file must not also open
                                  // the picker, so the chip stops the
                                  // tap from reaching the field.
                                  onRemove:
                                      enabled ? () => _remove(file) : null,
                                ),
                            ],
                          ),
                  ),
                  // Wrapped so the tap clears rather than reopening the
                  // picker underneath it, the same guard the file chips
                  // needed.
                  if (clearable && value.isNotEmpty && enabled)
                    GestureDetector(
                      onTap: () => onChanged(const []),
                      child: PlinthCloseButton(
                        size: PlinthSize.xs,
                        semanticLabel: 'Clear selected files',
                        onPressed: () => onChanged(const []),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
          PlinthText(error!,
              size: PlinthSize.xs, color: theme.rampFor(PlinthRole.error)),
        ],
      ],
    );
  }
}

class _FileChip extends StatelessWidget {
  const _FileChip({
    required this.label,
    required this.fontSize,
    required this.onRemove,
  });

  final String label;
  final double fontSize;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Container(
      padding: const EdgeInsets.only(left: 8, right: 2, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: theme.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: fontSize, color: theme.text),
            ),
          ),
          if (onRemove != null)
            PlinthCloseButton(
              size: PlinthSize.xs,
              onPressed: onRemove,
              semanticLabel: 'Remove $label',
            ),
        ],
      ),
    );
  }
}
