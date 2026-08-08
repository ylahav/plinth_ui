import 'package:flutter/foundation.dart';

/// A `ChangeNotifier`-based equivalent of Mantine's `useDisclosure`
/// hook — tracks a single open/closed boolean and exposes imperative
/// `open()` / `close()` / `toggle()` methods, so it can drive Modal,
/// Drawer, Popover, or any other overlay's visibility.
///
/// ```dart
/// class _MyPageState extends State<MyPage> {
///   final _modal = PlinthDisclosureController();
///
///   @override
///   void dispose() {
///     _modal.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return ListenableBuilder(
///       listenable: _modal,
///       builder: (context, _) => PlinthButton(
///         onPressed: _modal.open,
///         child: Text(_modal.isOpen ? 'Open!' : 'Closed'),
///       ),
///     );
///   }
/// }
/// ```
class PlinthDisclosureController extends ChangeNotifier {
  PlinthDisclosureController({bool initiallyOpen = false})
      : _isOpen = initiallyOpen;

  bool _isOpen;

  /// Whether the controlled element is currently open.
  bool get isOpen => _isOpen;

  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  void toggle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }
}
