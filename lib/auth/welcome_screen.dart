import '../l10n/app_fields.dart';
import '../l10n/app_text.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A lightweight, code-drawn brand animation; no image downloads at login.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.error, this.onRetry, this.onSignOut});

  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onSignOut;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  bool _reducedMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion) {
      _entrance.value = 1;
      _pulse.stop();
    } else {
      _entrance.forward();
      if (!_pulse.isAnimating) _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF6F8FF),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0F4FF), Colors.white, Color(0xFFF5F6F7)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 32),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: AnimatedBuilder(
                                animation:
                                    Listenable.merge([_entrance, _pulse]),
                                builder: (context, _) {
                                  final progress = _entrance.value;
                                  final textIn = Curves.easeOut.transform(
                                      (progress / .55).clamp(0.0, 1.0));
                                  final logoIn = Curves.easeOutBack.transform(
                                      ((progress - .18) / .82).clamp(0.0, 1.0));
                                  final brandIn = Curves.easeOut.transform(
                                      ((progress - .45) / .55).clamp(0.0, 1.0));
                                  final wave = _reducedMotion
                                      ? 0.0
                                      : (math.sin(_pulse.value * math.pi * 2) +
                                              1) /
                                          2;
                                  return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Opacity(
                                            opacity: textIn,
                                            child: Transform.translate(
                                              offset:
                                                  Offset(0, 12 * (1 - textIn)),
                                              child: const Column(children: [
                                                AppText('CHÀO MỪNG BẠN ĐẾN VỚI',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 2.4,
                                                        color:
                                                            Color(0xFF71809E))),
                                                SizedBox(height: 10),
                                                AppText(
                                                    'Một kết nối,\ntrọn yêu thương.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        height: 1.25,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xFF172B52))),
                                              ]),
                                            )),
                                        const SizedBox(height: 36),
                                        AppSemantics(
                                            label: 'Logo VetConnect',
                                            image: true,
                                            child: SizedBox(
                                              width: 200,
                                              height: 200,
                                              child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    for (final size in [
                                                      190.0,
                                                      152.0
                                                    ])
                                                      Transform.scale(
                                                          scale:
                                                              1 + wave * .035,
                                                          child: Container(
                                                            width: size,
                                                            height: size,
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    color: const Color(0xFF1F41BB).withValues(
                                                                        alpha: size ==
                                                                                190
                                                                            ? .05
                                                                            : .09))),
                                                          )),
                                                    Transform.translate(
                                                        offset: Offset(
                                                            0, -3 * wave),
                                                        child: Transform.scale(
                                                          scale:
                                                              .6 + .4 * logoIn,
                                                          child: Opacity(
                                                              opacity:
                                                                  logoIn.clamp(
                                                                      0.0, 1.0),
                                                              child: Container(
                                                                width: 112,
                                                                height: 112,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              34),
                                                                  gradient: const LinearGradient(
                                                                      begin: Alignment
                                                                          .topLeft,
                                                                      end: Alignment.bottomRight,
                                                                      colors: [
                                                                        Color(
                                                                            0xFF4168DB),
                                                                        Color(
                                                                            0xFF1F41BB)
                                                                      ]),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: const Color(0xFF1F41BB).withValues(
                                                                            alpha:
                                                                                .18),
                                                                        blurRadius:
                                                                            30,
                                                                        offset: const Offset(
                                                                            0,
                                                                            14))
                                                                  ],
                                                                ),
                                                                child: const ExcludeSemantics(
                                                                    child: Icon(
                                                                        Icons
                                                                            .pets_rounded,
                                                                        size:
                                                                            60,
                                                                        color: Colors
                                                                            .white)),
                                                              )),
                                                        )),
                                                    Positioned(
                                                        right: 35,
                                                        top: 35,
                                                        child: Opacity(
                                                            opacity: brandIn,
                                                            child: Container(
                                                              width: 27,
                                                              height: 27,
                                                              decoration: BoxDecoration(
                                                                  color: const Color(
                                                                      0xFF1F41BB),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .white,
                                                                      width:
                                                                          3)),
                                                              child: const Icon(
                                                                  Icons
                                                                      .add_rounded,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 18),
                                                            ))),
                                                  ]),
                                            )),
                                        const SizedBox(height: 16),
                                        Opacity(
                                            opacity: brandIn,
                                            child: const Column(children: [
                                              AppText('VetConnect',
                                                  style: TextStyle(
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: -1.2,
                                                      color:
                                                          Color(0xFF1F41BB))),
                                              SizedBox(height: 8),
                                              AppText(
                                                  'Đồng hành cùng sức khỏe thú cưng',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Color(0xFF71809E))),
                                            ])),
                                        const SizedBox(height: 40),
                                        if (widget.error == null) ...[
                                          AppSemantics(
                                              label: 'Đang chuẩn bị tài khoản',
                                              liveRegion: true,
                                              child: ExcludeSemantics(
                                                  child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children:
                                                    List.generate(3, (index) {
                                                  final intensity = _reducedMotion
                                                      ? .5
                                                      : (math.sin((_pulse.value -
                                                                      index *
                                                                          .16) *
                                                                  math.pi *
                                                                  2) +
                                                              1) /
                                                          2;
                                                  return Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4),
                                                      width: 6,
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: const Color(
                                                                  0xFF1F41BB)
                                                              .withValues(
                                                                  alpha: .2 +
                                                                      intensity *
                                                                          .65)));
                                                }),
                                              ))),
                                          const SizedBox(height: 14),
                                          const AppText(
                                              'Đang chuẩn bị không gian của bạn…',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF71809E))),
                                        ] else ...[
                                          AppSemantics(
                                              liveRegion: true,
                                              child: AppText(widget.error!,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      height: 1.5,
                                                      color:
                                                          Color(0xFF71809E)))),
                                          const SizedBox(height: 16),
                                          if (widget.onRetry != null)
                                            FilledButton.icon(
                                              onPressed: widget.onRetry,
                                              icon: const Icon(
                                                  Icons.refresh_rounded),
                                              label: const AppText('Thử lại'),
                                              style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF1F41BB)),
                                            ),
                                        ],
                                        if (widget.onSignOut != null) ...[
                                          const SizedBox(height: 18),
                                          TextButton(
                                              onPressed: widget.onSignOut,
                                              child: const AppText(
                                                  'Quay lại đăng nhập',
                                                  style: TextStyle(
                                                      color: Color(0xFF71809E),
                                                      fontSize: 12))),
                                        ],
                                      ]);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
          ),
        ),
      );
}
