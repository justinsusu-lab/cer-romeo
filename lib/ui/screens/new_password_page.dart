import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;

  const NewPasswordPage({super.key, required this.email});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isSaving = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le password non corrispondono')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Utente non autenticato')));
        return;
      }

      // Nota: potrebbe essere richiesta una "recent login" da Firebase
      await user.updatePassword(passwordController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password aggiornata con successo')),
      );

      // Torna alla prima schermata dello stack (es. login/home)
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      final message =
          e.message ?? "Errore durante l'aggiornamento della password";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const yellowOrange = Color(0xFFF9D923);
    const blue = Color(0xFF3A86FF);
    const grassGreen = Color(0xFF43AA8B);
    const turquoise = Color(0xFF00B4D8);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuova Password"),
        backgroundColor: grassGreen,
      ),
      backgroundColor: turquoise.withOpacity(0.07),
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Nuova Password",
                    style: TextStyle(color: blue, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Inserisci nuova password",
                    filled: true,
                    fillColor: yellowOrange.withOpacity(0.13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'La password deve contenere almeno 6 caratteri';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Conferma Password",
                    style: TextStyle(color: blue, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Conferma nuova password",
                    filled: true,
                    fillColor: yellowOrange.withOpacity(0.13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'La password deve contenere almeno 6 caratteri';
                    }
                    if (value != passwordController.text) {
                      return 'Le password non corrispondono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _savePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: grassGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Salva",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
