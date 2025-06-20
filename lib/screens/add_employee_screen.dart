import 'package:control_verde/services/inventory_service.dart';
import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedRole = 'empleado';
  bool canAccessResumen = false;
  bool canAddInventory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.lightBackground,
      appBar: AppBar(
        title: const Text('Añadir empleado'),
        backgroundColor: AppStyles.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(usernameController, 'Nombre de usuario'),
              _buildTextField(fullNameController, 'Nombre completo'),
              _buildTextField(passwordController, 'Contraseña', obscure: true),
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
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await InventoryService().createUser(
                        username: usernameController.text.trim(),
                        fullName: fullNameController.text.trim(),
                        password: passwordController.text.trim(),
                        role: selectedRole,
                        canAccessResumen: canAccessResumen,
                        canAddInventory: canAddInventory,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Empleado creado exitosamente')),
                      );

                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.pop(context, true);
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al crear empleado: $e')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Guardar empleado',
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
}
