import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/45_theme.dart';
import '../mypage/44_font_size_page.dart';

class AccessibilitySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '접근성 설정',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.onTertiary),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              '라이트 모드',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSecondary,
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
              activeColor: theme.colorScheme.primary,
              fillColor: MaterialStateProperty.resolveWith<Color?>(
                (states) {
                  if (states.contains(MaterialState.selected)) {
                    return theme.colorScheme.primary;
                  }
                  return theme.colorScheme.onSecondary;
                },
              ),
            ),
          ),
          ResponsiveSizedBox(height: 16), // 적절한 간격 추가
          ListTile(
            title: Text(
              '다크 모드',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSecondary,
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
              activeColor: theme.colorScheme.primary,
              fillColor: MaterialStateProperty.resolveWith<Color?>(
                (states) {
                  if (states.contains(MaterialState.selected)) {
                    return theme.colorScheme.primary;
                  }
                  return theme.colorScheme.onSecondary;
                },
              ),
            ),
          ),
          ResponsiveSizedBox(height: 16), // 적절한 간격 추가
          // 아래 코드가 활성화될 경우 적용
          // ListTile(
          //   title: Text(
          //     '시스템 모드',
          //     style: theme.textTheme.bodyLarge?.copyWith(
          //       color: theme.colorScheme.onSecondary,
          //     ),
          //   ),
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
