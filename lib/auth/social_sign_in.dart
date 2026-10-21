import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../l10n/app_text.dart';

/// Enable only after configuring the provider and the release signing SHA in
/// Firebase. Facebook on mobile additionally requires its native SDK setup.
class SocialSignIn extends StatefulWidget {
  const SocialSignIn({super.key});
  @override
  State<SocialSignIn> createState() => _SocialSignInState();
}

class _SocialSignInState extends State<SocialSignIn> {
  static const googleEnabled = bool.fromEnvironment('GOOGLE_SIGN_IN_ENABLED');
  static const facebookEnabled =
      bool.fromEnvironment('FACEBOOK_SIGN_IN_ENABLED');
  bool _busy = false;
  static Future<void>? _googleReady;
  Future<void> _signIn(bool google) async {
    setState(() => _busy = true);
    try {
      final auth = FirebaseAuth.instance;
      if (kIsWeb) {
        await auth.signInWithPopup(
            google ? GoogleAuthProvider() : FacebookAuthProvider());
      } else if (google) {
        _googleReady ??= GoogleSignIn.instance.initialize();
        await _googleReady;
        final account = await GoogleSignIn.instance.authenticate();
        await auth.signInWithCredential(GoogleAuthProvider.credential(
            idToken: account.authentication.idToken));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: AppText('Đăng nhập chưa thành công. Vui lòng thử lại.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!googleEnabled && !(facebookEnabled && kIsWeb)) {
      return const SizedBox.shrink();
    }
    return Column(children: [
      const AppText('Or continue with'),
      const SizedBox(height: 12),
      Wrap(spacing: 12, children: [
        if (googleEnabled)
          OutlinedButton.icon(
              onPressed: _busy ? null : () => _signIn(true),
              icon: Image.asset('assets/icons/google_icon.png', width: 20),
              label: const Text('Google')),
        if (facebookEnabled && kIsWeb)
          OutlinedButton.icon(
              onPressed: _busy ? null : () => _signIn(false),
              icon: Image.asset('assets/icons/facebook_icon.png', width: 20),
              label: const Text('Facebook')),
      ]),
      if (_busy) const LinearProgressIndicator(),
    ]);
  }
}
