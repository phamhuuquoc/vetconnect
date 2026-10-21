import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/app_data_repository.dart';
import '../../data/pet_repository.dart';
import '../../l10n/app_text.dart';
import '../../data/care_repository.dart';
import '../pet/add_pet_page.dart';
import '../../widgets/app_data_scope.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key, this.initialClinicId, this.onBook});
  final String? initialClinicId;
  final Future<void> Function(String petId, String slotId)? onBook;
  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  String? _petId;
  String? _clinicId;
  String? _serviceId;
  String? _slotId;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _clinicId = widget.initialClinicId;
  }

  Future<void> _submit() async {
    if (_saving || _petId == null || _slotId == null) return;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const AppText('Xác nhận đặt lịch'),
              content: const AppText(
                  'Gửi yêu cầu đặt lịch với thú cưng và khung giờ đã chọn?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const AppText('Hủy')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const AppText('Xác nhận'))
              ],
            ));
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      if (widget.onBook != null) {
        await widget.onBook!(_petId!, _slotId!);
      } else {
        await CareRepository().book(petId: _petId!, slotId: _slotId!);
      }
      if (!mounted) return;
      setState(() => _slotId = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: AppText(
              'Đã gửi yêu cầu đặt lịch. Theo dõi trạng thái trong Lịch sử.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: AppText(
              'Không thể đặt lịch. Khung giờ có thể đã được đặt; hãy chọn lại hoặc kiểm tra kết nối.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDataScope.watch(context);
    final clinics = AppDataRepository.clinics;
    final services = AppDataRepository.services
        .where((s) => s.text('clinicId') == _clinicId)
        .toList();
    final slots = AppDataRepository.timeSlots
        .where((s) =>
            s.text('clinicId') == _clinicId &&
            s.text('serviceId') == _serviceId &&
            s.text('status') == 'available' &&
            (s.date('startsAt')?.isAfter(DateTime.now()) ?? false))
        .toList()
      ..sort((a, b) => a.text('startsAt').compareTo(b.text('startsAt')));
    return Material(
        color: const Color(0xFFF5F6F7),
        child: SafeArea(
            child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppText('Đặt lịch khám',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading)),
            const SizedBox(height: 16),
            if (clinics.isEmpty || AppDataRepository.services.isEmpty)
              const AppText('Chưa có dịch vụ và khung giờ để đặt lịch.'),
            if (clinics.isNotEmpty) ...[
              const AppText('Thú cưng'),
              if (PetRepository.pets.isEmpty)
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
              Wrap(
                  spacing: 8,
                  children: PetRepository.pets
                      .map((p) => ChoiceChip(
                          label: Text(p.name),
                          selected: _petId == p.id,
                          onSelected: (_) => setState(() => _petId = p.id)))
                      .toList()),
              const SizedBox(height: 16),
              const AppText('Phòng khám'),
              RadioGroup<String>(
                  groupValue: _clinicId,
                  onChanged: (id) => setState(() {
                        _clinicId = id;
                        _serviceId = null;
                        _slotId = null;
                      }),
                  child: Column(children: [
                    for (final c in clinics)
                      RadioListTile<String>(
                          value: c.id, title: Text(c.text('name')))
                  ])),
              if (_clinicId != null) ...[
                const AppText('Dịch vụ'),
                RadioGroup<String>(
                    groupValue: _serviceId,
                    onChanged: (id) => setState(() {
                          _serviceId = id;
                          _slotId = null;
                        }),
                    child: Column(children: [
                      for (final s in services)
                        RadioListTile<String>(
                            value: s.id,
                            title: Text(s.text('name')),
                            subtitle: Text(
                                '${s.number('priceVnd')} đ • ${s.number('durationMinutes')} ${translate(context, 'phút')}'))
                    ])),
              ],
              if (_serviceId != null) ...[
                const AppText('Khung giờ'),
                if (slots.isEmpty) const AppText('Chưa có khung giờ trống.'),
                RadioGroup<String>(
                    groupValue: _slotId,
                    onChanged: (id) => setState(() => _slotId = id),
                    child: Column(children: [
                      for (final slot in slots)
                        RadioListTile<String>(
                            value: slot.id,
                            title: Text(_format(slot)),
                            subtitle: Text(AppDataRepository.doctorName(
                                slot.text('doctorId'))))
                    ])),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                  onPressed: !_saving &&
                          _petId != null &&
                          slots.any((s) => s.id == _slotId) &&
                          PetRepository.byId(_petId!) != null
                      ? _submit
                      : null,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.calendar_month),
                  label: const AppText('Gửi yêu cầu đặt lịch')),
            ],
          ],
        )));
  }

  String _format(AppRecord slot) {
    final date = slot.date('startsAt');
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
