import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import 'inventory_screen.dart';
import 'summary_screen.dart';
import 'staff_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Simulación de permisos cargados desde backend (esto lo asignas al iniciar sesión)
  bool canAddSale = true;       // Simula el permiso de añadir venta
  bool canAddInventory = false; // Simula el permiso de añadir inventario

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verdurería el Ahorro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppStyles.primaryGreen,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppStyles.lightBackground,
          labelColor: Colors.white,
          unselectedLabelColor: AppStyles.textLight,
          tabs: const [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.inventory)),
            Tab(icon: Icon(Icons.show_chart)),
            Tab(icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInicioTab(),
          const InventoryScreen(),
          const SummaryScreen(),
          const StaffScreen(),
        ],
      ),
      backgroundColor: AppStyles.lightBackground,
    );
  }

  Widget _buildInicioTab() {
    return Stack(
      children: [
        Column(
          children: [
            // Mensaje temporal
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              child: const Text(
                'Mensaje temporal',
                style: TextStyle(fontSize: 16),
              ),
            ),

            // Lista de ventas / inventario
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                children: [
                  _buildListItem(Icons.shopping_cart, 'Venta', 'Descripción de la venta'),
                  _buildListItem(Icons.inventory, 'Inventario Agregado', 'Descripción del inventario agregado'),
                  _buildListItem(Icons.shopping_cart, 'Venta', 'Descripción de la venta'),
                  _buildListItem(Icons.inventory, 'Inventario Agregado', 'Descripción del inventario agregado'),

                ],
              ),
            ),
          ],
        ),
        _buildBotonesSegunPermiso()
      ],
    );
  }

  Widget _buildBotonesSegunPermiso() {
    List<Widget> botones = [];

    if (canAddSale) {
      botones.add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            onPressed: () {
              // Acción para añadir venta
            },
            child: const Text(
              'Añadir venta',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      );
    }

    if (canAddInventory) {
      if (botones.isNotEmpty) {
        botones.add(const SizedBox(width: 10)); // Espaciador si hay ambos
      }
      botones.add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            onPressed: () {
              // Acción para añadir inventario
            },
            child: const Text(
              'Añadir inventario',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      );
    }

    if (botones.isEmpty) {
      return const SizedBox(); // No muestra nada si no hay permisos
    }

    return Positioned(
      bottom: 32,
      left: 16,
      right: 16,
      child: Row(
        children: botones,
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: AppStyles.primaryGreen),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
