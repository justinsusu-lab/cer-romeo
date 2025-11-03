// Conditional import/export: use web implementation when building for web
export 'web_svg_view_nonweb.dart'
    if (dart.library.html) 'web_svg_view_web.dart';
