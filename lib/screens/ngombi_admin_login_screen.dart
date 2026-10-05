import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/ngombi_supabase_config.dart';
import '../services/ngombi_ad_server_repository.dart';
import 'ngombi_ad_manager_screen.dart';

class NgombiAdminLoginScreen extends StatefulWidget {
  const NgombiAdminLoginScreen({super.key});

  @override
  State<NgombiAdminLoginScreen> createState() => _NgombiAdminLoginScreenState();
}

class _NgombiAdminLoginScreenState extends State<NgombiAdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!NgombiSupabaseConfig.isConfigured) {
      _message('Le serveur publicitaire NGOMBI n’est pas encore configuré.');
      return;
    }

    setState(() => _loading = true);

    try {
      final client = Supabase.instance.client;

      final response = await client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Connexion refusée.');
      }

      final adminResult = await client.rpc(
        'is_ngombi_admin',
        params: {'p_user_id': user.id},
      );

      if (adminResult != true) {
        await client.auth.signOut();
        throw const AuthException(
          'Ce compte n’est pas autorisé à administrer NGOMBI.',
        );
      }

      final ads = await NgombiAdServerRepository().loadAdminAds();

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NgombiAdManagerScreen(
            ads: ads,
            remoteSave: NgombiAdServerRepository().saveAds,
          ),
        ),
      );
    } on AuthException catch (e) {
      _message(e.message);
    } on PostgrestException catch (e) {
      _message('Erreur serveur NGOMBI : ${e.message}');
    } catch (e) {
      _message('Erreur de connexion NGOMBI : $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administration NGOMBI')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 64,
                      color: Color(0xFFFFA21A),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Gestion publicitaire',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Accès réservé à l’administrateur NGOMBI.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email administrateur',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _login,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login_rounded),
                        label: Text(
                          _loading ? 'Connexion…' : 'Se connecter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
