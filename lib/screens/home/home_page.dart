import 'package:flutter/material.dart';
import '../../data/pet_repository.dart';
import '../../models/pet.dart';
import '../pet/add_pet_page.dart';
import '../pet/pet_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color primary = Color(0xFF1F41BB);
  static const Color bg = Color(0xFFF5F6F7);

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
              _header(),
              const SizedBox(height: 20),
              _petHeader(context),
              const SizedBox(height: 10),
              _pets(context),
              const SizedBox(height: 20),
              _sectionTitle('Lịch hẹn sắp tới', 'Tất cả'),
              const SizedBox(height: 10),
              _upcoming(),
              const SizedBox(height: 20),
              _services(),
              const SizedBox(height: 20),
              _sectionTitle('Nhắc nhở sắp tới', ''),
              const SizedBox(height: 10),
              _reminders(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Xin chào,',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              SizedBox(height: 2),
              Text(
                'Nguyễn Văn A',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Stack(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_none, color: primary),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (action.isNotEmpty)
          Text(
            action,
            style: const TextStyle(fontSize: 13, color: primary),
          ),
      ],
    );
  }

  Widget _petHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text(
          'Thú cưng của tôi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        GestureDetector(
          onTap: () async {
            final bool? ok = await Navigator.of(context).push<bool>(
              MaterialPageRoute<bool>(
                builder: (BuildContext context) => const AddPetPage(),
              ),
            );
            if (ok == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm thú cưng')),
              );
            }
          },
          child: const Text(
            'Thêm',
            style: TextStyle(fontSize: 13, color: primary),
          ),
        ),
      ],
    );
  }

  Widget _pets(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PetRepository.pets.map((Pet pet) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 150,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => PetDetailPage(pet: pet),
                    ),
                  );
                },
                child: _petCard(pet),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _petCard(Pet pet) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 22,
            backgroundColor: primary.withOpacity(0.1),
            child: const Icon(Icons.pets, color: primary),
          ),
          const SizedBox(height: 10),
          Text(
            pet.name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            pet.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _upcoming() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.event_available, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Thứ 6, 24/10 - 09:30',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Phòng khám Thú y An Phú',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'BS. Trần Thị Bình - Khám tổng quát cho Miu',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Xem chi tiết',
                      style: TextStyle(color: primary, fontSize: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Đổi lịch',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _services() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _serviceItem(Icons.medical_services, 'Khám bệnh'),
        _serviceItem(Icons.vaccines, 'Tiêm chủng'),
        _serviceItem(Icons.spa, 'Spa thú cưng'),
        _serviceItem(Icons.emergency, 'Cấp cứu'),
      ],
    );
  }

  Widget _serviceItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _reminders() {
    return Column(
      children: <Widget>[
        _reminderTile(Icons.vaccines, 'Tiêm vaccine dại cho Béo', 'Còn 5 ngày'),
        const SizedBox(height: 10),
        _reminderTile(Icons.medication, 'Tẩy giun định kỳ cho Miu', 'Còn 12 ngày'),
      ],
    );
  }

  Widget _reminderTile(IconData icon, String title, String due) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: primary, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Text(
            due,
            style: const TextStyle(fontSize: 12, color: Colors.deepOrange),
          ),
        ],
      ),
    );
  }
}
