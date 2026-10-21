import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetconnect/widgets/home_discovery.dart';

void main() {
  for (final language in ['vi', 'en']) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          '$language home promotion fits small screens at text scale $scale',
          (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var clinics = 0;
        var bookings = 0;
        var pets = 0;
        await tester.pumpWidget(MaterialApp(
          locale: Locale(language),
          supportedLocales: const [Locale('vi'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: MediaQuery(
              data: MediaQueryData(
                  size: const Size(320, 640),
                  textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                  body: SingleChildScrollView(
                      child: Padding(
                padding: const EdgeInsets.all(16),
                child: HomeDiscovery(
                    onFindClinics: () => clinics++,
                    onBook: () => bookings++,
                    onAddPet: () => pets++),
              )))),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final label in language == 'vi'
            ? ['Tìm phòng khám', 'Khám phá dịch vụ', 'Tạo hồ sơ thú cưng']
            : [
                'Find a clinic',
                'Explore care services',
                'Create a pet profile'
              ]) {
          await tester.ensureVisible(find.text(label));
          await tester.tap(find.text(label));
        }
        expect([clinics, bookings, pets], [1, 1, 1]);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
