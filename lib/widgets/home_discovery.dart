import 'package:flutter/material.dart';
import '../l10n/app_text.dart';
import '../theme/app_theme.dart';

class HomeDiscovery extends StatelessWidget {
  const HomeDiscovery(
      {super.key,
      required this.onFindClinics,
      required this.onBook,
      required this.onAddPet});
  final VoidCallback onFindClinics;
  final VoidCallback onBook;
  final VoidCallback onAddPet;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
        final showArt = constraints.maxWidth >= 310 && !largeText;
        final stackTiles = constraints.maxWidth < 310 || largeText;
        final tiles = [
          _DiscoveryTile(
              icon: Icons.event_available_rounded,
              color: const Color(0xFFE6F3ED),
              iconColor: const Color(0xFF1F41BB),
              title: 'Lên lịch chăm sóc',
              subtitle: 'Khám phá dịch vụ',
              onTap: onBook),
          _DiscoveryTile(
              icon: Icons.pets_rounded,
              color: const Color(0xFFFFF0E4),
              iconColor: const Color(0xFF1F41BB),
              title: 'Một hồ sơ, trọn quan tâm',
              subtitle: 'Tạo hồ sơ thú cưng',
              onTap: onAddPet),
        ];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE2ECFF), Color(0xFFEAF5F2)],
                )),
                child: Stack(children: [
                  Positioned(
                      right: -55,
                      top: -70,
                      child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: .06)))),
                  if (showArt)
                    const Positioned(
                        right: 4,
                        bottom: 55,
                        child: ExcludeSemantics(
                            child: SizedBox(
                                width: 132,
                                height: 172,
                                child: CustomPaint(
                                    painter: _CareCompanionPainter())))),
                  Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .7),
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.favorite_rounded,
                                          size: 12, color: AppColors.blue),
                                      SizedBox(width: 6),
                                      Flexible(
                                          child: AppText('GÓC YÊU THƯƠNG',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  letterSpacing: 1.1,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.blue))),
                                    ])),
                            const SizedBox(height: 18),
                            Padding(
                                padding:
                                    EdgeInsets.only(right: showArt ? 100 : 0),
                                child: const AppText(
                                    'Bạn nhỏ khỏe mạnh.\nBạn thêm an tâm.',
                                    style: TextStyle(
                                        fontSize: 23,
                                        height: 1.22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.heading,
                                        letterSpacing: -.6))),
                            const SizedBox(height: 12),
                            Padding(
                                padding:
                                    EdgeInsets.only(right: showArt ? 106 : 0),
                                child: const AppText(
                                    'Kết nối với phòng khám và dịch vụ chăm sóc thú cưng.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        height: 1.6,
                                        color: Color(0xFF526888)))),
                            const SizedBox(height: 20),
                            FilledButton(
                                onPressed: onFindClinics,
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                          child: AppText('Tìm phòng khám',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w700))),
                                      SizedBox(width: 10),
                                      Icon(Icons.arrow_forward_rounded,
                                          size: 17),
                                    ])),
                          ])),
                ]),
              )),
          const SizedBox(height: 22),
          const AppText('Dành cho bạn nhỏ',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading)),
          const SizedBox(height: 12),
          if (stackTiles) ...[
            tiles[0],
            const SizedBox(height: 12),
            tiles[1]
          ] else
            IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Expanded(child: tiles[0]),
                  const SizedBox(width: 12),
                  Expanded(child: tiles[1])
                ])),
        ]);
      });
}

class _DiscoveryTile extends StatelessWidget {
  const _DiscoveryTile(
      {required this.icon,
      required this.color,
      required this.iconColor,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final IconData icon;
  final Color color, iconColor;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon, color: iconColor, size: 25),
                const Spacer(),
                Icon(Icons.north_east_rounded, color: iconColor, size: 17)
              ]),
              const SizedBox(height: 16),
              AppText(title,
                  style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: AppColors.heading)),
              const SizedBox(height: 6),
              AppText(subtitle,
                  style:
                      TextStyle(fontSize: 11, height: 1.4, color: iconColor)),
            ]),
          )));
}

/// Scalable illustration drawn in the app's icon style, with no remote assets.
class _CareCompanionPainter extends CustomPainter {
  const _CareCompanionPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 132, size.height / 172);
    final paint = Paint()..isAntiAlias = true;
    void oval(Rect rect, Color color) =>
        canvas.drawOval(rect, paint..color = color);
    void round(Rect rect, double radius, Color color) => canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        paint..color = color);
    oval(const Rect.fromLTWH(9, 25, 116, 122), const Color(0xFFCADBFA));
    oval(const Rect.fromLTWH(17, 146, 100, 12), const Color(0xFFB9CFF1));
    round(const Rect.fromLTWH(33, 88, 69, 66), 29, const Color(0xFFF5F6F7));
    final ears = Path()
      ..moveTo(25, 61)
      ..lineTo(24, 14)
      ..quadraticBezierTo(26, 9, 31, 14)
      ..lineTo(55, 38)
      ..moveTo(83, 38)
      ..lineTo(109, 15)
      ..quadraticBezierTo(114, 11, 114, 18)
      ..lineTo(111, 66);
    canvas.drawPath(ears, paint..color = const Color(0xFFE0E8FA));
    final innerEars = Path()
      ..moveTo(32, 40)
      ..lineTo(31, 24)
      ..lineTo(45, 39)
      ..moveTo(96, 40)
      ..lineTo(108, 26)
      ..lineTo(107, 46);
    canvas.drawPath(innerEars, paint..color = const Color(0xFFADC1F2));
    oval(const Rect.fromLTWH(20, 35, 97, 78), Colors.white);
    oval(const Rect.fromLTWH(42, 71, 53, 36), const Color(0xFFF5F6F7));
    oval(const Rect.fromLTWH(41, 65, 6, 9), const Color(0xFF24374D));
    oval(const Rect.fromLTWH(89, 65, 6, 9), const Color(0xFF24374D));
    oval(const Rect.fromLTWH(29, 79, 14, 7), const Color(0xFFDCE6FF));
    oval(const Rect.fromLTWH(94, 79, 14, 7), const Color(0xFFDCE6FF));
    oval(const Rect.fromLTWH(63, 78, 10, 7), const Color(0xFF426CE1));
    final smile = Path()
      ..moveTo(68, 84)
      ..lineTo(68, 88)
      ..quadraticBezierTo(61, 96, 56, 88)
      ..moveTo(68, 88)
      ..quadraticBezierTo(75, 96, 81, 88);
    canvas.drawPath(
        smile,
        Paint()
          ..color = const Color(0xFF1F41BB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round);
    round(const Rect.fromLTWH(43, 109, 52, 9), 4, const Color(0xFF426CE1));
    oval(const Rect.fromLTWH(62, 112, 13, 14), const Color(0xFFADC1F2));
    round(const Rect.fromLTWH(76, 121, 46, 39), 12, Colors.white);
    round(const Rect.fromLTWH(94, 129, 10, 23), 2, const Color(0xFF1F41BB));
    round(const Rect.fromLTWH(87, 136, 24, 9), 2, const Color(0xFF1F41BB));
    oval(const Rect.fromLTWH(9, 14, 6, 6), Colors.white);
    oval(const Rect.fromLTWH(118, 95, 5, 5), const Color(0xFFDCE6FF));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CareCompanionPainter oldDelegate) => false;
}
