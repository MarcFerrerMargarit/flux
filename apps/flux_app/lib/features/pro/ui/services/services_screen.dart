import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/profile.dart';
import '../../../../core/repositories/service_repository.dart';
import 'create_service_screen.dart';

class ServicesScreen extends ConsumerWidget {
  final Profile profile;

  const ServicesScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (profile.organizationId == null) {
      return const Scaffold(
        body: Center(child: Text('No perteneces a ninguna organización.')),
      );
    }

    final servicesAsync = ref.watch(
        servicesByOrganizationProvider(profile.organizationId!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateServiceScreen(organizationId: profile.organizationId!),
                ),
              );
            },
          ),
        ],
      ),
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.design_services, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay servicios creados.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateServiceScreen(
                              organizationId: profile.organizationId!),
                        ),
                      );
                    },
                    child: const Text('Crear mi primer servicio'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.class_,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(service.name),
                subtitle: Text(
                  '${service.durationMinutes} min • \$${service.price.toStringAsFixed(2)}\n'
                  '${service.maxParticipants} participantes max',
                ),
                isThreeLine: true,
                trailing: Switch(
                  value: service.isActive,
                  onChanged: (bool value) async {
                    try {
                      await ref.read(serviceRepositoryProvider).updateService(
                            service.copyWith(isActive: value),
                          );
                      // Invalidate to refresh the list
                      ref.invalidate(
                          servicesByOrganizationProvider(profile.organizationId!));
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar: $e')),
                        );
                      }
                    }
                  },
                ),
                onTap: () {
                  // TODO: Navigate to Edit Service Screen
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error al cargar servicios:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
