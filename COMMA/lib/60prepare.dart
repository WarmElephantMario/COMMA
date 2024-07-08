import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'components.dart'; // components.dart 파일을 임포트
import '62lecture_start.dart'; 
import '63record.dart'; // 추가: RecordPage 임포트

class LearningPreparation extends StatefulWidget {
  const LearningPreparation({super.key});

  @override
  _LearningPreparationState createState() => _LearningPreparationState();
}

class _LearningPreparationState extends State<LearningPreparation> {
  String? _selectedFileName;
  String? _downloadURL; // 다운로드 URL을 저장할 변수 추가
  bool _isMaterialEmbedded = false;
  bool _isIconVisible = true;
  Uint8List? _fileBytes;

  int _selectedIndex = 2; // 학습 시작 탭이 기본 선택되도록 설정

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _fileBytes = result.files.first.bytes;
        _selectedFileName = result.files.first.name;
        _isMaterialEmbedded = true;
        _isIconVisible = false;
      });

      await _uploadFileToFirebase(_fileBytes!, _selectedFileName!);
    }
  }

  Future<void> _uploadFileToFirebase(Uint8List fileBytes, String fileName) async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = storageRef.putData(fileBytes);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _downloadURL = downloadURL; // 다운로드 URL 설정
      });

      print('File uploaded successfully! Download URL: $downloadURL');
    } catch (e) {
      print('File upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(toolbarHeight: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 15),
          const Text(
            '오늘의 학습 준비하기',
            style: TextStyle(
              color: Color(0xFF414141),
              fontSize: 24,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            '학습 유형을 선택해주세요.',
            style: TextStyle(
              color: Color(0xFF575757),
              fontSize: 16,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 30),
          Checkbox2(
            label: '대체텍스트 생성',
            onChanged: (bool value) {},
          ),
          Checkbox2(
            label: '실시간 자막 생성',
            onChanged: (bool value) {},
          ),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClickButton(
                  text: _isMaterialEmbedded ? '강의 자료 학습 시작하기' : '강의 자료를 임베드하세요',
                  onPressed: _isMaterialEmbedded ? () {
                    showLearningDialog(context, _selectedFileName!, _downloadURL!); // 파일 이름과 URL을 전달하여 showLearningDialog 호출
                  } : _pickFile,
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50.0,
                  iconPath: _isIconVisible ? 'assets/Vector.png' : null,
                ),
              ],
            ),
          ),
          if (_isMaterialEmbedded)
            Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFileName!,
                            style: TextStyle(
                              color: Color(0xFF575757),
                              fontSize: 15,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
