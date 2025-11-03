// lib/ui/widgets/weather_iframe_view.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: undefined_prefixed_name
import 'dart:ui_web' as ui_web;

class WeatherIFrameView extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  const WeatherIFrameView({
    Key? key,
    required this.url,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<WeatherIFrameView> createState() => _WeatherIFrameViewState();
}

class _WeatherIFrameViewState extends State<WeatherIFrameView> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    assert(kIsWeb, 'WeatherIFrameView è supportato solo su Web.');
    _viewType =
        'weather-${widget.url.hashCode}-${DateTime.now().microsecondsSinceEpoch}';
    final wrapper = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%';
    final iframe = html.IFrameElement()
      ..src = widget.url
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'fullscreen'
      ..allowFullscreen = true;
    wrapper.append(iframe);
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId, {Object? params}) => wrapper,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
