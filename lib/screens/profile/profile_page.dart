import '../../l10n/app_text.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/pet_repository.dart';
import '../../data/app_data_repository.dart';
import '../../models/pet.dart';
import '../../models/app_user.dart';
import '../../l10n/language_picker.dart';
import '../pet/pet_detail_page.dart';
import '../pet/add_pet_page.dart';
import 'settings_page.dart';
import '../../widgets/app_data_scope.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.account});
  final AppUser? account;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color primary = Color(0xFF1F41BB);
  static const Color bg = Color(0xFFF5F6F7);
  bool get _isPetOwner =>
      (widget.account?.role ?? UserRole.user) == UserRole.user;

  Future<void> _openPetDetail(Pet pet) async {
    final bool? result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => PetDetailPage(pet: pet),
      ),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDataScope.watch(context);
    return Container(
      color: bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const AppText(
                'Cá nhân',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading),
              ),
              const SizedBox(height: 16),
              _header(),
              if (_isPetOwner) ...[
                const SizedBox(height: 14),
                _stats(),
                const SizedBox(height: 18),
                _sectionTitle('Thú cưng của tôi'),
                const SizedBox(height: 10),
                _petList(),
                TextButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute<bool>(
                              builder: (_) => const AddPetPage()));
                      if (mounted) setState(() {});
                    },
                    icon: const Icon(Icons.add),
                    label: const AppText('Thêm thú cưng')),
              ],
              const SizedBox(height: 18),
              _sectionTitle('Cài đặt'),
              const SizedBox(height: 10),
              _menu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _petList() {
    if (PetRepository.pets.isEmpty) {
      return Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const AppText(
              'Chưa có thú cưng nào.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }
    return Column(
      children: <Widget>[
        ...PetRepository.pets.map(
          (Pet pet) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => _openPetDetail(pet),
              child: _petTile(pet),
            ),
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            backgroundColor: primary.withValues(alpha: 0.1),
            child: const AppText(
              '👤',
              style: TextStyle(
                color: primary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppText(
                  widget.account?.role.label ?? 'Tài khoản',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                AppText(
                  widget.account?.email ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats() {
    return Row(
      children: <Widget>[
        _statCard('${PetRepository.pets.length}', 'Thú cưng'),
        const SizedBox(width: 10),
        _statCard(
            '${AppDataRepository.appointments.length + PetRepository.pets.fold<int>(0, (sum, pet) => sum + pet.visits.length)}',
            'Lịch khám'),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: <Widget>[
            AppText(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
            const SizedBox(height: 4),
            AppText(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return AppText(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _petTile(Pet pet) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 22,
            backgroundColor: primary.withValues(alpha: 0.1),
            child: const Icon(Icons.pets, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  pet.name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                AppText(
                  pet.subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
    );
  }

  Widget _menu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          const LanguageSetting(),
          _divider(),
          if (_isPetOwner) ...[
            _menuItem(Icons.account_balance_wallet_outlined, 'Chi phí khám'),
            _divider(),
            _menuItem(Icons.location_on_outlined, 'Địa chỉ của tôi'),
            _divider(),
            _menuItem(Icons.notifications_none, 'Cài đặt nhắc nhở'),
            _divider(),
            _menuItem(Icons.favorite_border, 'Phòng khám yêu thích'),
            _divider(),
          ],
          _menuItem(Icons.help_outline, 'Trợ giúp và hỗ trợ'),
          _divider(),
          _menuItem(Icons.logout, 'Đăng xuất', danger: true),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 56, color: Color(0xFFEDEFF3));
  }

  Widget _menuItem(IconData icon, String label, {bool danger = false}) {
    return InkWell(
      onTap: icon == Icons.logout
          ? () async {
              try {
                await FirebaseAuth.instance.signOut();
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          AppText('Chưa thể đăng xuất. Vui lòng thử lại.')),
                );
              }
            }
          : () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (_) => SettingsPage(section: label))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22, color: danger ? Colors.redAccent : primary),
            const SizedBox(width: 16),
            Expanded(
              child: AppText(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: danger ? Colors.redAccent : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
