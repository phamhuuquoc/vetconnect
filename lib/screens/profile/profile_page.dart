import 'package:flutter/material.dart';
import '../../data/pet_repository.dart';
import '../../models/pet.dart';
import '../pet/add_pet_page.dart';
import '../pet/pet_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color primary = Color(0xFF1F41BB);
  static const Color bg = Color(0xFFF5F6F7);

  Future<void> _openAddPet() async {
    final bool? result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => const AddPetPage(),
      ),
    );
    if (result == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm thú cưng')),
      );
    }
  }

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
    return Container(
      color: bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Cá nhân',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _header(),
              const SizedBox(height: 14),
              _stats(),
              const SizedBox(height: 18),
              _sectionTitle('Thú cưng của tôi'),
              const SizedBox(height: 10),
              _petList(),
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
            child: const Text(
              'Chưa có thú cưng nào. Thêm hồ sơ để bắt đầu đặt lịch khám.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 10),
          _addPet(),
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
        _addPet(),
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
            backgroundColor: primary.withOpacity(0.1),
            child: const Text(
              'NA',
              style: TextStyle(
                color: primary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Nguyễn Văn A',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 3),
                Text(
                  'nguyenvana@gmail.com',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, size: 20, color: primary),
        ],
      ),
    );
  }

  Widget _stats() {
    return Row(
      children: <Widget>[
        _statCard('${PetRepository.pets.length}', 'Thú cưng'),
        const SizedBox(width: 10),
        _statCard('8', 'Lịch khám'),
        const SizedBox(width: 10),
        _statCard('320', 'Điểm thưởng'),
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
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
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
            backgroundColor: primary.withOpacity(0.1),
            child: const Icon(Icons.pets, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  pet.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
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

  Widget _addPet() {
    return GestureDetector(
      onTap: _openAddPet,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primary.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Icon(Icons.add, color: primary, size: 20),
            SizedBox(width: 6),
            Text('Thêm thú cưng', style: TextStyle(color: primary, fontSize: 14)),
          ],
        ),
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
          _menuItem(Icons.account_balance_wallet_outlined, 'Ví và thanh toán'),
          _divider(),
          _menuItem(Icons.location_on_outlined, 'Địa chỉ của tôi'),
          _divider(),
          _menuItem(Icons.notifications_none, 'Cài đặt nhắc nhở'),
          _divider(),
          _menuItem(Icons.favorite_border, 'Phòng khám yêu thích'),
          _divider(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 22, color: danger ? Colors.redAccent : primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
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
    );
  }
}
