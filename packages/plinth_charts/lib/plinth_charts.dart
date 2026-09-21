/// Charts for Plinth UI.
///
/// Themed from the same tokens as everything else, and built on the
/// categorical palette in `plinth_core` that is validated against
/// protanopia, deuteranopia and tritanopia — a chart whose series are
/// told apart by colour alone is a chart a tenth of its readers cannot
/// use.
///
/// Every chart here carries a text alternative built from its own data,
/// because a chart is pixels and pixels say nothing.
library;

export 'package:plinth_core/plinth_core.dart';

export 'src/plinth_sparkline.dart';
