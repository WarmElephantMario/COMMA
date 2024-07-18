import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:io';
import 'components.dart';
import 'model/user_provider.dart';
import 'package:provider/provider.dart';
import '62lecture_start.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import './api/api.dart';

bool isAlternativeTextEnabled = true;
bool isRealTimeSttEnabled = false;

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
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);

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
        String mimeType = 'application/octet-stream';
        if (fileName.endsWith('.pdf')) {
          mimeType = 'application/pdf';
          _isPDF = true;
        } else if (fileName.endsWith('.png') ||
            fileName.endsWith('.jpg') ||
            fileName.endsWith('.jpeg')) {
          mimeType = 'image/png';
          _isPDF = false;
        }

        // Define metadata
        final metadata = SettableMetadata(
          contentType: mimeType,
        );

        // 파일명 유니크하게 만들기
        int timestamp = DateTime.now().millisecondsSinceEpoch;
        int f_id = timestamp ~/ fileName.length;
        int id = f_id ~/ fileName.length;

        // Upload file with metadata
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads/${userProvider.user!.userKey}/${fileName}_${id}');
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
        width: page.width.toInt(),
        height: page.height.toInt(),
        x: 0,
        y: 0,
      );

      final image = await pageImage.createImageIfNotAvailable();
      final imageData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (imageData != null) {
        images.add(imageData.buffer.asUint8List());
      }
    }
    return images;
  }

  Future<List<String>> uploadImagesToFirebase(
    List<Uint8List> images, int userKey) async {
    List<String> downloadUrls = [];

    for (int i = 0; i < images.length; i++) {
      _progressNotifier.value = (i + 1) / images.length; // 진행률 업데이트

      final storageRef =
          FirebaseStorage.instance.ref().child('uploads/$userKey/page_$i.jpg');
      final uploadTask = storageRef.putData(
          images[i], SettableMetadata(contentType: 'image/jpeg'));
      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }

  Future<String> callChatGPT4API(
      List<String> imageUrls,
      bool isAlternativeTextEnabled,
      bool isRealTimeSttEnabled,
      int userKey,
      String lectureFileName) async {
    const String apiKey = Env.apiKey;
    final Uri apiUrl = Uri.parse('https://api.openai.com/v1/chat/completions');
    final String promptForAlternativeText = '''
      당신은 시각장애인을 위한 대체텍스트를 작성하는 전문가입니다. 다음 강의 자료의 내용을 스크린 리더가 인식할 수 있도록 텍스트로 변환해 주세요. 
      시각장애인이 이 텍스트를 통해 강의 자료의 어느 위치에 어떤 글자나 그림이 있는지 알 수 있어야 합니다.
      조건:
      1. 강의 자료의 페이지가 여러 장인 경우, 각 페이지별로 대체텍스트를 생성하되, 페이지별 대체텍스트의 사이에는 '//' 라는 구분자를 넣어주세요.
         그리고 각 페이지의 대체텍스트의 시작과 끝에는 [n 페이지 설명 시작], [n 페이지 설명 끝] 이라는 문구를 붙여주세요.
      2. 강의 자료에 포함되어 있는 글은 수정 없이 텍스트로 그대로 옮겨 적어주세요. 다만, 해당 줄글이 강의 자료의 어느 위치에 쓰여 있는지에 대한 위치 설명은 추가되어야 합니다.
      3. 가능한 한 명확하고 간결하게 작성해 주세요.
      예시: [1페이지 설명 시작] 흰 바탕에 파란 테두리가 그려져있다. 오른쪽 위 모서리에는 이화생활도서고나 로고가 있다. 그 아래 가운데에는 글자색 파란색으로 "모두의 화장실"이라고 크게 적혀있다. 그 아래에는 글자색 검정색으로 "모두의 화장실이 뭐지?" 라고 적혀있다. [1페이지 설명 끝] //
       [2페이지 설명 시작] 맨 뒤에는 "모두의 화장실이란?" 이라고 적혀있다. 그 아래에는 "모두의 화장실은 단순 성별 중립 화장실을 포괄하는 보다 넓은 개념입니다." 라고 쓰여있다. [2페이지 설명 끝]
      ''';

    final String promptForKeywords = '''
      당신은 이미지 분석 전문가입니다. 다음 이미지 속에 있는 키워드를 최대한 많이 추출해 주세요. 조건은 다음과 같습니다:
      1. 중복되지 않는 키워드를 나열해 주세요.
      2. 키워드는 줄바꿈 없이 나열해 주세요.
      3. 가능한 한 많은 키워드를 포함해 주세요.
      ''';


  try {
    var messages = imageUrls.map((url) => {
      'role': 'user',
      'content': [
        {'type': 'text', 
        'text': isAlternativeTextEnabled ? promptForAlternativeText : promptForKeywords},
        {
          'type': 'image_url',
          'image_url': {'url': url}
        }
      ]
    }).toList();

      var response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': messages,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        var decodedResponse = jsonDecode(responseBody);
        var gptResponse = decodedResponse['choices'][0]['message']['content'];

        if (isAlternativeTextEnabled) {
          // 대체텍스트일 때만 save response(.txt file) to Firebase

          // Get temporary directory to store the file
          final directory = await getTemporaryDirectory();
          final filePath = path.join(
              directory.path, '${DateTime.now().millisecondsSinceEpoch}.txt');

          // Write response to .txt file
          final file = File(filePath);
          await file.writeAsString(gptResponse);

          // Define the storage path
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final storageRef = FirebaseStorage.instance.ref().child(
              'response/$userKey/$lectureFileName/${path.basename(filePath)}');
          UploadTask uploadTask = storageRef.putFile(file);

          TaskSnapshot taskSnapshot = await uploadTask;
          String responseUrl = await taskSnapshot.ref.getDownloadURL();
          print('$gptResponse');
          print('GPT Response stored URL: $responseUrl');

          // Optionally delete the temporary file
          await file.delete();
          return responseUrl; //.txt 저장한 url을 반환
        }
        return gptResponse; //대체텍스트 아니고 실시간 자막이면 그냥 로그를 반환
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
      print(
          'PDF to image conversion completed. Number of images: ${images.length}');

      // 이미지를 Firebase에 업로드
      print('Starting image upload to Firebase...');
      List<String> imageUrls = await uploadImagesToFirebase(images, userKey);
      print(
          'Image upload to Firebase completed. Number of image URLs: ${imageUrls.length}');

      // 이미지 URL 리스트 반환
      return imageUrls;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  void _onLearningTypeChanged(bool? isAlternativeText) {
    if (isAlternativeText != null) {
      setState(() {
        isAlternativeTextEnabled = isAlternativeText;
        isRealTimeSttEnabled = !isAlternativeText;
      });
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
          CustomRadioButton(
            label: '대체텍스트 생성',
            value: true,
            groupValue: isAlternativeTextEnabled,
            onChanged: _onLearningTypeChanged,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomRadioButton(
            label: '실시간 자막 생성',
            value: false,
            groupValue: isAlternativeTextEnabled,
            onChanged: _onLearningTypeChanged,
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
                          print(
                              "Starting learning with file: $_selectedFileName");
                          print("대체텍스트 선택 여부: $isAlternativeTextEnabled");
                          print("실시간자막 선택 여부: $isRealTimeSttEnabled");
                          if (_selectedFileName != null &&
                              _downloadURL != null &&
                              _isMaterialEmbedded == true) {
                            showLearningDialog(context, _selectedFileName!,
                                _downloadURL!, _progressNotifier);
                            try {
                              final userProvider = Provider.of<UserProvider>(
                                  context,
                                  listen: false);
                              int type = isAlternativeTextEnabled ? 0 : 1; //대체면 0, 실시간이면 1

                              if (_isPDF) {
                                if (_fileBytes != null) {
                                  handlePdfUpload(_fileBytes!,
                                          userProvider.user!.userKey)
                                      .then((imageUrls) async {
                                    final responseUrl = await callChatGPT4API(
                                        imageUrls,
                                        isAlternativeTextEnabled,
                                        isRealTimeSttEnabled,
                                        userProvider.user!.userKey,
                                        _selectedFileName!);
                                    print("GPT-4 Response: $responseUrl");
                                    if (Navigator.canPop(context)) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LectureStartPage(
                                          fileName: _selectedFileName!,
                                          fileURL: _downloadURL!,
                                          responseUrl: responseUrl,
                                          type: type, //대체인지 실시간인지 전달해줌
                                        ),
                                      ),
                                    );
                                  });
                                } else {
                                  print('Error: _fileBytes is null.');
                                }
                              } else {
                                final response = await callChatGPT4API(
                                    [_downloadURL!],
                                    isAlternativeTextEnabled,
                                    isRealTimeSttEnabled,
                                    userProvider.user!.userKey,
                                    _selectedFileName!);
                                print("GPT-4 Response: $response");
                                if (Navigator.canPop(context)) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LectureStartPage(
                                      fileName: _selectedFileName!,
                                      fileURL: _downloadURL!,
                                      responseUrl:
                                          response, //실시간 자막일 때는 그냥 response 전달하고 안쓰면됨
                                      type: type,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (Navigator.canPop(context)) {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              }
                              print('Error: $e');
                            }
                          } else {
                            print(
                                'Error: File name, URL, or embedded material is missing.');
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