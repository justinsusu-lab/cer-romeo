import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'new_password_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final bool isPasswordRecovery;

  const EmailVerificationPage({
    Key? key,
    required this.email,
    this.isPasswordRecovery = false,
  }) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isVerifying = false;
  String? _errorText;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _verifyEmail() async {
    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    try {
      if (widget.isPasswordRecovery) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NewPasswordPage(email: widget.email),
          ),
        );
      } else {
        User? user = _auth.currentUser;
        await user?.reload();
        user = _auth.currentUser;
        if (user != null && user.emailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verifica completata! Benvenuto!')),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          setState(() {
            _errorText =
                'La email non risulta ancora verificata. Controlla la tua casella.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorText = 'Errore durante la verifica: $e';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const grassGreen = Color(0xFF43AA8B);
    const turquoise = Color(0xFF00B4D8);

    return Scaffold(
      backgroundColor: turquoise.withOpacity(0.07),
      appBar: AppBar(
        title: const Text("Verifica Email"),
        backgroundColor: grassGreen,
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: turquoise.withOpacity(0.15),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Abbiamo inviato una mail di verifica a:\n${widget.email}\n"
                "Segui il link contenuto nella mail per confermare il tuo indirizzo.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: grassGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isVerifying ? null : _verifyEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: grassGreen,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: _isVerifying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Ho verificato la mail",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 18),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
