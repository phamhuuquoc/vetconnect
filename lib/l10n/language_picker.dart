import 'package:flutter/material.dart';
import 'app_text.dart';
import 'locale_controller.dart';

class LanguageSetting extends StatelessWidget {
  const LanguageSetting({super.key});

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: const Icon(Icons.language, color: Color(0xFF1F41BB), size: 22),
        title: const AppText('Ngôn ngữ', style: TextStyle(fontSize: 14)),
        subtitle: Text(Localizations.localeOf(context).languageCode == 'en'
            ? 'English'
            : 'Tiếng Việt'),
        trailing:
            const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          useSafeArea: true,
          builder: (_) => const _LanguagePicker(),
        ),
      ));
}

class LanguageAction extends StatelessWidget {
  const LanguageAction({super.key});
  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            useSafeArea: true,
            builder: (_) => const _LanguagePicker()),
        icon: const Icon(Icons.language, size: 19),
        label: Text(Localizations.localeOf(context).languageCode.toUpperCase()),
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF1F41BB)),
      );
}

class _LanguagePicker extends StatefulWidget {
  const _LanguagePicker();
  @override
  State<_LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<_LanguagePicker> {
  bool _saving = false;
  Future<void> _select(String code) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await appLocale.select(Locale(code));
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              translate(context, 'Chưa thể lưu ngôn ngữ. Vui lòng thử lại.'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const AppText('Chọn ngôn ngữ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        for (final entry in {'vi': 'Tiếng Việt', 'en': 'English'}.entries)
          ListTile(
              title: Text(entry.value),
              enabled: !_saving,
              leading: Icon(
                  selected == entry.key
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: const Color(0xFF1F41BB)),
              onTap: () => _select(entry.key)),
        if (_saving) const LinearProgressIndicator(),
      ]),
    );
  }
}
