import 'package:flutter/material.dart';
import '../model/44_font_size_provider.dart';
import 'package:provider/provider.dart';
import '../mypage/43_font_size_page.dart';

class FolderSection extends StatelessWidget {
  final String sectionTitle;
  final VoidCallback onAddPressed;
  final VoidCallback onViewAllPressed;


  const FolderSection({
    super.key,
    required this.sectionTitle,
    required this.onAddPressed,
    required this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            sectionTitle,
            style: TextStyle(
              color: theme.colorScheme.onTertiary,
              fontSize: 26 ,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: onAddPressed,
                child: Row(
                  children: [
                    Text(
                      '추가하기',
                      style: TextStyle(
                        color: Color(0xFF36AE92),
                        fontSize: 15 ,
                      ),
                    ),
                    SizedBox(width: 5),
                    Image.asset('assets/add2.png'),
                  ],
                ),
              ),
              TextButton(
                onPressed: onViewAllPressed,
                child: Row(
                  children: [
                    Text(
                      '전체 보기',
                      style: TextStyle(
                        color: Color(0xFF36AE92),
                        fontSize: 15 ,
                      ),
                    ),
                    SizedBox(width: 5.5 ),
                    Image.asset('assets/navigate.png'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
