import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetconnect/data/pet_repository.dart';
import 'package:vetconnect/models/app_user.dart';
import 'package:vetconnect/models/pet.dart';
import 'package:vetconnect/screens/home/home_page.dart';
import 'package:vetconnect/screens/history/history_page.dart';
import 'package:vetconnect/screens/search/search_page.dart';
import 'package:vetconnect/screens/book/book_page.dart';
import 'package:vetconnect/screens/profile/profile_page.dart';

Widget page(Widget child) => MaterialApp(
    locale: const Locale('vi'),
    supportedLocales: const [Locale('vi'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: Scaffold(body: child));
void main() {
  setUp(PetRepository.clearSession);
  tearDown(PetRepository.clearSession);
  testWidgets(
      'empty account never displays example identities or business records',
      (tester) async {
    for (final screen in <Widget>[
      const HomePage(),
      const SearchPage(),
      const BookPage(),
      const HistoryPage(),
      const ProfilePage()
    ]) {
      await tester.pumpWidget(page(screen));
      await tester.pumpAndSettle();
      for (final value in [
        'Nguyễn Văn A',
        'nguyenvana@gmail.com',
        'Miu',
        'Béo',
        'Phòng khám Thú y An Phú',
        'Điểm thưởng',
        '200.000đ'
      ]) {
        expect(find.textContaining(value), findsNothing);
      }
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets(
      'home and history render the supplied pet records and real account identity',
      (tester) async {
    final pet = Pet.fromMap('firebase-pet', {
      'name': 'Luna Firebase',
      'species': 'Mèo',
      'breed': 'Mèo ta',
      'ageYears': 3,
      'weightKg': 4.5,
      'gender': 'Cái',
      'vaccines': [
        {'name': 'Vaccine Firebase', 'date': '2026-11-05', 'done': false}
      ],
      'visits': [
        {
          'date': '2026-10-01',
          'clinic': 'Clinic Firebase',
          'service': 'Khám Firebase',
          'priceVnd': 123000
        }
      ],
    });
    PetRepository.addPet(pet);
    await tester.pumpWidget(page(const HomePage(
        account: AppUser(
            uid: 'test',
            email: 'owner@vetconnect.test',
            role: UserRole.user))));
    await tester.pumpAndSettle();
    expect(find.text('owner@vetconnect.test'), findsOneWidget);
    expect(find.text('Luna Firebase'), findsOneWidget);
    expect(find.text('Vaccine Firebase - Luna Firebase'), findsOneWidget);
    expect(find.text('Thêm'), findsNothing);
    await tester.pumpWidget(page(const HistoryPage()));
    await tester.pumpAndSettle();
    expect(find.text('Clinic Firebase'), findsOneWidget);
    expect(find.text('Khám Firebase - Luna Firebase'), findsOneWidget);
    expect(find.text('123000 đ'), findsOneWidget);
  });
}
