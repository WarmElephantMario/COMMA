import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/44_font_size_provider.dart';

class FontSizePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('글씨 크기 조정'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: Text('보통', style: theme.textTheme.bodySmall),
            leading: Radio<double>(
              value: 1.0,
              groupValue: fontSizeProvider.scaleFactor,
              onChanged: (value) {
                if (value != null) {
                  fontSizeProvider.setScaleFactor(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text('크게', style: theme.textTheme.bodyMedium),
            leading: Radio<double>(
              value: 1.3,
              groupValue: fontSizeProvider.scaleFactor,
              onChanged: (value) {
                if (value != null) {
                  fontSizeProvider.setScaleFactor(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text('엄청 크게', style: theme.textTheme.bodyLarge),
            leading: Radio<double>(
              value: 1.5,
              groupValue: fontSizeProvider.scaleFactor,
              onChanged: (value) {
                if (value != null) {
                  fontSizeProvider.setScaleFactor(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
