import '../l10n/app_text.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';

class RoleGuard extends StatelessWidget {
  const RoleGuard({
    super.key,
    required this.role,
    required this.allowedRoles,
    required this.child,
  });

  final UserRole role;
  final Set<UserRole> allowedRoles;
  final Widget child;

  @override
  Widget build(BuildContext context) => allowedRoles.contains(role)
      ? child
      : const Center(
          child: AppText('Bạn không có quyền truy cập khu vực này.'));
}
