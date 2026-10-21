import '../../l10n/app_text.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

import '../../models/pet.dart';
import '../../data/pet_repository.dart';
import '../../data/care_repository.dart';
import 'add_pet_page.dart';
import '../../widgets/app_data_scope.dart';

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
  bool _saving = false;

  Future<void> _vaccine([int? index]) async {
    final name = TextEditingController(
        text: index == null ? '' : _pet.vaccines[index].name);
    final form = GlobalKey<FormState>();
    DateTime date = index == null ? DateTime.now() : _pet.vaccines[index].date;
    DateTime? nextDate = index == null ? null : _pet.vaccines[index].nextDate;
    bool done = index == null ? false : _pet.vaccines[index].done;
    final ok = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setDialog) => AlertDialog(
                  title: const AppText('Lịch tiêm chủng & tẩy giun'),
                  content: SingleChildScrollView(
                      child: Form(
                          key: form,
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            TextFormField(
                                controller: name,
                                maxLength: 150,
                                decoration: InputDecoration(
                                    labelText: translate(
                                        context, 'Tên vaccine hoặc thuốc')),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? translate(
                                        context, 'Vui lòng nhập thông tin')
                                    : null),
                            SwitchListTile(
                                title: const AppText('Đã thực hiện'),
                                value: done,
                                onChanged: (v) => setDialog(() => done = v)),
                            ListTile(
                                title: AppText(
                                    done ? 'Ngày thực hiện' : 'Ngày dự kiến'),
                                subtitle: Text(_formatDate(date)),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                      context: context,
                                      initialDate: date,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100));
                                  if (picked != null) {
                                    setDialog(() => date = picked);
                                  }
                                }),
                            ListTile(
                                title: const AppText('Ngày nhắc lại'),
                                subtitle: Text(nextDate == null
                                    ? translate(context, 'Chưa chọn')
                                    : _formatDate(nextDate!)),
                                trailing: nextDate == null
                                    ? null
                                    : IconButton(
                                        onPressed: () =>
                                            setDialog(() => nextDate = null),
                                        icon: const Icon(Icons.clear)),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                      context: context,
                                      initialDate: nextDate ??
                                          date.add(const Duration(days: 365)),
                                      firstDate: date,
                                      lastDate: DateTime(2101));
                                  if (picked != null) {
                                    setDialog(() => nextDate = picked);
                                  }
                                }),
                            const AppText(
                                'Thông tin theo dõi do chủ nuôi nhập.'),
                          ]))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const AppText('Hủy')),
                    FilledButton(
                        onPressed: () {
                          if (form.currentState!.validate() &&
                              (!done || !date.isAfter(DateTime.now())) &&
                              (nextDate == null || !nextDate!.isBefore(date))) {
                            Navigator.pop(context, true);
                          }
                        },
                        child: const AppText('Lưu'))
                  ],
                )));
    final text = name.text.trim();
    Future<void>.delayed(const Duration(seconds: 1), name.dispose);
    if (ok != true || !mounted) return;
    final vaccines = [..._pet.vaccines];
    final record =
        VaccineRecord(name: text, date: date, done: done, nextDate: nextDate);
    if (index == null) {
      vaccines.add(record);
    } else {
      vaccines[index] = record;
    }
    setState(() => _saving = true);
    try {
      final updated = _pet.copyWith(vaccines: vaccines);
      await CareRepository().savePet(updated);
      if (mounted) setState(() => _pet = updated);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: AppText('Không thể lưu. Kiểm tra kết nối và thử lại.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _edit() async {
    await Navigator.push(context,
        MaterialPageRoute<bool>(builder: (_) => AddPetPage(pet: _pet)));
    if (mounted) setState(() => _pet = PetRepository.byId(_pet.id) ?? _pet);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const AppText('Xóa hồ sơ thú cưng'),
                content: const AppText(
                    'Xóa hồ sơ này? Lịch khám đã đặt vẫn được giữ lại.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const AppText('Hủy')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const AppText('Xóa'))
                ]));
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await CareRepository().deletePet(_pet.id);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: AppText('Không thể lưu. Kiểm tra kết nối và thử lại.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _weight() async {
    final controller = TextEditingController();
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const AppText('Cập nhật cân nặng'),
                content: Form(
                    key: key,
                    child: TextFormField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(suffixText: 'kg'),
                        validator: (value) {
                          final kg = double.tryParse(
                              (value ?? '').replaceAll(',', '.'));
                          return kg == null ||
                                  !kg.isFinite ||
                                  kg <= 0 ||
                                  kg > 1000
                              ? translate(context, 'Vui lòng nhập số hợp lệ')
                              : null;
                        })),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const AppText('Hủy')),
                  FilledButton(
                      onPressed: () {
                        if (key.currentState!.validate()) {
                          Navigator.pop(context, true);
                        }
                      },
                      child: const AppText('Lưu'))
                ]));
    final value = double.tryParse(controller.text.replaceAll(',', '.'));
    Future<void>.delayed(const Duration(seconds: 1), controller.dispose);
    if (ok != true || value == null || !mounted) return;
    setState(() => _saving = true);
    final updated = Pet(
        id: _pet.id,
        name: _pet.name,
        species: _pet.species,
        breed: _pet.breed,
        ageYears: _pet.ageYears,
        weightKg: value,
        gender: _pet.gender,
        neutered: _pet.neutered,
        allergies: _pet.allergies,
        vaccines: _pet.vaccines,
        visits: _pet.visits,
        weights: [
          ..._pet.weights,
          WeightRecord(date: DateTime.now(), kg: value)
        ]);
    try {
      await CareRepository().savePet(updated);
      if (mounted) setState(() => _pet = updated);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: AppText('Không thể lưu. Kiểm tra kết nối và thử lại.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  @override
  Widget build(BuildContext context) {
    AppDataScope.watch(context);
    _pet = PetRepository.byId(_pet.id) ?? _pet;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: _saving ? null : _edit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: translate(context, 'Chỉnh sửa hồ sơ')),
          IconButton(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: translate(context, 'Xóa hồ sơ thú cưng'))
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          _pet.name,
          style: const TextStyle(color: AppColors.heading, fontSize: 18),
        ),
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
            TextButton.icon(
                onPressed: _saving ? null : () => _vaccine(),
                icon: const Icon(Icons.add),
                label: const AppText('Thêm lịch chăm sóc')),
            const SizedBox(height: 18),
            _sectionTitle('Cân nặng theo thời gian'),
            const SizedBox(height: 10),
            _weightChart(),
            TextButton.icon(
                onPressed: _saving ? null : _weight,
                icon: const Icon(Icons.add),
                label: const AppText('Cập nhật cân nặng')),
            const SizedBox(height: 10),
            const SizedBox(height: 18),
            _sectionTitle('Lịch sử khám'),
            const SizedBox(height: 10),
            _visits(),
            const SizedBox(height: 18),
            _sectionTitle('Dị ứng'),
            const SizedBox(height: 10),
            _allergies(),
            const SizedBox(height: 24),
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
            backgroundColor: primary.withValues(alpha: 0.1),
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
                AppText(
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
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          AppText(text, style: const TextStyle(fontSize: 11, color: primary)),
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
          _pet.vaccines.isEmpty
              ? 'Chưa có dữ liệu.'
              : _pet.vaccineUpToDate
                  ? 'Đầy đủ'
                  : 'Còn ${_pet.pendingVaccineCount} mũi',
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
            AppText(
              value,
              style: const TextStyle(
                fontSize: 14,
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
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.heading),
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
              IconButton(
                  onPressed: _saving ? null : () => _vaccine(i),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: translate(context, 'Chỉnh sửa')),
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
                    AppText(
                      v.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      v.done
                          ? 'Đã tiêm ${_formatDate(v.date)}'
                          : 'Dự kiến ${_formatDate(v.date)}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    if (v.nextDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: AppText(
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
                  AppText(
                    '${w.kg}kg',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 34,
                    height: 24 + ratio * 56,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppText(
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
                      child: AppText(
                        v.service,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AppText(
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
                AppText(
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
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const AppText(
                'Tổng chi phí',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              AppText(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF0FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  a,
                  style: const TextStyle(fontSize: 12, color: primary),
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
      child: AppText(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black54),
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
