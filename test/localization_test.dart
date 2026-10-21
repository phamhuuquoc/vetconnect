import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vetconnect/l10n/app_text.dart';
import 'package:vetconnect/l10n/app_fields.dart';
import 'package:vetconnect/l10n/locale_controller.dart';
import 'package:vetconnect/l10n/language_picker.dart';
import 'package:vetconnect/l10n/translations.dart';
import 'package:vetconnect/screens/profile/profile_page.dart';
import 'package:vetconnect/screens/doctor/doctor_page.dart';
import 'package:vetconnect/models/app_user.dart';
import 'package:vetconnect/data/pet_repository.dart';
import 'package:vetconnect/screens/pet/add_pet_page.dart';

Widget localized(Widget child, {Locale locale = const Locale('vi')}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: LocaleController.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: child),
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await appLocale.load();
  });

  test(
      'language persists across controller instances and invalid choices fall back',
      () async {
    final first = LocaleController();
    await first.select(const Locale('en'));
    final restored = LocaleController();
    await restored.load();
    expect(restored.locale.languageCode, 'en');
    expect(() => restored.select(const Locale('xx')), throwsArgumentError);
    SharedPreferences.setMockInitialValues(
        {LocaleController.preferenceKey: 'xx'});
    await restored.load();
    expect(restored.locale.languageCode, 'vi');
  });

  testWidgets(
      'picker updates retained labels, native widgets and fields without losing input',
      (tester) async {
    final controller = TextEditingController(text: 'Miu');
    addTearDown(controller.dispose);
    await tester.pumpWidget(ListenableBuilder(
        listenable: appLocale,
        builder: (context, _) => localized(
              Column(children: [
                const AppText('Cài đặt'),
                const AppText('Đăng xuất'),
                AppTextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Password')),
                const LanguageSetting(),
              ]),
              locale: appLocale.locale,
            )));
    await tester.pumpAndSettle();
    expect(find.text('Cài đặt'), findsOneWidget);
    await tester.tap(find.text('Ngôn ngữ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(controller.text, 'Miu');
    final context = tester.element(find.byType(AppTextField));
    expect(MaterialLocalizations.of(context).cancelButtonLabel, 'Cancel');
    expect(
        (await SharedPreferences.getInstance())
            .getString(LocaleController.preferenceKey),
        'en');
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();
    expect(find.text('Cài đặt'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
    expect(controller.text, 'Miu');
  });

  for (final role in UserRole.values) {
    testWidgets('${role.name} has a language setting in Profile',
        (tester) async {
      await tester.pumpWidget(localized(
          ProfilePage(
              account: AppUser(
                  uid: 'test', email: 'account@example.com', role: role)),
          locale: const Locale('en')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Language'), 300,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Language'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('doctor workspace is translated', (tester) async {
    await tester
        .pumpWidget(localized(const DoctorPage(), locale: const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Doctor workspace'), findsOneWidget);
  });

  testWidgets(
      'translated pet choices keep canonical stored values and pet names',
      (tester) async {
    PetRepository.clearSession();
    addTearDown(PetRepository.clearSession);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      supportedLocales: LocaleController.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Builder(
          builder: (context) => Scaffold(
                  body: TextButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => AddPetPage(
                            onSave: (pet) async => PetRepository.addPet(pet)))),
                child: const Text('Open form'),
              ))),
    ));
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Home');
    await tester.enterText(find.byType(TextFormField).at(2), '2');
    await tester.enterText(find.byType(TextFormField).at(3), '4.5');
    await tester.tap(find.text('Cat'));
    await tester.scrollUntilVisible(
        find.widgetWithText(ElevatedButton, 'Add pet'), 300,
        scrollable: find
            .descendant(
                of: find.byType(SingleChildScrollView),
                matching: find.byType(Scrollable))
            .last);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add pet'));
    await tester.pumpAndSettle();
    expect(PetRepository.pets.single.name, 'Home');
    expect(PetRepository.pets.single.species, 'Mèo');
    await tester.pumpWidget(localized(
        const ProfilePage(
            account: AppUser(
                uid: 'owner', email: 'owner@example.com', role: UserRole.user)),
        locale: const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  test('dynamic messages preserve names and roles remain canonical', () {
    expect(translateFor('en', 'Bạn chắc chắn muốn xóa hồ sơ của Miu?'),
        'Delete the profile for Miu?');
    expect(
        translateFor(
            'en', 'Chuyển pet@example.com từ Người dùng thành Bác sĩ?'),
        'Change pet@example.com from User to Doctor?');
    expect(translateFor('en', 'British Shorthair - 2 tuổi'),
        'British Shorthair - 2 years old');
    expect(translateFor('vi', 'Forgot your password?'), 'Quên mật khẩu?');
    expect(UserRole.doctor.name, 'doctor');
  });
}
