import 'package:flutter/material.dart';
import 'record.dart';

class LearningDialog extends StatelessWidget {
  final BuildContext parentContext;

  LearningDialog(this.parentContext);

  @override
  Widget build(BuildContext context) {
    // Navigate to RecordPage after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close the dialog
      Navigator.push(
        parentContext,
        MaterialPageRoute(builder: (context) => RecordPage()),
      );
    });

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.symmetric(vertical: 16.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 팝업 창 닫기
            },
            child: Text(
              '취소',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '강의 자료 학습중입니다',
            style: TextStyle(
              color: Color(0xFF414141),
              fontSize: 16,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF36AE92)),
            strokeWidth: 4.0,
          ),
          SizedBox(height: 16),
          Text(
            '75%',
            style: TextStyle(
              color: Color(0xFF414141),
              fontSize: 16,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
