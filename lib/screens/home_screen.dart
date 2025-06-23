import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../utils/app_styles.dart';
import 'inventory_screen.dart';
import 'summary_screen.dart';
import 'staff_screen.dart';
import 'add_sale_screen.dart';
import 'add_inventory_screen.dart';
import '../models/user_permissions.dart';

class HomeScreen extends StatefulWidget {
  final UserPermissions userPermissions;

  const HomeScreen({super.key, required this.userPermissions});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _ventas = [];
  bool _isLoadingVentas = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: _getTabCount(),
      vsync: this,
    );

    _tabController.addListener(() {
      setState(() {});
    });

    _loadVentas();
  }

  int _getTabCount() {
    int count = 2; // inicio + inventario
    if (widget.userPermissions.role == 'jefe' || widget.userPermissions.canAccessResumen) {
      count++;
    }
    if (widget.userPermissions.role == 'jefe' || widget.userPermissions.canAccessControlPersonal) {
      count++;
    }
    return count;
  }

  Future<void> _loadVentas() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3001/ventas'));

      print('DEBUG VENTAS RESPONSE CODE: ${response.statusCode}');
      print('DEBUG VENTAS RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ordenar por fecha descendente y limitar a 20
        data.sort((a, b) => DateTime.parse(b['fecha']).compareTo(DateTime.parse(a['fecha'])));
        final limitedData = data.take(20).toList();

        setState(() {
          _ventas = limitedData;
          _isLoadingVentas = false;
        });
      } else {
        setState(() {
          _isLoadingVentas = false;
        });
        _showError('Error al cargar ventas');
      }
    } catch (e) {
      setState(() {
        _isLoadingVentas = false;
      });
      _showError('Error de conexión: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final canAddSale = widget.userPermissions.canAddSale;
    final canAddInventory = widget.userPermissions.canAddInventory;

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
          tabs: _buildTabs(),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: _buildTabViews(),
          ),
          if (_tabController.index == 0)
            _buildBotonesSegunPermiso(canAddSale, canAddInventory),
        ],
      ),
      backgroundColor: AppStyles.lightBackground,
    );
  }

  List<Widget> _buildTabs() {
    List<Widget> tabs = [
      const Tab(icon: Icon(Icons.home)),
      const Tab(icon: Icon(Icons.inventory)),
    ];

    if (widget.userPermissions.role == 'jefe' || widget.userPermissions.canAccessResumen) {
      tabs.add(const Tab(icon: Icon(Icons.show_chart)));
    }

    if (widget.userPermissions.role == 'jefe' || widget.userPermissions.canAccessControlPersonal) {
      tabs.add(const Tab(icon: Icon(Icons.people)));
    }

    return tabs;
  }

  List<Widget> _buildTabViews() {
    List<Widget> views = [
      _buildInicioTab(),
      InventoryScreen(userPermissions: widget.userPermissions),
    ];

    if (widget.userPermissions.role == 'jefe' || widget.userPermissions.canAccessResumen) {
      views.add(const SummaryScreen());
    }

    if (widget.userPermissions.role == 'jefe' || widget.userPermissions.canAccessControlPersonal) {
      views.add(const StaffScreen());
    }

    return views;
  }

  Widget _buildInicioTab() {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        Expanded(
          child: _isLoadingVentas
              ? const Center(child: CircularProgressIndicator())
              : _ventas.isEmpty
                  ? const Center(child: Text('No hay ventas registradas.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: _ventas.length,
                      itemBuilder: (_, index) {
                        final venta = _ventas[index];

                        final fecha = DateFormat('dd/MM/yyyy HH:mm').format(
                          DateTime.parse(venta['fecha']),
                        );

                        final empleado = venta['empleado']?['fullName'] ?? 'Desconocido';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ExpansionTile(
                            leading: Icon(Icons.shopping_cart, color: AppStyles.primaryGreen),
                            title: Text('Venta #${venta['id']} - Lps. ${venta['total']}'),
                            subtitle: Text('Fecha: $fecha | Empleado: $empleado'),
                            children: (venta['detalles'] as List<dynamic>).map((detalle) {
                              final producto = detalle['producto'];
                              final nombreProducto = producto?['name'] ?? 'Producto desconocido';
                              final cantidad = detalle['cantidad'];
                              final precio = detalle['precioUnitario'];
                              final subtotal = (precio * cantidad).toStringAsFixed(2);

                              return ListTile(
                                title: Text('$nombreProducto x$cantidad'),
                                subtitle: Text('Lps. $precio c/u'),
                                trailing: Text('Subtotal: Lps. $subtotal'),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildBotonesSegunPermiso(bool canAddSale, bool canAddInventory) {
    List<Widget> botones = [];

    if (canAddSale) {
      botones.add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddSaleScreen(
                    canModifyPrice: widget.userPermissions.canAddInventory,
                    empleadoId: widget.userPermissions.empleadoId,
                  ),
                ),
              );
              _loadVentas();
            },
            child: const Text('Añadir venta', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    if (canAddInventory) {
      if (botones.isNotEmpty) {
        botones.add(const SizedBox(width: 10));
      }
      botones.add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddInventoryScreen()),
              );
            },
            child: const Text('Añadir inventario', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    if (botones.isEmpty) {
      return const SizedBox();
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
}
