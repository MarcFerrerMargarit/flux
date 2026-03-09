import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/profile.dart';
import '../../../../core/repositories/organization_repository.dart';
import '../../../auth/data/auth_provider.dart';
import '../services/services_screen.dart';

class SettingsScreen extends ConsumerWidget {
  final Profile profile;

  const SettingsScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D47A1)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ajustes del Centro',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Negocio
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Negocio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.design_services, color: Colors.blue),
                  title: const Text('Mis Servicios'),
                  subtitle: const Text('Gestiona clases y citas ofrecidas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServicesScreen(profile: profile),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                Consumer(
                  builder: (context, ref, child) {
                    if (profile.organizationId == null) return const SizedBox();
                    
                    final orgAsync = ref.watch(userOrganizationsProvider(profile.id));
                    
                    return orgAsync.when(
                      data: (orgs) {
                        return ListTile(
                          leading: const Icon(Icons.share, color: Colors.indigo),
                          title: const Text('Código de Invitación'),
                          subtitle: const Text('Invita a clientes a tu centro'),
                          trailing: const Icon(Icons.copy),
                          onTap: () async {
                            try {
                              final org = await ref.read(organizationRepositoryProvider).getOrganizationById(profile.organizationId!);
                              if (org != null && org.inviteCode != null && context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Código de Invitación', textAlign: TextAlign.center),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Comparte este código con tus clientes para que se unan a tu centro.', textAlign: TextAlign.center),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            org.inviteCode!,
                                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                        );
                      },
                      loading: () => const ListTile(title: Text('Cargando...')),
                      error: (_, __) => const SizedBox(),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.purple),
                  title: const Text('Horarios de Apertura'),
                  subtitle: const Text('Define cuándo se pueden hacer reservas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to StaffScheduleScreen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente...')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.store, color: Colors.green),
                  title: const Text('Perfil del Centro'),
                  subtitle: const Text('Nombre, logo y detalles básicos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to Edit Organization Profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente...')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          
          // Section: Cuenta
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Cuenta',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.orange),
                  title: const Text('Mi Perfil Personal'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to Edit Personal Profile
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  onTap: () => ref.read(authControllerProvider.notifier).logout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
