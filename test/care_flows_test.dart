import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetconnect/data/app_data_repository.dart';
import 'package:vetconnect/data/pet_repository.dart';
import 'package:vetconnect/models/pet.dart';
import 'package:vetconnect/screens/book/book_page.dart';
import 'package:vetconnect/screens/pet/add_pet_page.dart';
import 'package:vetconnect/screens/history/history_page.dart';
import 'package:vetconnect/widgets/app_data_scope.dart';

Widget page(Widget child) => MaterialApp(
    locale: const Locale('vi'),
    supportedLocales: const [Locale('vi'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    builder: (context, child) => AppDataScope(child: child!),
    home: Scaffold(body: child));
Pet pet() => Pet(
    id: 'pet',
    name: 'Luna',
    species: 'Mèo',
    breed: 'Mèo ta',
    ageYears: 2,
    weightKg: 4,
    gender: 'Cái');

void main() {
  setUp(() {
    AppDataRepository.clearSession();
    PetRepository.clearSession();
  });
  tearDown(() {
    AppDataRepository.clearSession();
    PetRepository.clearSession();
  });
  test('health records survive serialization and edits', () {
    final data = pet().copyWith(vaccines: [
      VaccineRecord(
          name: 'Rabies',
          date: DateTime.utc(2026, 11, 1),
          done: false,
          nextDate: DateTime.utc(2027, 11, 1))
    ], weights: [
      WeightRecord(date: DateTime.utc(2026, 10, 21), kg: 4.5)
    ], visits: [
      VisitRecord(
          date: DateTime.utc(2026, 10, 20),
          clinic: 'Clinic',
          service: 'Exam',
          priceVnd: 200000)
    ]).toMap();
    final restored = Pet.fromMap('pet', data).copyWith(name: 'Luna edited');
    expect(restored.vaccines.single.nextDate, DateTime.utc(2027, 11, 1));
    expect(restored.weights.single.kg, 4.5);
    expect(restored.visits.single.priceVnd, 200000);
    expect(restored.toMap()['name'], 'Luna edited');
  });
  testWidgets('invalid age and weight prevent saving, errors preserve the form',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(page(AddPetPage(onSave: (_) async {
      calls++;
      throw StateError('offline');
    })));
    await tester.enterText(find.byType(TextFormField).at(0), 'Luna');
    await tester.enterText(find.byType(TextFormField).at(2), '-1');
    await tester.enterText(find.byType(TextFormField).at(3), 'NaN');
    await tester.scrollUntilVisible(find.widgetWithText(ElevatedButton, 'Thêm thú cưng'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Thêm thú cưng'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('Vui lòng nhập số hợp lệ'), findsNWidgets(2));
    await tester.scrollUntilVisible(find.byType(TextFormField).at(2), -300,
        scrollable: find.byType(Scrollable).first);
    await tester.enterText(find.byType(TextFormField).at(2), '2');
    await tester.enterText(find.byType(TextFormField).at(3), '4,5');
    await tester.scrollUntilVisible(
        find.widgetWithText(ElevatedButton, 'Thêm thú cưng'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Thêm thú cưng'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(PetRepository.pets, isEmpty);
    expect(find.text('Không thể lưu. Kiểm tra kết nối và thử lại.'),
        findsOneWidget);
  });
  testWidgets(
      'booking requires selections and waits for server acknowledgement',
      (tester) async {
    PetRepository.addPet(pet());
    AppDataRepository.clinics = [
      const AppRecord('clinic', {'name': 'Clinic'})
    ];
    AppDataRepository.services = [
      const AppRecord('service', {
        'name': 'Exam',
        'clinicId': 'clinic',
        'priceVnd': 200000,
        'durationMinutes': 30
      })
    ];
    AppDataRepository.timeSlots = [
      const AppRecord('slot', {
        'clinicId': 'clinic',
        'serviceId': 'service',
        'status': 'available',
        'startsAt': '2099-10-25T09:00:00Z'
      })
    ];
    final done = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(page(BookPage(
        initialClinicId: 'clinic',
        onBook: (pet, slot) {
          expect(pet, 'pet');
          expect(slot, 'slot');
          calls++;
          return done.future;
        })));
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    await tester.tap(find.text('Luna'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exam'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.textContaining('2099'), 200);
    await tester.tap(find.textContaining('2099'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Gửi yêu cầu đặt lịch'), 200);
    await tester.tap(find.text('Gửi yêu cầu đặt lịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(calls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
        find.text(
            'Đã gửi yêu cầu đặt lịch. Theo dõi trạng thái trong Lịch sử.'),
        findsNothing);
    done.complete();
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Đã gửi yêu cầu đặt lịch. Theo dõi trạng thái trong Lịch sử.'),
        findsOneWidget);
  });
  testWidgets('a retained history route reacts to incoming appointment results',
      (tester) async {
    await tester.pumpWidget(page(const HistoryPage()));
    expect(find.text('Chưa có lịch sử khám.'), findsOneWidget);
    AppDataRepository.appointments = [
      const AppRecord('a', {
        'serviceName': 'Exam',
        'petName': 'Luna',
        'status': 'completed',
        'medicalNotes': 'Follow up next week'
      })
    ];
    AppDataRepository.changed();
    await tester.pumpAndSettle();
    expect(find.text('Follow up next week'), findsOneWidget);
    expect(find.text('Chưa có lịch sử khám.'), findsNothing);
  });
}
