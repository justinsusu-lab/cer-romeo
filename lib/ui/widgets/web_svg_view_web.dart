// Web-only implementation: embeds the SVG via an <object> tag so browser animations/SMIL/CSS run.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: undefined_prefixed_name
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WebSvgView extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  const WebSvgView({Key? key, required this.assetPath, this.width, this.height})
    : super(key: key);

  @override
  State<WebSvgView> createState() => _WebSvgViewState();
}

class _WebSvgViewState extends State<WebSvgView> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType =
        'web-svg-${widget.assetPath.hashCode}-${DateTime.now().microsecondsSinceEpoch}';

    final object = html.Element.tag('object');
    object.setAttribute('type', 'image/svg+xml');
    object.setAttribute('data', widget.assetPath);
    object.style.width = '100%';
    object.style.height = '100%';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => object,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
