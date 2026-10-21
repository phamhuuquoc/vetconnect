import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetconnect/widgets/floating_navigation.dart';
import 'package:vetconnect/main/main_page.dart';
import 'package:vetconnect/screens/book/book_page.dart';

void main() {
  for (final language in ['vi', 'en']) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          '$language navigation is usable at 320px and text scale $scale',
          (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final selected = ValueNotifier(0);
        addTearDown(selected.dispose);
        await tester.pumpWidget(MaterialApp(
          locale: Locale(language),
          supportedLocales: const [Locale('vi'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: MediaQuery(
              data: MediaQueryData(
                  size: const Size(320, 640),
                  textScaler: TextScaler.linear(scale)),
              child: ValueListenableBuilder<int>(
                  valueListenable: selected,
                  builder: (context, value, child) => Scaffold(
                        body: const SizedBox.expand(),
                        bottomNavigationBar: FloatingNavigation(
                            selectedIndex: value,
                            onSelected: (index) => selected.value = index),
                      ))),
        ));
        await tester.pumpAndSettle();
        final labels = language == 'vi'
            ? ['Trang chủ', 'Tìm kiếm', 'Đặt lịch', 'Lịch sử', 'Cá nhân']
            : ['Home', 'Search', 'Book now', 'History', 'Profile'];
        for (var index = 0; index < labels.length; index++) {
          await tester.tap(find.text(labels[index]));
          await tester.pumpAndSettle();
          expect(selected.value, index);
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
  testWidgets('booking CTA opens the booking tab', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        locale: Locale('vi'),
        supportedLocales: [Locale('vi'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: MainPage()));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsNothing);
    await tester.tap(find.text('Đặt lịch'));
    await tester.pumpAndSettle();
    expect(find.byType(BookPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
