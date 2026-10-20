import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

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
              const Text(
                'Lịch sử khám',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              _tabs(),
              const SizedBox(height: 16),
              _healthSummary(),
              const SizedBox(height: 16),
              _visitCard(
                'Đã hoàn tất',
                const Color(0xFFE8F5E9),
                Colors.green,
                'Phòng khám Thú y An Phú',
                'Khám tổng quát - Miu',
                '12/09/2026 - 10:00',
                '320.000đ',
              ),
              _visitCard(
                'Sắp tới',
                const Color(0xFFE8EDFB),
                primary,
                'Bệnh viện Thú y Sài Gòn',
                'Tiêm vaccine dại - Béo',
                '24/10/2026 - 09:30',
                '150.000đ',
              ),
              _visitCard(
                'Đã hủy',
                const Color(0xFFFDECEA),
                Colors.redAccent,
                'Pet Care Spa & Clinic',
                'Spa thú cưng - Miu',
                '02/08/2026 - 15:00',
                '300.000đ',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Row(
      children: <Widget>[
        _tab('Sắp tới', true),
        const SizedBox(width: 8),
        _tab('Đã khám', false),
        const SizedBox(width: 8),
        _tab('Đã hủy', false),
      ],
    );
  }

  Widget _tab(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: active ? primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: active ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _healthSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Hồ sơ sức khỏe - Miu',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _metric('Cân nặng', '4.2 kg'),
              _metric('Tiêm chủng', 'Đầy đủ'),
              _metric('Lần khám gần nhất', '12/09'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Xem hồ sơ chi tiết',
                style: TextStyle(color: primary, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _visitCard(
    String status,
    Color statusBg,
    Color statusColor,
    String clinic,
    String service,
    String time,
    String price,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 11, color: statusColor),
                ),
              ),
              const Spacer(),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            clinic,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            service,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Icon(Icons.access_time, size: 15, color: Colors.black45),
              const SizedBox(width: 5),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Spacer(),
              const Text(
                'Đánh giá',
                style: TextStyle(fontSize: 12, color: primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
