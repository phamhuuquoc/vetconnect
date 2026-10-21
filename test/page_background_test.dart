import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetconnect/data/pet_repository.dart';
import 'package:vetconnect/main/main_page.dart';
import 'package:vetconnect/theme/app_theme.dart';

void main() {
  testWidgets('tab backgrounds fill the viewport and safe areas',
      (tester) async {
    final previousShadows = debugDisableShadows;
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = previousShadows);
    PetRepository.clearSession();
    await tester.runAsync(() async {
      final config = jsonDecode(
          await File('.dart_tool/package_config.json').readAsString());
      final flutter = (config['packages'] as List)
          .firstWhere((p) => p['name'] == 'flutter');
      final sdk = Directory.fromUri(Uri.parse(flutter['rootUri'] as String))
          .parent
          .parent
          .path;
      for (final entry in {
        'Roboto': 'roboto-regular.ttf',
        'MaterialIcons': 'materialicons-regular.otf'
      }.entries) {
        final loader = FontLoader(entry.key);
        loader.addFont(
            File('$sdk/bin/cache/artifacts/material_fonts/${entry.value}')
                .readAsBytes()
                .then(ByteData.sublistView));
        await loader.load();
      }
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('vi'),
          supportedLocales: const [Locale('vi'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: buildAppTheme(fontFamily: 'Roboto'),
          home: const Scaffold(body: MainPage()),
        )));
    for (final entry in {
      'home': 'Trang chủ',
      'search': 'Tìm kiếm',
      'history': 'Lịch sử'
    }.entries) {
      await tester.tap(find.text(entry.value).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        // Sample the unoccupied left edge through the status bar, body and
        // lower safe area. Short content must not expose a different surface.
        for (final y in [0, 24, 300, 650, 843]) {
          final offset = y * image.width * 4;
          expect(rgba!.buffer.asUint8List().sublist(offset, offset + 3),
              [245, 246, 247],
              reason: '${entry.key}: mismatched background at y=$y');
        }
        await Directory('build/previews').create(recursive: true);
        await File('build/previews/background-${entry.key}.png')
            .writeAsBytes(png!.buffer.asUint8List());
        image.dispose();
      });
    }
    debugDisableShadows = previousShadows;
  });
}
