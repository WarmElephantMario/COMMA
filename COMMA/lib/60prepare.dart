import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:io';
import 'components.dart';
import 'model/user_provider.dart';
import 'package:provider/provider.dart';
import '62_lecture_start.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_image/flutter_image.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:pdf_render/pdf_render.dart' as pdfr;
import 'env/env.dart';
import 'package:dart_openai/dart_openai.dart';
import 'dart:ui' as ui;

bool isAlternativeTextEnabled = false;

class LearningPreparation extends StatefulWidget {
  const LearningPreparation({super.key});

  @override
  _LearningPreparationState createState() => _LearningPreparationState();
}

class _LearningPreparationState extends State<LearningPreparation> {
  String? _selectedFileName;
  String? _downloadURL;
  bool _isMaterialEmbedded = false;
  bool _isIconVisible = true;
  Uint8List? _fileBytes;
  bool _isPDF = false;
  late pdfx.PdfController _pdfController;

  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      String fileName = result.files.first.name;

      if (fileBytes == null) {
        String? filePath = result.files.first.path;
        if (filePath != null) {
          File file = File(filePath);
          fileBytes = await file.readAsBytes();
        } else {
          return;
        }
      }

      try {
        // Determine MIME type
        String mimeType = 'application/octet-stream';
        if (fileName.endsWith('.pdf')) {
          mimeType = 'application/pdf';
          _isPDF = true;
        } else if (fileName.endsWith('.png') ||
            fileName.endsWith('.jpg') ||
            fileName.endsWith('.jpeg')) {
          mimeType = 'image/png'; // or 'image/jpeg' based on the file extension
          _isPDF = false;
        }
        // Define metadata
        final metadata = SettableMetadata(
          contentType: mimeType,
        );

        // Upload file with metadata
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads/${userProvider.user!.userKey}/$fileName');
        UploadTask uploadTask = storageRef.putData(fileBytes, metadata);

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          _selectedFileName = fileName;
          _downloadURL = downloadURL;
          _isMaterialEmbedded = true;
          _isIconVisible = false;
          _fileBytes = fileBytes;

          if (_isPDF) {
            _pdfController = pdfx.PdfController(
              document: pdfx.PdfDocument.openData(fileBytes!),
            );
          }
        });

        print('File uploaded successfully: $downloadURL');
      } catch (e) {
        print('File upload failed: $e');
      }
    }
  }

Future<List<Uint8List>> convertPdfToImages(Uint8List pdfBytes) async {
  final document = await pdfr.PdfDocument.openData(pdfBytes);
  final pageCount = document.pageCount;
  List<Uint8List> images = [];

  for (int i = 0; i < pageCount; i++) {
    final page = await document.getPage(i + 1);
    final pageImage = await page.render(
      width: page.width.toInt(), // double to int
      height: page.height.toInt(), // double to int
      x: 0,
      y: 0,
    );
    
    if (pageImage != null) {
      final image = await pageImage.createImageIfNotAvailable();
      final imageData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (imageData != null) {
        images.add(imageData.buffer.asUint8List());
      }
    }
  }
  return images;
}

  Future<List<String>> uploadImagesToFirebase(List<Uint8List> images, int userKey) async {
    List<String> downloadUrls = [];

    for (int i = 0; i < images.length; i++) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/$userKey/page_$i.jpg');
      final uploadTask = storageRef.putData(images[i], SettableMetadata(contentType: 'image/jpeg'));
      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }



  Future<String> callChatGPT4API(List<String> imageUrls) async {
    const String apiKey = Env.apiKey;
    final Uri apiUrl =
        Uri.parse('https://api.openai.com/v1/chat/completions'); // 엔드포인트 수정

    try {
      var response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o', // 모델 변경
          'messages': imageUrls.map((url) => {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': '이미지 속에 있는 키워드를 중복되지 않는 것으로 최대한 많이 말해주세요.'},
              {
                'type': 'image_url',
                'image_url': {'url': url}
              }
            ]
          }).toList(),
          'max_tokens': 100,
        }),
      );

      var responseBody = response.body;

  if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      var decodedResponse = jsonDecode(responseBody);
      return decodedResponse['choices'][0]['message']['content'];
    } else {
      var responseBody = utf8.decode(response.bodyBytes);
      print('Error calling ChatGPT-4 API: ${response.statusCode}');
      print('Response body: $responseBody'); 
      return 'Error: ${response.statusCode}';
    }
    } catch (e) {
      print('Error: $e');
      return 'Error: $e';
    }
  }

Future<List<String>> handlePdfUpload(Uint8List pdfBytes, int userKey) async {
    try {
        // PDF를 이미지로 변환
        print('Starting PDF to image conversion...');
        List<Uint8List> images = await convertPdfToImages(pdfBytes);
        print('PDF to image conversion completed. Number of images: ${images.length}');

        // 이미지를 Firebase에 업로드
        print('Starting image upload to Firebase...');
        List<String> imageUrls = await uploadImagesToFirebase(images, userKey);
        print('Image upload to Firebase completed. Number of image URLs: ${imageUrls.length}');

        // 이미지 URL 리스트 반환
        return imageUrls;
    } catch (e) {
        print('Error: $e');
        return [];
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
          CustomCheckbox(
            label: '대체텍스트 생성',
            isSelected: isAlternativeTextEnabled,
            onChanged: (bool value) {
              setState(() {
                isAlternativeTextEnabled = value;
              });
            },
          ),
          CustomCheckbox(
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
              onPressed: _isMaterialEmbedded
                  ? () async {
                      print("Starting learning with file: $_selectedFileName");
                      print("대체텍스트 선택 여부: $isAlternativeTextEnabled");
                      if (_selectedFileName != null && _downloadURL != null && _isMaterialEmbedded == true) {
                          showLearningDialog(context, _selectedFileName!, _downloadURL!);
                      try {
                          final userProvider = Provider.of<UserProvider>(context, listen: false);
                          if (_isPDF) {
                              if (_fileBytes != null) { // Add null check here
                                  // PDF 파일을 이미지로 변환하고 Firebase에 업로드
                                  handlePdfUpload(_fileBytes!, userProvider.user!.userKey).then((imageUrls) async {
                                      final response = await callChatGPT4API(imageUrls);  // 이미지 URL 리스트 전달
                                      print("GPT-4 Response: $response");
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LectureStartPage2(
                                                  fileName: _selectedFileName!,
                                                  fileURL: _downloadURL!,
                                                  response: response,
                                              ),
                                          ),
                                      );
                                  });
                              } else {
                                  print('Error: _fileBytes is null.');
                              }
                          } else {
                                  final response = await callChatGPT4API([_downloadURL!]);  // 단일 이미지 URL 리스트 전달
                                  print("GPT-4 Response: $response");
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LectureStartPage2(
                                              fileName: _selectedFileName!,
                                              fileURL: _downloadURL!,
                                              response: response,
                                          ),
                                      ),
                                  );
                              }
                          } catch (e) {
                              Navigator.of(context).pop();
                              print('Error: $e');
                              // Handle the error or show an error message to the user
                          }
                      } else {
                          print('Error: File name, URL, or embedded material is missing.');
                      }
                  }
                  : _pickFile,
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
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(_isPDF ? Icons.picture_as_pdf : Icons.image,
                          color: _isPDF ? Colors.red : Colors.blue, size: 40),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFileName!,
                            style: const TextStyle(
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
          if (_downloadURL != null)
            _isPDF
                ? SizedBox(
                    height: 600,
                    child: pdfx.PdfView(
                      controller: _pdfController,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Image.network(
                      _downloadURL!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // 에러 로그 출력
                        print('Error loading image: $error');
                        print('Stack trace: $stackTrace');
                        print('Image URL: $_downloadURL');

                        return const Center(
                          child: Text(
                            '이미지를 불러올 수 없습니다.',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        ],
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
