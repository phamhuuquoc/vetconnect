import '../../l10n/app_text.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/app_data_repository.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/app_data_scope.dart';

class DoctorPage extends StatelessWidget {
  const DoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppDataScope.watch(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.medical_services_outlined,
            size: 64, color: Color(0xFF1F41BB)),
        const SizedBox(height: 16),
        const AppText('Khu vực bác sĩ',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.heading)),
        const SizedBox(height: 12),
        const AppText('Tài khoản của bạn đã được cấp quyền bác sĩ.'),
        const SizedBox(height: 12),
        if (AppDataRepository.appointments.isEmpty)
          const AppText('Chưa có lịch khám được phân công.'),
        for (final appointment in AppDataRepository.appointments)
          AppointmentCard(appointment: appointment, staff: true),
      ],
    );
  }
}
