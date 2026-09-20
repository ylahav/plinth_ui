import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// What a [PlinthContactBlock] hands back when it is sent.
typedef PlinthContactValues = ({String name, String email, String message});

/// A "get in touch" form, with room for what surrounds it.
///
/// Covers the contact arrangements that are a form plus context: the
/// form alone, the form beside your address, the form beside your
/// opening hours. [aside] is whatever that context is.
///
/// ```dart
/// PlinthContactBlock(
///   onSubmit: (values) => support.send(values),
///   subtitle: 'We usually reply within a working day.',
///   aside: const PlinthDataList(items: [
///     PlinthDataListItem.text('Weekdays', '9–17 UTC'),
///     PlinthDataListItem.text('Weekends', 'Closed'),
///   ]),
/// )
/// ```
///
/// **Put the reply window in [subtitle] or [aside].** Knowing it before
/// writing changes what people write and whether they wait, and a form
/// that only says it after sending has told them too late to be useful.
class PlinthContactBlock extends StatefulWidget {
  const PlinthContactBlock({
    super.key,
    this.onSubmit,
    this.title = 'Get in touch',
    this.subtitle,
    this.nameLabel = 'Name',
    this.emailLabel = 'Email',
    this.emailPlaceholder = 'you@example.com',
    this.messageLabel = 'Message',
    this.messagePlaceholder = 'How can we help?',
    this.submitLabel = 'Send',
    this.showName = true,
    this.messageLines = 3,
    this.aside,
    this.asideOnLeft = false,
    this.minSplitWidth = 520,
    this.width,
    this.titleOrder = 3,
    this.sent = false,
    this.sentTitle = 'Thanks — that is with us',
    this.sentMessage = 'We will reply to the address you gave.',
  });

  /// Called with what was typed. Null disables the send button.
  final ValueChanged<PlinthContactValues>? onSubmit;

  final String title;
  final String? subtitle;
  final String nameLabel;
  final String emailLabel;
  final String? emailPlaceholder;
  final String messageLabel;
  final String? messagePlaceholder;
  final String submitLabel;

  /// Whether to ask for a name. Off for a form that only needs a reply
  /// address — every field is one more reason not to send.
  final bool showName;

  final int messageLines;

  /// Context beside the form: an address, opening hours, other ways to
  /// reach you. Moves under the form when there is no room for two.
  final Widget? aside;

  final bool asideOnLeft;
  final double minSplitWidth;
  final double? width;
  final int titleOrder;

  /// Whether the message has been sent — swaps the form for an
  /// acknowledgement.
  ///
  /// Part of the block for the same reason the password-reset
  /// confirmation is: a form that submits and then looks unchanged
  /// reads as broken, and the result is the same message sent four
  /// times.
  final bool sent;

  final String sentTitle;
  final String sentMessage;

  @override
  State<PlinthContactBlock> createState() => _PlinthContactBlockState();
}

class _PlinthContactBlockState extends State<PlinthContactBlock> {
  String _name = '';
  String _email = '';
  String _message = '';

  void _submit() => widget.onSubmit?.call((
        name: _name,
        email: _email,
        message: _message,
      ));

  @override
  Widget build(BuildContext context) {
    final form = widget.sent ? _acknowledgement() : _form();

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (widget.width ?? double.infinity);

        if (widget.aside == null) return form;

        if (available < widget.minSplitWidth) {
          return PlinthStack(
            gap: PlinthSize.lg,
            children: [form, widget.aside!],
          );
        }

        final panes = <Widget>[
          Expanded(child: form),
          const SizedBox(width: 24),
          Expanded(child: widget.aside!),
        ];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.asideOnLeft ? panes.reversed.toList() : panes,
        );
      },
    );

    return widget.width == null
        ? body
        : SizedBox(width: widget.width, child: body);
  }

  Widget _acknowledgement() {
    return PlinthStack(
      gap: PlinthSize.sm,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlinthTitle(widget.sentTitle, order: widget.titleOrder),
        PlinthText(widget.sentMessage, size: PlinthSize.sm, color: 'gray'),
      ],
    );
  }

  Widget _form() {
    return PlinthStack(
      gap: PlinthSize.sm,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlinthTitle(widget.title, order: widget.titleOrder),
        if (widget.subtitle case final subtitle?)
          PlinthText(subtitle, size: PlinthSize.sm, color: 'gray'),
        if (widget.showName)
          PlinthTextInput(
            label: widget.nameLabel,
            onChanged: (value) => _name = value,
          ),
        PlinthTextInput(
          label: widget.emailLabel,
          placeholder: widget.emailPlaceholder,
          onChanged: (value) => _email = value,
        ),
        PlinthTextarea(
          label: widget.messageLabel,
          placeholder: widget.messagePlaceholder,
          minLines: widget.messageLines,
          onChanged: (value) => _message = value,
        ),
        PlinthButton(
          fullWidth: true,
          onPressed: widget.onSubmit == null ? null : _submit,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
