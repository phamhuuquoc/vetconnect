import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/care_repository.dart';
import '../../data/app_data_repository.dart';
import '../../l10n/app_text.dart';
import '../../widgets/app_data_scope.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.section});
  final String section;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _address = TextEditingController();
  final _form = GlobalKey<FormState>();
  final Set<String> _favorites = {};
  bool _reminders = true;
  bool _loading = true;
  bool _saving = false;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final data = (await CareRepository().settings.get()).data() ?? {};
      if (!mounted) return;
      _address.text = data['address'] as String? ?? '';
      _reminders = data['remindersEnabled'] as bool? ?? true;
      _favorites
        ..clear()
        ..addAll(List<String>.from(data['favoriteClinicIds'] as List? ?? []));
    } catch (_) {
      if (mounted) _failed = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_form.currentState?.validate() == false) return;
    setState(() => _saving = true);
    try {
      await CareRepository().saveSettings(switch (widget.section) {
        'Địa chỉ của tôi' => {'address': _address.text.trim()},
        'Cài đặt nhắc nhở' => {'remindersEnabled': _reminders},
        _ => {'favoriteClinicIds': _favorites.toList()},
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: AppText('Đã lưu thay đổi.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: AppText('Không thể lưu. Kiểm tra kết nối và thử lại.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: AppText('Đã gửi email đặt lại mật khẩu.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: AppText('Không thể gửi email. Vui lòng thử lại.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDataScope.watch(context);
    final section = widget.section;
    final billing = section == 'Chi phí khám';
    final help = section == 'Trợ giúp và hỗ trợ';
    final completed = AppDataRepository.appointments
        .where((a) => a.text('status') == 'completed')
        .toList();
    return Scaffold(
        appBar: AppBar(title: AppText(section)),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _failed
                ? Center(
                    child: TextButton(
                        onPressed: _load,
                        child: const AppText(
                            'Không thể tải dữ liệu. Nhấn để thử lại.')))
                : Form(
                    key: _form,
                    child:
                        ListView(padding: const EdgeInsets.all(20), children: [
                      if (section == 'Địa chỉ của tôi')
                        TextFormField(
                            controller: _address,
                            maxLines: 3,
                            maxLength: 500,
                            decoration: InputDecoration(
                                labelText: translate(context, 'Địa chỉ'))),
                      if (section == 'Cài đặt nhắc nhở') ...[
                        SwitchListTile(
                            title: const AppText(
                                'Hiện nhắc lịch chăm sóc trong ứng dụng'),
                            value: _reminders,
                            onChanged: _saving
                                ? null
                                : (v) => setState(() => _reminders = v)),
                        const AppText(
                            'Nhắc lịch hiển thị ở trang chủ. Thông báo đẩy cần được bật khi dịch vụ thông báo được kết nối.'),
                      ],
                      if (section == 'Phòng khám yêu thích') ...[
                        if (AppDataRepository.clinics.isEmpty)
                          const AppText('Chưa có dữ liệu phòng khám.'),
                        for (final c in AppDataRepository.clinics)
                          CheckboxListTile(
                              title: Text(c.text('name')),
                              subtitle: Text(c.text('address')),
                              value: _favorites.contains(c.id),
                              onChanged: _saving
                                  ? null
                                  : (v) => setState(() {
                                        if (v == true) {
                                          _favorites.add(c.id);
                                        } else {
                                          _favorites.remove(c.id);
                                        }
                                      })),
                      ],
                      if (billing) ...[
                        const AppText(
                            'Chi phí của các lần khám đã hoàn tất. Trạng thái này không phải xác nhận đã thanh toán.'),
                        const SizedBox(height: 16),
                        Text(
                            '${completed.fold<num>(0, (sum, a) => sum + a.number('priceVnd'))} đ',
                            style: Theme.of(context).textTheme.headlineMedium),
                        if (completed.isEmpty)
                          const AppText('Chưa có lịch sử khám.'),
                        for (final a in completed)
                          ListTile(
                              title: Text(
                                  '${a.text('serviceName')} • ${a.text('petName')}'),
                              subtitle: Text(AppDataRepository.clinicName(
                                  a.text('clinicId'))),
                              trailing: Text('${a.number('priceVnd')} đ')),
                      ],
                      if (help) ...[
                        const AppText(
                            'Đặt lịch: tạo hồ sơ thú cưng, chọn phòng khám, dịch vụ và khung giờ, sau đó gửi yêu cầu.'),
                        const SizedBox(height: 12),
                        const AppText(
                            'Theo dõi lịch trong Lịch sử. Bạn có thể hủy lịch chưa diễn ra; bác sĩ sẽ xác nhận và cập nhật kết quả khám tại đây.'),
                        const SizedBox(height: 12),
                        const AppText(
                            'Cần hỗ trợ y tế? Liên hệ phòng khám phụ trách. Thông tin liên hệ do phòng khám cung cấp:'),
                        for (final c in AppDataRepository.clinics
                            .where((c) => c.text('phone').isNotEmpty))
                          ListTile(
                              title: Text(c.text('name')),
                              subtitle: SelectableText(c.text('phone'))),
                        const Divider(),
                        TextButton(
                            onPressed: _saving ? null : _resetPassword,
                            child: const AppText('Gửi email đặt lại mật khẩu')),
                      ],
                      if (!billing && !help)
                        FilledButton(
                            onPressed: _saving ? null : _save,
                            child: const AppText('Lưu thay đổi')),
                      if (_saving) const LinearProgressIndicator(),
                    ])));
  }
}
