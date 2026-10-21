import '../../l10n/app_text.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/user_repository.dart';
import '../../models/app_user.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage(
      {super.key, required this.currentUser, required this.repository});

  final AppUser currentUser;
  final UserRepository repository;

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late final Stream<List<AppUser>> _users = widget.repository.watchUsers();
  final Set<String> _saving = {};

  Future<void> _changeRole(AppUser user, UserRole role) async {
    if (role == user.role ||
        user.uid == widget.currentUser.uid ||
        _saving.contains(user.uid)) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('Thay đổi vai trò'),
        content: AppText(
            'Chuyển ${user.email} từ ${user.role.label} thành ${role.label}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const AppText('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const AppText('Xác nhận')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving.add(user.uid));
    try {
      await widget.repository.changeRole(user.uid, role);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText('Đã cập nhật vai trò.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: AppText(
                'Không thể đổi vai trò. Kiểm tra kết nối và quyền quản trị.')),
      );
    } finally {
      if (mounted) setState(() => _saving.remove(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<AppUser>>(
        stream: _users,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: AppText(
                    'Không thể tải tài khoản. Kiểm tra quyền truy cập và kết nối.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const AppText('Quản lý tài khoản',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading)),
              const SizedBox(height: 8),
              const AppText(
                  'Chỉ quản trị viên được cấp hoặc thu hồi vai trò. Bạn không thể đổi vai trò của chính mình.'),
              const SizedBox(height: 16),
              if (users.isEmpty) const AppText('Chưa có hồ sơ tài khoản.'),
              for (final user in users)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email.isEmpty ? user.uid : user.email,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        SelectableText('UID: ${user.uid}'),
                        const SizedBox(height: 8),
                        DropdownButton<UserRole>(
                          value: user.role,
                          isExpanded: true,
                          items: [
                            for (final role in UserRole.values)
                              DropdownMenuItem(
                                  value: role, child: AppText(role.label))
                          ],
                          onChanged: user.uid == widget.currentUser.uid ||
                                  _saving.contains(user.uid)
                              ? null
                              : (role) {
                                  if (role != null) _changeRole(user, role);
                                },
                        ),
                        if (_saving.contains(user.uid))
                          const LinearProgressIndicator(),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      );
}
