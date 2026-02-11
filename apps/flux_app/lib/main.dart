import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flux_app/config/router.dart'; // Tu router

Future<void> main() async {
  // ⚠️ VITAL: Asegurar la inicialización de los bindings antes de usar await
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cargar el .env
  await dotenv.load(fileName: ".env");

  // 2. Despertar a Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 3. Arrancar la app envuelta en Riverpod
  runApp(const ProviderScope(child: FluxApp()));
}

class FluxApp extends ConsumerWidget {
  const FluxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Flux',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router, // Inject the reactive router
    );
  }
}
