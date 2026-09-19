import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The root of the semantics tree the test surface is currently
/// rendering.
///
/// Every accessibility test here walks the tree from its root, and each
/// used to reach it through `tester.binding.pipelineOwner`, which is
/// deprecated: since multi-view, a binding owns a *tree* of
/// [PipelineOwner]s and the semantics live on a child of the root, not
/// on the root itself. Reading `semanticsOwner` off any single owner
/// assumes the single-view shape that deprecation exists to retire.
///
/// So this descends from [RendererBinding.rootPipelineOwner] looking
/// for the first owner that has a semantics tree, which is what
/// `flutter_test`'s own `find.semantics` does internally.
///
/// Call [WidgetTester.ensureSemantics] first — without a live handle
/// there is no tree to find and this throws [StateError] saying so,
/// rather than the bare null-check failure the old expression gave.
SemanticsNode rootSemanticsNode(WidgetTester tester) {
  SemanticsNode? found;

  void visit(PipelineOwner owner) {
    found ??= owner.semanticsOwner?.rootSemanticsNode;
    if (found == null) owner.visitChildren(visit);
  }

  visit(tester.binding.rootPipelineOwner);

  if (found == null) {
    throw StateError(
      'No semantics tree. Call tester.ensureSemantics() before this, and '
      'dispose the handle it returns when the test is done.',
    );
  }
  return found!;
}
