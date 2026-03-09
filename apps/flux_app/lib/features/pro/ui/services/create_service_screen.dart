import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/service_type.dart';
import '../../../../core/models/service.dart';
import '../../../../core/repositories/service_repository.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  final String organizationId;

  const CreateServiceScreen({super.key, required this.organizationId});

  @override
  ConsumerState<CreateServiceScreen> createState() =>
      _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '60');
  final _priceController = TextEditingController(text: '0.00');
  final _capacityController = TextEditingController(text: '1');

  ServiceType _selectedType = ServiceType.classType;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final duration = int.parse(_durationController.text);
      final price = double.parse(_priceController.text);
      final capacity = int.parse(_capacityController.text);

      final service = Service(
        id: '', // Supabase will generate this
        organizationId: widget.organizationId,
        name: name,
        description: description.isEmpty ? null : description,
        type: _selectedType,
        durationMinutes: duration,
        price: price,
        isActive: _isActive,
        maxParticipants: capacity,
        createdAt: DateTime.now(),
      );

      await ref.read(serviceRepositoryProvider).createService(service);

      // Invalidate the provider to refresh the services list
      ref.invalidate(servicesByOrganizationProvider(widget.organizationId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio creado correctamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el servicio: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Servicio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Servicio',
                  hintText: 'Ej. Entrenamiento Funcional',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ServiceType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Servicio',
                  border: OutlineInputBorder(),
                ),
                items: ServiceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == ServiceType.classType ? 'Clase' : 'Cita'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duración (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Invalido';
                        }
                        if (int.parse(value) <= 0) return 'Mayor a 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio (\$)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null) {
                          return 'Invalido';
                        }
                        if (double.parse(value) < 0) return 'Positivo';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacidad Máxima',
                  helperText: 'Nº máximo de clientes',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Número invalido';
                  }
                  if (int.parse(value) < 1) return 'Mínimo 1';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Servicio Activo'),
                subtitle: const Text(
                  'Si está inactivo, los clientes no podrán reservarlo.',
                ),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Crear Servicio',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
