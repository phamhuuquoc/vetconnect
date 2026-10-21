import 'package:flutter/material.dart';
import '../../data/app_data_repository.dart';
import '../../data/user_repository.dart';
import '../../l10n/app_text.dart';
import '../../models/app_user.dart';
import '../../widgets/appointment_card.dart';
import 'admin_users_page.dart';
import 'catalog_page.dart';
import '../../widgets/app_data_scope.dart';

class AdminWorkspace extends StatelessWidget {
  const AdminWorkspace(
      {super.key, required this.user, required this.repository});
  final AppUser user;
  final UserRepository repository;
  @override
  Widget build(BuildContext context) {
    AppDataScope.watch(context);
    return DefaultTabController(
        length: 3,
        child: Column(children: [
          const TabBar(isScrollable: true, tabs: [
            Tab(child: AppText('Tài khoản')),
            Tab(child: AppText('Dịch vụ và lịch')),
            Tab(child: AppText('Lịch khám'))
          ]),
          Expanded(
              child: TabBarView(children: [
            AdminUsersPage(currentUser: user, repository: repository),
            const CatalogPage(),
            ListView(padding: const EdgeInsets.all(16), children: [
              if (AppDataRepository.appointments.isEmpty)
                const AppText('Chưa có lịch sử khám.'),
              for (final a in AppDataRepository.appointments)
                AppointmentCard(appointment: a, staff: true),
            ]),
          ])),
        ]));
  }
}
