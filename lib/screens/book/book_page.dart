import 'package:flutter/material.dart';
import '../../data/pet_repository.dart';
import '../../models/pet.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  static const Color primary = Color(0xFF1F41BB);
  static const Color bg = Color(0xFFF5F6F7);

  List<String> get _pets => PetRepository.pets.map((Pet p) => p.name).toList();
  final List<String> _services = <String>[
    'Khám tổng quát',
    'Tiêm vaccine',
    'Spa thú cưng',
    'Khám tại nhà',
  ];
  final List<int> _prices = <int>[200000, 150000, 300000, 450000];
  final List<String> _days = <String>['T2 20/10', 'T3 21/10', 'T4 22/10', 'T5 23/10', 'T6 24/10'];
  final List<String> _slots = <String>['08:00', '09:30', '11:00', '14:00', '15:30', '17:00'];

  int _petIndex = 0;
  int _serviceIndex = 0;
  int _dayIndex = 2;
  int _slotIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Đặt lịch khám',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    _steps(),
                    const SizedBox(height: 20),
                    _title('1. Chọn thú cưng'),
                    const SizedBox(height: 10),
                    _chips(_pets, _petIndex, (int i) {
                      setState(() => _petIndex = i);
                    }),
                    const SizedBox(height: 20),
                    _title('2. Chọn dịch vụ'),
                    const SizedBox(height: 10),
                    _serviceList(),
                    const SizedBox(height: 20),
                    _title('3. Chọn ngày'),
                    const SizedBox(height: 10),
                    _chips(_days, _dayIndex, (int i) {
                      setState(() => _dayIndex = i);
                    }),
                    const SizedBox(height: 20),
                    _title('4. Chọn khung giờ'),
                    const SizedBox(height: 10),
                    _chips(_slots, _slotIndex, (int i) {
                      setState(() => _slotIndex = i);
                    }),
                    const SizedBox(height: 16),
                    _note(),
                  ],
                ),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _steps() {
    final List<String> labels = <String>['Thú cưng', 'Dịch vụ', 'Ngày', 'Giờ'];
    return Row(
      children: List<Widget>.generate(labels.length, (int i) {
        final bool done = i <= 3;
        return Expanded(
          child: Row(
            children: <Widget>[
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: done ? primary : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: done ? primary : Colors.black26),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: done ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  color: done ? primary : Colors.black54,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _chips(List<String> items, int selected, ValueChanged<int> onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List<Widget>.generate(items.length, (int i) {
        final bool active = i == selected;
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: active ? primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? primary : const Color(0xFFE3E5EA),
              ),
            ),
            child: Text(
              items[i],
              style: TextStyle(
                fontSize: 14,
                color: active ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _serviceList() {
    return Column(
      children: List<Widget>.generate(_services.length, (int i) {
        final bool active = i == _serviceIndex;
        return GestureDetector(
          onTap: () => setState(() => _serviceIndex = i),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? primary : const Color(0xFFE3E5EA),
                width: active ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  active ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: active ? primary : Colors.black38,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _services[i],
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                Text(
                  '${_formatPrice(_prices[i])}đ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: active ? primary : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _note() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Icon(Icons.info_outline, size: 18, color: Colors.amber),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vui lòng đến trước 10 phút. Hủy lịch trước 2 giờ sẽ được hoàn lại đặt cọc.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Tạm tính', style: TextStyle(fontSize: 12, color: Colors.black54)),
              Text(
                '${_formatPrice(_prices[_serviceIndex])}đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Xác nhận đặt lịch',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int value) {
    final String s = value.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final int fromEnd = s.length - i;
      buffer.write(s[i]);
      if (fromEnd > 1 && (fromEnd - 1) % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}
