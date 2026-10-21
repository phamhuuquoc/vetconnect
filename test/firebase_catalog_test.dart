import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetconnect/data/app_data_repository.dart';
import 'package:vetconnect/data/pet_repository.dart';
import 'package:vetconnect/models/pet.dart';
import 'package:vetconnect/screens/search/search_page.dart';
import 'package:vetconnect/screens/book/book_page.dart';
import 'package:vetconnect/screens/home/home_page.dart';
import 'package:vetconnect/screens/doctor/doctor_page.dart';

Widget page(Widget child) => MaterialApp(
    locale: const Locale('vi'),
    supportedLocales: const [Locale('vi'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: Scaffold(body: child));
void main() {
  setUp(() {
    AppDataRepository.clearSession();
    PetRepository.clearSession();
    AppDataRepository.clinics = [
      const AppRecord('clinic', {
        'name': 'Firebase Clinic',
        'address': 'Firebase Address',
        'openingHours': '08–18'
      })
    ];
    AppDataRepository.doctors = [
      const AppRecord('doctor', {
        'name': 'Firebase Doctor',
        'clinicId': 'clinic',
        'specialty': 'Firebase Specialty'
      })
    ];
    AppDataRepository.services = [
      const AppRecord('service', {
        'name': 'Firebase Service',
        'clinicId': 'clinic',
        'priceVnd': 234000,
        'durationMinutes': 30
      })
    ];
    AppDataRepository.timeSlots = [
      const AppRecord('slot', {
        'clinicId': 'clinic',
        'serviceId': 'service',
        'doctorId': 'doctor',
        'startsAt': '2099-10-25T09:30:00+07:00',
        'status': 'available'
      })
    ];
  });
  tearDown(() {
    AppDataRepository.clearSession();
    PetRepository.clearSession();
  });
  testWidgets('clinic search renders and filters supplied Firestore records',
      (tester) async {
    await tester.pumpWidget(page(const SearchPage()));
    await tester.pumpAndSettle();
    expect(find.text('Firebase Clinic'), findsOneWidget);
    expect(find.text('Firebase Service'), findsOneWidget);
    expect(find.text('234000 đ'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('Firebase Clinic'), findsNothing);
  });
  testWidgets('booking options depend on selected clinic and service',
      (tester) async {
    PetRepository.addPet(Pet(
        id: 'pet',
        name: 'Firebase Pet',
        species: 'Mèo',
        breed: 'Mèo ta',
        ageYears: 2,
        weightKg: 4,
        gender: 'Cái'));
    await tester.pumpWidget(page(const BookPage()));
    await tester.pumpAndSettle();
    expect(find.text('Firebase Service'), findsNothing);
    await tester.tap(find.text('Firebase Clinic'));
    await tester.pumpAndSettle();
    expect(find.text('Firebase Service'), findsOneWidget);
    await tester.tap(find.text('Firebase Service'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Firebase Doctor'), 200);
    expect(find.text('Firebase Doctor'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });
  testWidgets('user and doctor workspaces render account appointment views',
      (tester) async {
    AppDataRepository.appointments = [
      const AppRecord('appointment', {
        'serviceName': 'Firebase Service',
        'petName': 'Firebase Pet',
        'clinicId': 'clinic',
        'doctorId': 'doctor',
        'startsAt': '2099-10-24T09:30:00+07:00',
        'status': 'confirmed',
        'priceVnd': 234000
      })
    ];
    for (final workspace in <Widget>[const HomePage(), const DoctorPage()]) {
      await tester.pumpWidget(page(workspace));
      await tester.pumpAndSettle();
      expect(find.text('Firebase Service - Firebase Pet'), findsOneWidget);
      expect(find.text('Đã xác nhận'), findsOneWidget);
    }
    AppDataRepository.clearSession();
    expect(AppDataRepository.appointments, isEmpty);
    expect(AppDataRepository.clinics, isEmpty);
  });
}
