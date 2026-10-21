enum UserRole {
  user('Người dùng'),
  doctor('Bác sĩ'),
  admin('Quản trị viên');

  const UserRole(this.label);
  final String label;

  static UserRole parse(Object? value) => UserRole.values.firstWhere(
        (role) => role.name == value,
        orElse: () => throw const FormatException('Vai trò không hợp lệ.'),
      );
}

class AppUser {
  const AppUser({required this.uid, required this.email, required this.role});

  final String uid;
  final String email;
  final UserRole role;

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) => AppUser(
        uid: uid,
        email: data['email'] as String? ?? '',
        role: UserRole.parse(data['role']),
      );
}
