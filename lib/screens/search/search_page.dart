import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

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
                'Tìm kiếm',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              _searchBar(),
              const SizedBox(height: 14),
              _filters(),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Text(
                    'Phòng khám gần bạn',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text('Bản đồ', style: TextStyle(fontSize: 13, color: primary)),
                ],
              ),
              const SizedBox(height: 10),
              _clinicCard(
                'Phòng khám Thú y An Phú',
                '123 Nguyễn Văn Cừ, Q.5',
                '1.2 km',
                4.8,
                'Mở cửa đến 21:00',
              ),
              _clinicCard(
                'Bệnh viện Thú y Sài Gòn',
                '45 Lê Hồng Phong, Q.10',
                '3.5 km',
                4.6,
                'Mở cửa 24/7',
              ),
              _clinicCard(
                'Pet Care Spa & Clinic',
                '78 Trần Não, Q.2',
                '5.8 km',
                4.9,
                'Mở cửa đến 19:00',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const <Widget>[
                Icon(Icons.search, color: Colors.black45, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm phòng khám, bác sĩ, dịch vụ',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.black38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ],
    );
  }

  Widget _filters() {
    return Wrap(
      spacing: 8,
      children: const <Widget>[
        _FilterChip(label: 'Gần tôi', selected: true),
        _FilterChip(label: 'Đánh giá cao'),
        _FilterChip(label: 'Giá tốt'),
        _FilterChip(label: 'Còn chỗ hôm nay'),
        _FilterChip(label: 'Khám tại nhà'),
      ],
    );
  }

  Widget _clinicCard(
    String name,
    String address,
    String distance,
    double rating,
    String openTime,
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      address,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 3),
                      Text(
                        rating.toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    distance,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Icon(Icons.access_time, size: 15, color: Colors.green),
              const SizedBox(width: 5),
              Text(
                openTime,
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Đặt lịch',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? SearchPage.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
