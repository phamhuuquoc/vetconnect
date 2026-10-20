import 'package:flutter/material.dart';
import '../../data/pet_repository.dart';
import '../../models/pet.dart';
import 'add_pet_page.dart';

class PetDetailPage extends StatefulWidget {
  const PetDetailPage({super.key, required this.pet});

  final Pet pet;

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  static const Color primary = Color(0xFF1F41BB);
  static const Color bg = Color(0xFFF5F6F7);

  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  void _reload() {
    final Pet? updated = PetRepository.byId(_pet.id);
    if (updated != null) {
      setState(() => _pet = updated);
    }
  }

  Future<void> _openEdit() async {
    final bool? result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => AddPetPage(pet: _pet),
      ),
    );
    if (result == true) {
      _reload();
    }
  }

  Future<void> _confirmDelete() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa thú cưng'),
          content: Text('Bạn chắc chắn muốn xóa hồ sơ của ${_pet.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      PetRepository.removePet(_pet.id);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _addWeight() async {
    final TextEditingController ctrl = TextEditingController();
    final double? value = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cập nhật cân nặng'),
          content: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Nhập cân nặng (kg)',
              suffixText: 'kg',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                final double? v = double.tryParse(ctrl.text.trim());
                Navigator.of(context).pop(v);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
    if (value != null && value > 0) {
      PetRepository.addWeightRecord(_pet.id, value);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật cân nặng cho ${_pet.name}')),
        );
      }
    }
  }

  void _markVaccineDone(int index) {
    PetRepository.markVaccineDone(_pet.id, index);
    _reload();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đánh dấu đã tiêm')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          _pet.name,
          style: const TextStyle(color: Colors.black87, fontSize: 18),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'edit') {
                _openEdit();
              } else if (value == 'delete') {
                _confirmDelete();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Sửa hồ sơ'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Xóa thú cưng', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _header(),
            const SizedBox(height: 14),
            _metrics(),
            const SizedBox(height: 18),
            _sectionTitle('Lịch tiêm chủng & tẩy giun'),
            const SizedBox(height: 10),
            _vaccines(),
            const SizedBox(height: 18),
            _sectionTitle('Cân nặng theo thời gian'),
            const SizedBox(height: 10),
            _weightChart(),
            const SizedBox(height: 10),
            _addWeightButton(),
            const SizedBox(height: 18),
            _sectionTitle('Lịch sử khám'),
            const SizedBox(height: 10),
            _visits(),
            const SizedBox(height: 18),
            _sectionTitle('Dị ứng'),
            const SizedBox(height: 10),
            _allergies(),
            const SizedBox(height: 24),
            _bookButton(),
          ],
        ),
      ),
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
            radius: 30,
            backgroundColor: primary.withOpacity(0.1),
            child: const Icon(Icons.pets, color: primary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _pet.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _pet.subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    _tag(_pet.gender),
                    const SizedBox(width: 6),
                    _tag(_pet.neutered ? 'Đã triệt sản' : 'Chưa triệt sản'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: primary)),
    );
  }

  Widget _metrics() {
    return Row(
      children: <Widget>[
        _metric('Cân nặng', '${_pet.weightKg} kg'),
        const SizedBox(width: 10),
        _metric('Tuổi', '${_pet.ageYears} tuổi'),
        const SizedBox(width: 10),
        _metric(
          'Tiêm chủng',
          _pet.vaccineUpToDate ? 'Đầy đủ' : 'Còn ${_pet.pendingVaccineCount} mũi',
        ),
      ],
    );
  }

  Widget _metric(String label, String value) {
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
                fontSize: 14,
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

  Widget _vaccines() {
    if (_pet.vaccines.isEmpty) {
      return _emptyBox('Chưa có lịch tiêm chủng');
    }
    return Column(
      children: List<Widget>.generate(_pet.vaccines.length, (int i) {
        final VaccineRecord v = _pet.vaccines[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                v.done ? Icons.check_circle : Icons.schedule,
                color: v.done ? Colors.green : Colors.orange,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      v.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      v.done
                          ? 'Đã tiêm ${_formatDate(v.date)}'
                          : 'Dự kiến ${_formatDate(v.date)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    if (v.nextDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          'Nhắc lại: ${_formatDate(v.nextDate!)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!v.done)
                TextButton(
                  onPressed: () => _markVaccineDone(i),
                  child: const Text('Đã tiêm', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _weightChart() {
    if (_pet.weights.isEmpty) {
      return _emptyBox('Chưa có dữ liệu cân nặng');
    }
    double maxKg = 0;
    for (final WeightRecord w in _pet.weights) {
      if (w.kg > maxKg) {
        maxKg = w.kg;
      }
    }
    if (maxKg == 0) {
      maxKg = 1;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _pet.weights.map((WeightRecord w) {
            final double ratio = w.kg / maxKg;
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                children: <Widget>[
                  Text(
                    '${w.kg}kg',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 34,
                    height: 24 + ratio * 56,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${w.date.day}/${w.date.month}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _addWeightButton() {
    return GestureDetector(
      onTap: _addWeight,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primary.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Icon(Icons.add, color: primary, size: 18),
            SizedBox(width: 6),
            Text(
              'Cập nhật cân nặng',
              style: TextStyle(color: primary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visits() {
    if (_pet.visits.isEmpty) {
      return _emptyBox('Chưa có lịch khám nào');
    }
    return Column(
      children: <Widget>[
        ..._pet.visits.map(
          (VisitRecord v) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        v.service,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${_formatMoney(v.priceVnd)}đ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  v.clinic,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(v.date),
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Tổng chi phí',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              Text(
                '${_formatMoney(_pet.totalSpent)}đ',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _allergies() {
    if (_pet.allergies.isEmpty) {
      return _emptyBox('Không ghi nhận dị ứng');
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 8,
        children: _pet.allergies
            .map(
              (String a) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  a,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black54),
      ),
    );
  }

  Widget _bookButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đặt lịch khám cho ${_pet.name}')),
          );
        },
        child: Text(
          'Đặt lịch cho ${_pet.name}',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _formatMoney(int value) {
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
