import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/app_data_repository.dart';
import '../../l10n/app_text.dart';
import '../../l10n/app_fields.dart';
import '../book/book_page.dart';
import '../../widgets/app_data_scope.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    AppDataScope.watch(context);
    final clinics = AppDataRepository.clinics
        .where((c) => '${c.text('name')} ${c.text('address')}'
            .toLowerCase()
            .contains(_query.toLowerCase()))
        .toList();
    return Container(
        color: const Color(0xFFF5F6F7),
        child: SafeArea(
            child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppText('Tìm kiếm',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading)),
            const SizedBox(height: 16),
            AppTextField(
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search), hintText: 'Tìm phòng khám'),
                onChanged: (value) => setState(() => _query = value)),
            const SizedBox(height: 16),
            if (clinics.isEmpty) const AppText('Chưa có dữ liệu phòng khám.'),
            for (final clinic in clinics)
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(clinic.text('name'),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600)),
                          Text(clinic.text('address')),
                          Text(clinic.text('openingHours')),
                          if (clinic.text('phone').isNotEmpty)
                            SelectableText(clinic.text('phone')),
                          if (clinic.data['rating'] != null)
                            Text('★ ${clinic.number('rating')}'),
                          const SizedBox(height: 8),
                          for (final doctor in AppDataRepository.doctors
                              .where((d) => d.text('clinicId') == clinic.id))
                            Text(
                                '${doctor.text('name')} • ${doctor.text('specialty')}'),
                          for (final service in AppDataRepository.services
                              .where((s) => s.text('clinicId') == clinic.id))
                            ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(service.text('name')),
                                trailing:
                                    Text('${service.number('priceVnd')} đ')),
                          FilledButton.icon(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                      builder: (_) => Scaffold(
                                          appBar: AppBar(),
                                          body: BookPage(
                                              initialClinicId: clinic.id)))),
                              icon: const Icon(Icons.calendar_month),
                              label: const AppText('Đặt lịch')),
                        ],
                      ))),
          ],
        )));
  }
}
