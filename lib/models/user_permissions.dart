class UserPermissions {
  final int empleadoId;
  final String role;
  final bool canAccessResumen;
  final bool canAccessControlPersonal;
  final bool canAddSale;
  final bool canAddInventory;

  UserPermissions({
    required this.empleadoId,
    required this.role,
    required this.canAccessResumen,
    required this.canAccessControlPersonal,
    required this.canAddSale,
    required this.canAddInventory,
  });

  factory UserPermissions.fromMap(Map<String, dynamic> data) {
    return UserPermissions(
      empleadoId: data['id'],
      role: data['role'] ?? 'empleado',
      canAccessResumen: data['canAccessResumen'] ?? false,
      canAccessControlPersonal: data['canAccessControlPersonal'] ?? false,
      canAddSale: data['canAddSale'] ?? false,
      canAddInventory: data['canAddInventory'] ?? false,
    );
  }
}
