import '../data/app_data_repository.dart';
import '../l10n/app_text.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/pet_repository.dart';
import '../data/user_repository.dart';
import '../main/main_page.dart';
import '../models/app_user.dart';
import '../screens/admin/admin_workspace.dart';
import '../screens/doctor/doctor_page.dart';
import '../screens/profile/profile_page.dart';
import 'login_page.dart';
import 'role_guard.dart';
import 'welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Scaffold(
                body: Center(
                    child: AppText('Không thể kiểm tra phiên đăng nhập.')));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const WelcomeScreen();
          }
          final user = snapshot.data;
          // Keep auth pages on their own navigator. Successful authentication
          // disposes the entire stack, including signup/reset pages.
          if (user == null) {
            return Navigator(
              key: const ValueKey('signed-out'),
              onGenerateRoute: (_) =>
                  MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            );
          }
          return _UserSession(key: ValueKey(user.uid), user: user);
        },
      );
}

class _UserSession extends StatefulWidget {
  const _UserSession({super.key, required this.user});
  final User user;

  @override
  State<_UserSession> createState() => _UserSessionState();
}

class _UserSessionState extends State<_UserSession> {
  final UserRepository _repository = UserRepository();
  late Stream<AppUser?> _profile;
  Timer? _introTimer;
  bool _introComplete = false;
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    // Clear cached pets before loading this account's Firestore records.
    PetRepository.clearSession();
    AppDataRepository.clearSession();
    _profile = _loadProfile();
    _introTimer = Timer(const Duration(milliseconds: 1900), () {
      if (mounted) setState(() => _introComplete = true);
    });
  }

  Stream<AppUser?> _loadProfile() async* {
    yield null;
    await _repository.ensureProfile(widget.user);
    await Future.wait([
      PetRepository.loadForUser(widget.user.uid),
      AppDataRepository.loadForUser(widget.user.uid)
    ]);
    await for (final profile in _repository.watchProfile(widget.user.uid)) {
      if (profile != null) AppDataRepository.watchForUser(profile);
      yield profile;
    }
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    PetRepository.clearSession();
    AppDataRepository.clearSession();
    super.dispose();
  }

  Widget _welcome({String? error}) => WelcomeScreen(
        error: error,
        onRetry: error == null
            ? null
            : () => setState(() => _profile = _loadProfile()),
        onSignOut: () async {
          try {
            await FirebaseAuth.instance.signOut();
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: AppText('Chưa thể đăng xuất. Vui lòng thử lại.')),
              );
            }
          }
        },
      );

  @override
  Widget build(BuildContext context) => StreamBuilder<AppUser?>(
        stream: _profile,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _welcome(
                error:
                    'Chưa thể kết nối với tài khoản của bạn. Vui lòng thử lại hoặc liên hệ quản trị viên.');
          }
          final profile = snapshot.data;
          if (profile == null ||
              (!_introComplete && !MediaQuery.disableAnimationsOf(context))) {
            return _welcome();
          }
          final animateEntrance = !_entered;
          _entered = true;
          // Replacing this navigator on role changes discards privileged
          // screens and dialogs that were opened before revocation.
          final navigator = Navigator(
            key: ValueKey('${profile.uid}:${profile.role.name}'),
            onGenerateRoute: (settings) => MaterialPageRoute<void>(
              settings: settings,
              builder: (pageContext) => Scaffold(
                backgroundColor: const Color(0xFFF5F6F7),
                appBar:
                    profile.role == UserRole.user && settings.name != '/profile'
                        ? null
                        : AppBar(
                            toolbarHeight: 48,
                            elevation: 0,
                            scrolledUnderElevation: 0,
                            backgroundColor: const Color(0xFFF5F6F7),
                            title: AppText(
                                settings.name == '/profile'
                                    ? 'Cá nhân'
                                    : 'VetConnect',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            actions: [
                              if (profile.role != UserRole.user &&
                                  settings.name != '/profile')
                                IconButton(
                                  tooltip: translate(pageContext, 'Profile'),
                                  icon: const Icon(Icons.person_outline),
                                  onPressed: () => Navigator.of(pageContext)
                                      .pushNamed('/profile'),
                                ),
                            ],
                          ),
                body: ValueListenableBuilder<int>(
                  valueListenable: AppDataRepository.revision,
                  builder: (context, value, child) => Column(children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: AppDataRepository.syncError,
                      builder: (context, error, child) => error == null
                          ? const SizedBox.shrink()
                          : MaterialBanner(content: AppText(error), actions: [
                              TextButton(
                                  onPressed: () =>
                                      AppDataRepository.watchForUser(profile),
                                  child: const AppText('Thử lại'))
                            ]),
                    ),
                    Expanded(child: _rolePage(profile, settings.name)),
                  ]),
                ),
              ),
            ),
          );
          // Only fade the first incoming workspace. Never retain an outgoing
          // privileged page when a role is revoked or a session is lost.
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: animateEntrance ? 0 : 1, end: 1),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 400),
            builder: (context, value, child) =>
                Opacity(opacity: value, child: child),
            child: navigator,
          );
        },
      );

  Widget _rolePage(AppUser user, String? route) {
    if (route == '/profile') return ProfilePage(account: user);
    if (route == '/admin' || (route == '/' && user.role == UserRole.admin)) {
      return RoleGuard(
          role: user.role,
          allowedRoles: const {UserRole.admin},
          child: AdminWorkspace(user: user, repository: _repository));
    }
    if (route == '/doctor' || (route == '/' && user.role == UserRole.doctor)) {
      return RoleGuard(
          role: user.role,
          allowedRoles: const {UserRole.doctor},
          child: const DoctorPage());
    }
    if (route == '/') {
      return RoleGuard(
          role: user.role,
          allowedRoles: const {UserRole.user},
          child: MainPage(account: user));
    }
    return const Center(
        child:
            AppText('Trang không tồn tại hoặc bạn không có quyền truy cập.'));
  }
}
