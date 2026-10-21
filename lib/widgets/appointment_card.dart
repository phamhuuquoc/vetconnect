import 'package:flutter/material.dart';
import '../data/app_data_repository.dart';
import '../l10n/app_text.dart';
import '../data/care_repository.dart';

class AppointmentCard extends StatefulWidget {
  const AppointmentCard(
      {super.key, required this.appointment, this.staff = false});
  final AppRecord appointment;
  final bool staff;
  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool _saving = false;
  Future<void> _update(String status) async {
    final notes = TextEditingController();
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: AppText(status == 'completed'
                  ? 'Kết quả khám'
                  : status == 'cancelled'
                      ? 'Hủy lịch khám'
                      : 'Tiếp nhận lịch khám'),
              content: status == 'completed'
                  ? TextField(
                      controller: notes,
                      minLines: 3,
                      maxLines: 8,
                      maxLength: 5000,
                      decoration: InputDecoration(
                          labelText: translate(
                              context, 'Kết quả và hướng dẫn chăm sóc')))
                  : const AppText('Xác nhận thay đổi trạng thái lịch khám?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const AppText('Hủy')),
                FilledButton(
                    onPressed: () {
                      if (status != 'completed' ||
                          notes.text.trim().isNotEmpty) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: const AppText('Xác nhận'))
              ],
            ));
    final text = notes.text;
    // The route's exit animation may still be using its controller.
    Future<void>.delayed(const Duration(seconds: 1), notes.dispose);
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await CareRepository()
          .updateAppointment(widget.appointment, status, notes: text);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: AppText(
                'Không thể cập nhật lịch. Kiểm tra kết nối và trạng thái hiện tại.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    final date = a.date('startsAt');
    final status = switch (a.text('status')) {
      'confirmed' => 'Đã xác nhận',
      'pending' => 'Chờ xác nhận',
      'completed' => 'Đã hoàn tất',
      'cancelled' => 'Đã hủy',
      _ => a.text('status'),
    };
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${a.text('serviceName')} - ${a.text('petName')}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(AppDataRepository.clinicName(a.text('clinicId'))),
                if (a.text('doctorId').isNotEmpty)
                  Text(AppDataRepository.doctorName(a.text('doctorId'))),
                if (date != null)
                  Text(
                      '${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'),
                Text('${a.number('priceVnd')} đ'),
                AppText(status),
                if (a.text('medicalNotes').isNotEmpty) ...[
                  const Divider(),
                  const AppText('Kết quả khám',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SelectableText(a.text('medicalNotes')),
                ],
                if (widget.staff && a.data['petSummary'] is Map) ...[
                  const Divider(),
                  Text(
                      '${a.data['petSummary']['species']} • ${a.data['petSummary']['ageYears']} • ${a.data['petSummary']['weightKg']} kg'),
                  Text(
                      '${translate(context, 'Dị ứng')}: ${(a.data['petSummary']['allergies'] as List? ?? []).join(', ')}'),
                ],
                if (a.text('ownerId').isNotEmpty &&
                    ['pending', 'confirmed'].contains(a.text('status'))) ...[
                  if (_saving) const LinearProgressIndicator(),
                  Wrap(spacing: 8, children: [
                    if (widget.staff && a.text('status') == 'pending')
                      TextButton(
                          onPressed:
                              _saving ? null : () => _update('confirmed'),
                          child: const AppText('Tiếp nhận lịch khám')),
                    if (widget.staff && a.text('status') == 'confirmed')
                      TextButton(
                          onPressed:
                              _saving || (date?.isAfter(DateTime.now()) ?? true)
                                  ? null
                                  : () => _update('completed'),
                          child: const AppText('Hoàn tất khám')),
                    if (widget.staff ||
                        (date?.isAfter(DateTime.now()) ?? false))
                      TextButton(
                          onPressed:
                              _saving ? null : () => _update('cancelled'),
                          child: const AppText('Hủy lịch khám')),
                  ]),
                ],
              ],
            )));
  }
}
