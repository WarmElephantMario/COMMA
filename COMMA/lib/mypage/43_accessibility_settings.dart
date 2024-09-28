import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/45_theme.dart';

class AccessibilitySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
            '접근성 설정',
            style: TextStyle(color: theme.colorScheme.onSecondary),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: theme.colorScheme.onTertiary)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              '라이트 모드',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary, // 텍스트 색상 지정
              ),
            ),
            leading: Radio(
              value: ThemeMode.light,
              groupValue: themeNotifier.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeNotifier.toggleTheme(value);
                }
              },
              activeColor:
                  Theme.of(context).colorScheme.onSecondary, // 라디오 버튼 색상 지정
              fillColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return Theme.of(context).colorScheme.primary; // 선택된 상태의 색상
                  }
                  return Theme.of(context).colorScheme.onSecondary; // 기본 상태의 색상
                },
              ),
            ),
          ),
          ListTile(
            title: Text(
              '다크 모드',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary, // 텍스트 색상 지정
              ),
            ),
            leading: Radio(
              value: ThemeMode.dark,
              groupValue: themeNotifier.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeNotifier.toggleTheme(value);
                }
              },
              activeColor:
                  Theme.of(context).colorScheme.primary, // 라디오 버튼 선택된 상태의 색상 지정
              fillColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return Theme.of(context)
                        .colorScheme
                        .primary; // 선택된 상태에서의 색상
                  }
                  return Theme.of(context).colorScheme.onSurface; // 기본 상태의 색상
                },
              ),
            ),
          ),
          // ListTile(
          //   title: Text('시스템 모드'),
          //   leading: Radio(
          //     value: ThemeMode.system,
          //     groupValue: themeNotifier.themeMode,
          //     onChanged: (ThemeMode? value) {
          //       if (value != null) {
          //         themeNotifier.toggleTheme(value);
          //       }
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
