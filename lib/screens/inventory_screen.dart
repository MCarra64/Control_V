import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import 'add_category_screen.dart';
import 'category_detail_screen.dart';
import '../services/inventory_service.dart';
import '../models/user_permissions.dart';

class InventoryScreen extends StatefulWidget {
  final UserPermissions userPermissions;

  const InventoryScreen({super.key, required this.userPermissions});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<dynamic>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = InventoryService().fetchCategories();
  }

  Future<void> _refresh() async {
    setState(() {
      _categoriesFuture = InventoryService().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Inventario',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No hay categorías disponibles.'));
                    }

                    final categories = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: categories.map((cat) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyles.accentGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryDetailScreen(
                                    categoryName: cat['name'],
                                    categoryId: cat['id'],
                                    userPermissions: widget.userPermissions,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              cat['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppStyles.textDark,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        if (widget.userPermissions.canAddInventory)
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddCategoryScreen(),
                  ),
                ).then((_) => _refresh());
              },
              child: const Text(
                'Añadir categoría',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
