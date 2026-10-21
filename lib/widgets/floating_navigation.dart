import 'package:flutter/material.dart';
import '../l10n/app_text.dart';

class FloatingNavigation extends StatelessWidget {
  const FloatingNavigation(
      {super.key, required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  static const _blue = Color(0xFF1F41BB);

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(12) > 17;
    final items = <Widget>[
      _item(context, 0, Icons.home_outlined, Icons.home_rounded, 'Home'),
      _item(context, 1, Icons.search_rounded, Icons.search_rounded, 'Search'),
      _item(
          context, 3, Icons.history_rounded, Icons.history_rounded, 'History'),
      _item(context, 4, Icons.person_outline_rounded, Icons.person_rounded,
          'Profile'),
    ];
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: EdgeInsets.fromLTRB(8, largeText ? 10 : 8, 8, 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE8EDF5)),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF1F315A).withValues(alpha: .09),
                  blurRadius: 24,
                  offset: const Offset(0, 6))
            ]),
        child: largeText
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                _bookingButton(context, horizontal: true),
                const SizedBox(height: 8),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (final item in items) Expanded(child: item)
                ]),
              ])
            : Row(children: [
                Expanded(child: items[0]),
                Expanded(child: items[1]),
                const SizedBox(width: 4),
                SizedBox(
                    width: MediaQuery.sizeOf(context).width < 350 ? 86 : 98,
                    child: _bookingButton(context)),
                const SizedBox(width: 4),
                Expanded(child: items[2]),
                Expanded(child: items[3]),
              ]),
      ),
    );
  }

  Widget _bookingButton(BuildContext context, {bool horizontal = false}) =>
      Semantics(
        button: true,
        selected: selectedIndex == 2,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF466CE2), _blue]),
            borderRadius: BorderRadius.circular(19),
            boxShadow: [
              BoxShadow(
                  color: _blue.withValues(alpha: .24),
                  blurRadius: 12,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(19),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onSelected(2),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
                  child: horizontal
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.calendar_month_rounded,
                                  color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Flexible(
                                  child: AppText('Đặt lịch',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700))),
                            ])
                      : const Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.calendar_month_rounded,
                              color: Colors.white, size: 25),
                          SizedBox(height: 5),
                          AppText('Đặt lịch',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ]),
                ),
              )),
        ),
      );

  Widget _item(BuildContext context, int index, IconData icon,
      IconData activeIcon, String label) {
    final selected = selectedIndex == index;
    return Semantics(
      button: true,
      selected: selected,
      child: Tooltip(
          message: translate(context, label),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(17),
              onTap: () => onSelected(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFEBF0FF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(selected ? activeIcon : icon,
                          size: 22,
                          color: selected ? _blue : const Color(0xFF8A95A8))),
                  const SizedBox(height: 5),
                  AppText(label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          height: 1.2,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? _blue : const Color(0xFF8A95A8))),
                ]),
              ),
            ),
          )),
    );
  }
}
