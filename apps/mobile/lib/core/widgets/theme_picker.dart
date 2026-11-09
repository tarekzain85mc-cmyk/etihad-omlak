import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({required this.value, required this.onChanged, super.key});

  final AppThemeMode value;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppThemeMode>(
      tooltip: 'تغيير مظهر التطبيق',
      initialValue: value,
      onSelected: onChanged,
      icon: const Icon(Icons.contrast_rounded),
      itemBuilder: (context) => AppThemeMode.values
          .map(
            (mode) => PopupMenuItem(
              value: mode,
              child: Row(
                children: [
                  Icon(
                    mode == value
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  const SizedBox(width: 12),
                  Text(mode.label),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
