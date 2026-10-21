import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vetconnect/auth/welcome_screen.dart';

void main() {
  testWidgets('welcome animation renders a phone preview', (tester) async {
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
                .then((bytes) => ByteData.sublistView(bytes)));
        await loader.load();
      }
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: MaterialApp(
            locale: const Locale('vi'),
            supportedLocales: const [Locale('vi'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Roboto'),
            home: WelcomeScreen(onSignOut: () {}))));
    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.text('VetConnect'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('build/previews').create(recursive: true);
      await File('build/previews/auth-welcome.png')
          .writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('small screens and large text can scroll to retry and sign out',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var retried = false;
    var signedOut = false;
    await tester.pumpWidget(MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: const [Locale('vi'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: MediaQuery(
          data: const MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(2),
              disableAnimations: true),
          child: WelcomeScreen(
              error: 'Chưa thể kết nối với tài khoản của bạn.',
              onRetry: () => retried = true,
              onSignOut: () => signedOut = true),
        )));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Thử lại'));
    await tester.tap(find.text('Thử lại'));
    expect(retried, isTrue);
    await tester.ensureVisible(find.text('Quay lại đăng nhập'));
    await tester.tap(find.text('Quay lại đăng nhập'));
    expect(signedOut, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
