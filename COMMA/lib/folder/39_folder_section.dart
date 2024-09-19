import 'package:flutter/material.dart';
import '../model/44_font_size_provider.dart';
import 'package:provider/provider.dart';


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
    // 폰트 크기 비율을 Provider에서 가져옴
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    // 디스플레이 비율을 가져옴
    final scaleFactor = fontSizeProvider.scaleFactor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            sectionTitle,
            style: TextStyle(
              color: Colors.black,
              fontSize: 26* scaleFactor,
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
                        fontSize: 15 * scaleFactor,
                      ),
                    ),
                    const SizedBox(width: 5),
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
                        fontSize: 15 *scaleFactor,
                      ),
                    ),
                    const SizedBox(width: 5.5),
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
