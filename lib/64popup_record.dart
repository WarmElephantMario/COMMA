import 'package:flutter/material.dart';

enum RecordingState { initial, recording, recorded }

void showStopRecordingDialog(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          '정말 녹음을 종료하시겠습니까?',
          style: TextStyle(
            color: Color(0xFF545454),
            fontSize: 14,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          '녹음을 종료하면 다시 시작할 수 없습니다.',
          style: TextStyle(
            color: Color(0xFF245B3A),
            fontSize: 11,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w200,
          ),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: Color(0xFFFFA17A),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onConfirm();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xFF545454),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}