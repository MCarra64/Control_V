import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../services/inventory_service.dart';

class TagManagementScreen extends StatefulWidget {
  final int productId;
  final List<Map<String, dynamic>> initialTags;

  const TagManagementScreen({
    super.key,
    required this.productId,
    required this.initialTags,
  });

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  late List<Map<String, dynamic>> tags;
  List<Map<String, dynamic>> availableTags = [];
  final InventoryService _service = InventoryService();

  @override
  void initState() {
    super.initState();
    tags = List.from(widget.initialTags);
    _loadAvailableTags();
  }

  Future<void> _loadAvailableTags() async {
    try {
      final fetchedTags = await _service.fetchAvailableTags();
      setState(() {
        availableTags = fetchedTags;
      });
    } catch (e) {
      _showError(context, 'Error al cargar etiquetas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar etiquetas'),
        backgroundColor: AppStyles.primaryGreen,
      ),
      backgroundColor: const Color(0xFFC8E6C9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                GestureDetector(
                  onTap: () {
                    _showAddTagDialog(context);
                  },
                  child: Chip(
                    label: const Text(
                      'Añadir etiqueta',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppStyles.primaryGreen,
                    avatar: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1.5, color: Colors.grey),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.label, color: AppStyles.primaryGreen),
                    title: Text(tag['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        _showConfirmDeleteDialog(context, tag);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    if (availableTags.isEmpty) {
      _showError(context, 'No hay etiquetas disponibles.');
      return;
    }
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Selecciona una etiqueta o crea nueva'),
        children: [
          ...availableTags.map((tag) => SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _addTag(tag);
                },
                child: Text(tag['name']),
              )),
          const Divider(),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showCreateNewTagDialog(context);
            },
            child: const Row(
              children: [
                Icon(Icons.add, color: AppStyles.primaryGreen),
                SizedBox(width: 8),
                Text('Crear nueva etiqueta', style: TextStyle(color: AppStyles.primaryGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateNewTagDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva etiqueta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Ingrese el nombre de la etiqueta'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryGreen),
            onPressed: () async {
              final newTagName = controller.text.trim();
              if (newTagName.isNotEmpty) {
                Navigator.pop(context);
                try {
                  final newTagId = await _service.createTag(newTagName);
                  await _service.addTagToProduct(widget.productId, newTagId);
                  setState(() {
                    tags.add({'id': newTagId, 'name': newTagName});
                    availableTags.add({'id': newTagId, 'name': newTagName});
                  });
                } catch (e) {
                  _showError(context, 'Error al crear etiqueta: $e');
                }
              }
            },
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteDialog(BuildContext context, Map<String, dynamic> tag) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Qué deseas hacer con la etiqueta "${tag['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.removeTagFromProduct(widget.productId, tag['id']);
                setState(() {
                  tags.removeWhere((t) => t['id'] == tag['id']);
                });
              } catch (e) {
                _showError(context, 'Error al quitar la etiqueta del producto: $e');
              }
            },
            child: const Text('Quitar del producto'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.deleteTag(tag['id']);
                setState(() {
                  tags.removeWhere((t) => t['id'] == tag['id']);
                  availableTags.removeWhere((t) => t['id'] == tag['id']);
                });
              } catch (e) {
                _showError(context, 'Error al eliminar etiqueta del sistema: $e');
              }
            },
            child: const Text('Eliminar del sistema', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addTag(Map<String, dynamic> tag) async {
    try {
      await _service.addTagToProduct(widget.productId, tag['id']);
      if (!tags.any((t) => t['id'] == tag['id'])) {
        setState(() {
          tags.add(tag);
        });
      }
    } catch (e) {
      _showError(context, 'Error al añadir etiqueta: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
