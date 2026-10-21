import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_text.dart';
import '../../data/pet_repository.dart';
import '../../data/app_data_repository.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/app_data_scope.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    AppDataScope.watch(context);
    final visits = PetRepository.pets
        .expand((pet) => pet.visits.map((visit) => (pet: pet, visit: visit)))
        .toList()
      ..sort((a, b) => b.visit.date.compareTo(a.visit.date));
    return Container(
        color: const Color(0xFFF5F6F7),
        child: SafeArea(
            child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppText('Lịch sử khám',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading)),
            const SizedBox(height: 16),
            if (visits.isEmpty && AppDataRepository.appointments.isEmpty)
              const AppText('Chưa có lịch sử khám.'),
            for (final appointment in AppDataRepository.appointments)
              AppointmentCard(appointment: appointment),
            for (final entry in visits)
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.visit.clinic,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text('${entry.visit.service} - ${entry.pet.name}'),
                          const SizedBox(height: 6),
                          Text(
                              '${entry.visit.date.day}/${entry.visit.date.month}/${entry.visit.date.year}'),
                          Text('${entry.visit.priceVnd} đ'),
                        ],
                      ))),
          ],
        )));
  }
}
