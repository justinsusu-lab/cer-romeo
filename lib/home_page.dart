import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        // Load SVG asset and show loading/error states
        child: FutureBuilder<String>(
          future: rootBundle.loadString('assets/diagrams/cer_animata.svg'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(height: 8),
                  Text('SVG non trovato o errore nel caricamento.'),
                ],
              );
            } else {
              return SvgPicture.string(
                snapshot.data!,
                width: 600,
                height: 400,
                fit: BoxFit.contain,
                placeholderBuilder: (context) =>
                    const CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
