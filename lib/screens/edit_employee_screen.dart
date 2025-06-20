import 'package:control_verde/services/inventory_service.dart';
import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class EditEmployeeScreen extends StatefulWidget {
  final int id;
  final String username;
  final String fullName;

  const EditEmployeeScreen({
    super.key,
    required this.id,
    required this.username,
    required this.fullName,
  });

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController fullNameController;
  final TextEditingController passwordController = TextEditingController();

  String selectedRole = 'empleado';
  bool canAccessResumen = false;
  bool canAddInventory = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.username);
    fullNameController = TextEditingController(text: widget.fullName);
  }

  @override
  void dispose() {
    usernameController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar empleado'),
        backgroundColor: AppStyles.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFC8E6C9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(usernameController, 'Nombre de usuario'),
              _buildTextField(fullNameController, 'Nombre completo'),
              _buildTextField(passwordController, 'Nueva contraseña', obscure: true),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Elegir rol',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildRoleDropdown(),
              const SizedBox(height: 16),
              if (selectedRole == 'empleado') ...[
                SwitchListTile(
                  title: const Text('Acceder a Resumen'),
                  value: canAccessResumen,
                  onChanged: (value) {
                    setState(() {
                      canAccessResumen = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Añadir al Inventario'),
                  value: canAddInventory,
                  onChanged: (value) {
                    setState(() {
                      canAddInventory = value;
                    });
                  },
                ),
              ],
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 32.0),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await InventoryService().updateUser(
                        id: widget.id,
                        username: usernameController.text.trim(),
                        fullName: fullNameController.text.trim(),
                        password: passwordController.text.isNotEmpty ? passwordController.text.trim() : null,
                        role: selectedRole,
                        canAccessResumen: canAccessResumen,
                        canAddInventory: canAddInventory,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil actualizado exitosamente')),
                      );

                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.pop(context, true);
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al actualizar: $e')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Guardar cambios',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ingrese $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      decoration: const InputDecoration(
        labelText: 'Rol',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'empleado', child: Text('Empleado')),
        DropdownMenuItem(value: 'jefe', child: Text('Jefe')),
      ],
      onChanged: (value) {
        setState(() {
          selectedRole = value ?? 'empleado';
          if (selectedRole == 'jefe') {
            canAccessResumen = true;
            canAddInventory = true;
          }
        });
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar empleado'),
        content: const Text('¿Estás seguro de que quieres eliminar este empleado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: _deleteUser,
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser() async {
    Navigator.pop(context);
    try {
      await InventoryService().deleteUser(widget.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado eliminado')),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, true);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }
}
