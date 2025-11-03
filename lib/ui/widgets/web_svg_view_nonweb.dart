import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WebSvgView extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  const WebSvgView({Key? key, required this.assetPath, this.width, this.height})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.white,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        placeholderBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
