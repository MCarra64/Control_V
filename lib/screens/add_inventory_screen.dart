import 'package:flutter/material.dart';

class AddInventoryScreen extends StatelessWidget {
  const AddInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Inventario')),
      body: const Center(
        child: Text('Aquí irá el formulario para añadir inventario'),
      ),
    );
  }
}
