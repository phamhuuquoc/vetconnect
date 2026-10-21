import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vetconnect/auth/role_guard.dart';
import 'package:vetconnect/models/app_user.dart';

void main() {
  test('unknown or missing roles never become privileged accounts', () {
    for (final value in [null, '', 'ADMIN', 'superadmin', 42]) {
      expect(() => UserRole.parse(value), throwsFormatException);
    }
    expect(UserRole.parse('user'), UserRole.user);
    expect(UserRole.parse('doctor'), UserRole.doctor);
    expect(UserRole.parse('admin'), UserRole.admin);
  });

  for (final target in UserRole.values) {
    for (final actor in UserRole.values) {
      testWidgets('${actor.name} access to ${target.name} area',
          (tester) async {
        await tester.pumpWidget(MaterialApp(
            locale: const Locale('vi'),
            supportedLocales: const [Locale('vi'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: RoleGuard(
              role: actor,
              allowedRoles: {target},
              child: const Text('Protected content'),
            )));
        expect(find.text('Protected content'),
            actor == target ? findsOneWidget : findsNothing);
        expect(find.text('Bạn không có quyền truy cập khu vực này.'),
            actor == target ? findsNothing : findsOneWidget);
      });
    }
  }

  testWidgets('revoking a role removes protected content', (tester) async {
    Widget page(UserRole role) => MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: const [Locale('vi'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: RoleGuard(
          role: role,
          allowedRoles: const {UserRole.admin},
          child: const Text('User management'),
        ));
    await tester.pumpWidget(page(UserRole.admin));
    expect(find.text('User management'), findsOneWidget);
    await tester.pumpWidget(page(UserRole.user));
    expect(find.text('User management'), findsNothing);
  });
}
