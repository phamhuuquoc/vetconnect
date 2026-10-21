import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth_gate.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/locale_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/app_data_scope.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await appLocale.load();
  } catch (_) {
    // Keep the default language if device preferences are unavailable.
  }
  runApp(const VetConnectApp());
}

class VetConnectApp extends StatelessWidget {
  const VetConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: appLocale,
        builder: (context, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'VetConnect',
              locale: appLocale.locale,
              supportedLocales: LocaleController.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: buildAppTheme(),
              builder: (context, child) =>
                  AppDataScope(child: child ?? const SizedBox.shrink()),
              home: const AuthGate(),
            ));
  }
}
