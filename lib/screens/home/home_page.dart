import 'package:flutter/material.dart';
import '../../l10n/app_text.dart';
import '../../data/pet_repository.dart';
import '../../models/app_user.dart';
import '../pet/pet_detail_page.dart';
import '../../data/app_data_repository.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/home_discovery.dart';
import '../../theme/app_theme.dart';
import '../search/search_page.dart';
import '../book/book_page.dart';
import '../pet/add_pet_page.dart';
import '../../widgets/app_data_scope.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.account, this.onFindClinics, this.onBook});
  final AppUser? account;
  final VoidCallback? onFindClinics;
  final VoidCallback? onBook;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color primary = Color(0xFF1F41BB);
  static const Color bg = Color(0xFFF5F6F7);

  @override
  Widget build(BuildContext context) {
    AppDataScope.watch(context);
    final reminders = PetRepository.pets
        .where((pet) => AppDataRepository.remindersEnabled)
        .expand((pet) => pet.vaccines
            .where((v) => !v.done || v.nextDate != null)
            .map((v) =>
                (pet: pet, vaccine: v, date: v.done ? v.nextDate! : v.date)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return Container(
        color: bg,
        child: SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText('Xin chào,',
                  style: TextStyle(color: Colors.black54)),
              if (widget.account != null)
                Text(widget.account!.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.heading)),
              const SizedBox(height: 20),
              HomeDiscovery(
                onFindClinics:
                    widget.onFindClinics ?? () => _open(const SearchPage()),
                onBook: widget.onBook ?? () => _open(const BookPage()),
                onAddPet: _addPet,
              ),
              const SizedBox(height: 26),
              _title('Thú cưng của tôi'),
              const SizedBox(height: 10),
              if (PetRepository.pets.isEmpty) _empty('Chưa có thú cưng nào.'),
              for (final pet in PetRepository.pets)
                Card(
                    child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(pet.name),
                  subtitle: AppText(pet.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => PetDetailPage(pet: pet))),
                )),
              const SizedBox(height: 20),
              _title('Lịch hẹn sắp tới'),
              const SizedBox(height: 10),
              if (AppDataRepository.upcoming.isEmpty)
                _empty('Chưa có lịch hẹn sắp tới.'),
              for (final appointment in AppDataRepository.upcoming)
                AppointmentCard(appointment: appointment),
              const SizedBox(height: 20),
              _title('Nhắc nhở sắp tới'),
              const SizedBox(height: 10),
              if (reminders.isEmpty) _empty('Chưa có nhắc nhở.'),
              for (final item in reminders)
                Card(
                    child: ListTile(
                  leading: const Icon(Icons.vaccines, color: primary),
                  title: Text('${item.vaccine.name} - ${item.pet.name}'),
                  subtitle: Text(
                      '${item.date.day}/${item.date.month}/${item.date.year}'),
                )),
            ],
          ),
        )));
  }

  void _open(Widget page) => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(appBar: AppBar(), body: page)));

  Future<void> _addPet() async {
    final added = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(builder: (_) => const AddPetPage()));
    if (added == true && mounted) setState(() {});
  }

  Widget _title(String text) => AppText(text,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.heading));
  Widget _empty(String text) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: AppText(text));
}
