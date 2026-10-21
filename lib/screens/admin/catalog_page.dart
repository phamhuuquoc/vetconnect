import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/app_data_repository.dart';
import '../../l10n/app_text.dart';
import '../../widgets/app_data_scope.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String _collection = 'clinics';
  bool _saving = false;
  static const labels = {
    'clinics': 'Phòng khám',
    'services': 'Dịch vụ',
    'doctors': 'Bác sĩ',
    'timeSlots': 'Khung giờ'
  };
  List<AppRecord> get records => switch (_collection) {
        'clinics' => AppDataRepository.clinics,
        'services' => AppDataRepository.services,
        'doctors' => AppDataRepository.doctors,
        _ => AppDataRepository.timeSlots,
      };

  Future<void> _edit([AppRecord? record]) async {
    final collection = _collection;
    final data = Map<String, dynamic>.of(record?.data ?? {});
    final fields = switch (collection) {
      'clinics' => ['name', 'address', 'openingHours', 'phone'],
      'services' => ['name', 'priceVnd', 'durationMinutes'],
      'doctors' => ['name', 'specialty'],
      _ => <String>[],
    };
    const fieldLabels = {
      'name': 'Tên',
      'address': 'Địa chỉ',
      'openingHours': 'Giờ mở cửa',
      'phone': 'Số điện thoại',
      'priceVnd': 'Giá (VND)',
      'durationMinutes': 'Thời lượng (phút)',
      'specialty': 'Chuyên khoa'
    };
    final controllers = {
      for (final field in fields)
        field: TextEditingController(text: '${data[field] ?? ''}')
    };
    final form = GlobalKey<FormState>();
    DateTime? startsAt = record?.date('startsAt');
    List<QueryDocumentSnapshot<Map<String, dynamic>>> users = [];
    if (collection == 'doctors') {
      try {
        users = (await FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'doctor')
                .get())
            .docs;
      } catch (_) {
        if (mounted) _error();
        return;
      }
      if (!mounted) return;
    }
    final ok = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setDialog) {
              Widget choose(
                      String field, String label, List<AppRecord> options) =>
                  DropdownButtonFormField<String>(
                    key: ValueKey('$field:${data[field]}'),
                    initialValue: options.any((o) => o.id == data[field])
                        ? data[field] as String
                        : null,
                    isExpanded: true,
                    decoration:
                        InputDecoration(labelText: translate(context, label)),
                    items: options
                        .map((o) => DropdownMenuItem(
                            value: o.id,
                            child: Text(o.text('name'),
                                overflow: TextOverflow.ellipsis)))
                        .toList(),
                    validator: (v) => v == null
                        ? translate(context, 'Vui lòng nhập thông tin')
                        : null,
                    onChanged: (v) => setDialog(() {
                      data[field] = v;
                      if (field == 'clinicId') {
                        data.remove('serviceId');
                        data.remove('doctorId');
                      }
                    }),
                  );
              return AlertDialog(
                  title: AppText(record == null ? 'Thêm mới' : 'Chỉnh sửa'),
                  content: SizedBox(
                      width: 450,
                      child: Form(
                          key: form,
                          child: SingleChildScrollView(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                if (collection != 'clinics')
                                  choose('clinicId', 'Phòng khám',
                                      AppDataRepository.clinics),
                                for (final field in fields)
                                  TextFormField(
                                      controller: controllers[field],
                                      maxLength: field == 'address' ? 500 : 150,
                                      decoration: InputDecoration(
                                          labelText: translate(
                                              context, fieldLabels[field]!)),
                                      keyboardType: [
                                        'priceVnd',
                                        'durationMinutes'
                                      ].contains(field)
                                          ? TextInputType.number
                                          : TextInputType.text,
                                      validator: (value) {
                                        if (field == 'phone') return null;
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return translate(context,
                                              'Vui lòng nhập thông tin');
                                        }
                                        if (['priceVnd', 'durationMinutes']
                                            .contains(field)) {
                                          final number = int.tryParse(value);
                                          if (number == null ||
                                              number <
                                                  (field == 'priceVnd'
                                                      ? 0
                                                      : 1) ||
                                              number >
                                                  (field == 'priceVnd'
                                                      ? 100000000
                                                      : 1440)) {
                                            return translate(context,
                                                'Vui lòng nhập số hợp lệ');
                                          }
                                        }
                                        return null;
                                      }),
                                if (collection == 'doctors')
                                  DropdownButtonFormField<String>(
                                      initialValue: users.any(
                                              (u) => u.id == data['userId'])
                                          ? data['userId'] as String
                                          : null,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                          labelText: translate(
                                              context, 'Tài khoản bác sĩ')),
                                      items: users
                                          .map((u) => DropdownMenuItem(
                                              value: u.id,
                                              child: Text(
                                                  u.data()['email'] as String,
                                                  overflow:
                                                      TextOverflow.ellipsis)))
                                          .toList(),
                                      validator: (v) => v == null
                                          ? translate(context,
                                              'Hãy cấp quyền bác sĩ cho tài khoản trước.')
                                          : null,
                                      onChanged: (v) => data['userId'] = v),
                                if (collection == 'timeSlots') ...[
                                  choose(
                                      'serviceId',
                                      'Dịch vụ',
                                      AppDataRepository.services
                                          .where((s) =>
                                              s.text('clinicId') ==
                                              data['clinicId'])
                                          .toList()),
                                  choose(
                                      'doctorId',
                                      'Bác sĩ',
                                      AppDataRepository.doctors
                                          .where((s) =>
                                              s.text('clinicId') ==
                                              data['clinicId'])
                                          .toList()),
                                  ListTile(
                                      title: const AppText('Ngày và giờ khám'),
                                      subtitle: Text(startsAt == null
                                          ? translate(context, 'Chọn ngày giờ')
                                          : '${startsAt!.day}/${startsAt!.month}/${startsAt!.year} ${startsAt!.hour.toString().padLeft(2, '0')}:${startsAt!.minute.toString().padLeft(2, '0')}'),
                                      onTap: () async {
                                        final now = DateTime.now();
                                        final day = await showDatePicker(
                                            context: context,
                                            firstDate: DateTime(
                                                now.year, now.month, now.day),
                                            lastDate: now
                                                .add(const Duration(days: 730)),
                                            initialDate: startsAt != null &&
                                                    startsAt!.isAfter(now)
                                                ? startsAt
                                                : now);
                                        if (day == null || !context.mounted) {
                                          return;
                                        }
                                        final time = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                startsAt ?? now));
                                        if (time != null) {
                                          setDialog(() => startsAt = DateTime(
                                              day.year,
                                              day.month,
                                              day.day,
                                              time.hour,
                                              time.minute));
                                        }
                                      }),
                                ],
                              ])))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const AppText('Hủy')),
                    FilledButton(
                        onPressed: () {
                          if (!form.currentState!.validate()) return;
                          if (collection == 'timeSlots' &&
                              !(startsAt?.isAfter(DateTime.now()) ?? false)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: AppText(
                                        'Hãy chọn khung giờ trong tương lai.')));
                            return;
                          }
                          Navigator.pop(context, true);
                        },
                        child: const AppText('Lưu'))
                  ]);
            }));
    for (final field in fields) {
      data[field] = ['priceVnd', 'durationMinutes'].contains(field)
          ? int.tryParse(controllers[field]!.text)
          : controllers[field]!.text.trim();
    }
    Future<void>.delayed(const Duration(seconds: 1), () {
      for (final c in controllers.values) {
        c.dispose();
      }
    });
    if (ok != true || !mounted) return;
    if (collection == 'timeSlots') {
      data['startsAt'] = startsAt!.toUtc().toIso8601String();
      data['startsAtTime'] = Timestamp.fromDate(startsAt!);
      data['status'] = 'available';
      data['appointmentId'] = '';
    }
    setState(() => _saving = true);
    try {
      final ref = FirebaseFirestore.instance.collection(collection);
      if (record == null) {
        await ref.add(data);
      } else {
        await ref.doc(record.id).set(data);
      }
    } catch (_) {
      if (mounted) _error();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _error() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: AppText('Không thể lưu. Kiểm tra kết nối và thử lại.')));
  bool _inUse(AppRecord record) => switch (_collection) {
        'clinics' => [
            ...AppDataRepository.services,
            ...AppDataRepository.doctors,
            ...AppDataRepository.timeSlots
          ].any((v) => v.text('clinicId') == record.id),
        'services' => AppDataRepository.timeSlots
            .any((v) => v.text('serviceId') == record.id),
        'doctors' => AppDataRepository.timeSlots
            .any((v) => v.text('doctorId') == record.id),
        _ => record.text('status') != 'available',
      };
  Future<void> _delete(AppRecord record) async {
    final collection = _collection;
    final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const AppText('Xóa'),
                content: const AppText('Xóa mục này?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const AppText('Hủy')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const AppText('Xóa'))
                ]));
    if (ok != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(record.id)
          .delete();
    } catch (_) {
      if (mounted) _error();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDataScope.watch(context);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Wrap(spacing: 8, children: [
        for (final entry in labels.entries)
          ChoiceChip(
              label: AppText(entry.value),
              selected: _collection == entry.key,
              onSelected: _saving
                  ? null
                  : (_) => setState(() => _collection = entry.key))
      ]),
      const SizedBox(height: 12),
      FilledButton.icon(
          onPressed: _saving ? null : () => _edit(),
          icon: const Icon(Icons.add),
          label: const AppText('Thêm mới')),
      if (_saving) const LinearProgressIndicator(),
      const SizedBox(height: 12),
      if (records.isEmpty) const AppText('Chưa có dữ liệu.'),
      for (final record in records)
        Card(
            child: ListTile(
                title: Text(_collection == 'timeSlots'
                    ? '${record.date('startsAt') ?? ''}'
                    : record.text('name')),
                subtitle: Text(_collection == 'timeSlots'
                    ? '${AppDataRepository.clinicName(record.text('clinicId'))} • ${record.text('status')}'
                    : record.text(_collection == 'clinics'
                        ? 'address'
                        : _collection == 'doctors'
                            ? 'specialty'
                            : 'clinicId')),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      onPressed: _saving ||
                              (_collection == 'timeSlots' && _inUse(record))
                          ? null
                          : () => _edit(record),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: translate(context, 'Chỉnh sửa')),
                  IconButton(
                      onPressed: _saving || _inUse(record)
                          ? null
                          : () => _delete(record),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: translate(context, 'Xóa')),
                ]))),
    ]);
  }
}
