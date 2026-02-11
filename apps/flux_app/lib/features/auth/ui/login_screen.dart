import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_provider.dart';

// Change to ConsumerStatefulWidget to access 'ref' and manage TextControllers
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _performLogin() {
    // Evitar doble submit si ya está cargando
    if (ref.read(authControllerProvider).isLoading) return;

    ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the state of the auth controller (Loading, Data, Error)
    final authState = ref.watch(authControllerProvider);

    // 2. Listen for errors globally to show a SnackBar without cluttering build logic
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (state.hasValue &&
          !state.hasError &&
          state.isLoading == false) {
        // Success! In the future, we will navigate to the Dashboard here,
        // or let GoRouter's redirect handle it automatically.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful! 🚀'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.flash_on, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 16),
                const Text(
                  'FLUX',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  // 1. Tecla "Siguiente" en el teclado
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),

                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  // 2. Tecla "Hecho" (Done) en el teclado
                  textInputAction: TextInputAction.done,
                  // 3. Ejecutar login al pulsar Enter
                  onSubmitted: (_) => _performLogin(),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 24),

                FilledButton(
                  // Llamamos al método que acabamos de crear
                  onPressed: authState.isLoading ? null : _performLogin,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Sign In', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
