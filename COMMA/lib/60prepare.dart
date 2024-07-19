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
  String _selectedFolder = '폴더';
  String _noteName = '새로운 노트';
  List<Map<String, dynamic>> folderList = [];
  List<Map<String, dynamic>> items = [];
  int _selectedIndex = 2;
  int? lecturefileId; 

  @override
  void initState() {
    super.initState();
    fetchFolderList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchFolderList() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      try {
        // currentFolderId를 쿼리 파라미터로 포함
        final uri = Uri.parse('${API.baseUrl}/api/lecture-folders?userKey=$userKey');
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final List<dynamic> folderData = json.decode(response.body);

          setState(() {
            // 현재 선택된 폴더를 제외하고 나머지 폴더 목록 업데이트
            folderList = folderData
                .map((folder) => {
                      'id': folder['id'],
                      'folder_name': folder['folder_name'],
                      'selected': false,
                    })
                .toList();

            var defaultFolder = folderList.firstWhere(
                (folder) => folder['folder_name'] == '기본 폴더',
                orElse: () => <String, dynamic>{});
            if (defaultFolder.isNotEmpty) {
              _selectFolder(defaultFolder['folder_name']);
            }
          });
        } else {
          throw Exception('Failed to load folders');
        }
      } catch (e) {
        print('Folder list fetch failed: $e');
      }
    } else {
      print('User Key is null, cannot fetch folders.');
    }
  }

  void _selectFolder(String folderName) {
    setState(() {
      _selectedFolder = folderName;
    });
  }

  Future<void> fetchOtherFolders(String fileType, int currentFolderId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      try {
        final uri = Uri.parse(
            '${API.baseUrl}/api/getOtherFolders/$fileType/$userKey=$userKey');
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          List<Map<String, dynamic>> fetchedFolders =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));

          setState(() {
            // 기존의 폴더 리스트를 업데이트하는 대신, fetchedFolders를 사용합니다.
            folderList = fetchedFolders;
          });
        } else {
          throw Exception(
              'Failed to load folders with status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching other folders: $e');
        rethrow;
      }
    } else {
      print('User Key is null, cannot fetch folders.');
    }
  }

  Future<void> renameItem(String newName) async {
    setState(() {
      _noteName = newName;
    });
  }

  int getFolderIdByName(String folderName) {
    return folderList.firstWhere(
        (folder) => folder['folder_name'] == folderName,
        orElse: () => {'id': -1})['id'];
  }

  void showQuickMenu(
      BuildContext context,
      Future<void> Function() fetchOtherFolders,
      List<Map<String, dynamic>> folders,
      Function(String) selectFolder) async {
    print('Attempting to fetch other folders.');
    await fetchOtherFolders();
    print('Updating folders with selection state.');

    // updatedFolders는 fetchOtherFolders 호출 후 업데이트된 folderList를 사용합니다.
    var updatedFolders = folderList.map((folder) {
      bool isSelected = folder['folder_name'] == _selectedFolder;
      return {
        ...folder,
        'selected': isSelected,
      };
    }).toList();

    print('Updated folders: $updatedFolders');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Color.fromRGBO(84, 84, 84, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        '다음으로 이동',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final selectedFolder = updatedFolders.firstWhere(
                              (folder) => folder['selected'] == true,
                              orElse: () => {});
                          if (selectedFolder.isNotEmpty) {
                            selectFolder(selectedFolder['folder_name']);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '이동',
                          style: TextStyle(
                            color: Color.fromRGBO(255, 161, 122, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Center(
                    child: Text(
                      '다른 폴더로 이동할 수 있어요.',
                      style: TextStyle(
                        color: Color(0xFF575757),
                        fontSize: 13,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: updatedFolders.map((folder) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: CustomRadioButton2(
                          label: folder['folder_name'],
                          isSelected: folder['selected'] ?? false,
                          onChanged: (bool isSelected) {
                            setState(() {
                              for (var f in updatedFolders) {
                                f['selected'] = false;
                              }
                              folder['selected'] = isSelected;
                            });
                            print('Folder selected: ${folder['folder_name']}');
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showRenameDialog2(
  BuildContext context,
  String currentName,
  Future<void> Function(String) renameItem,
  void Function(VoidCallback) setState,
  String title,
  String fieldName,
) {
  final TextEditingController textController = TextEditingController();
  textController.text = currentName;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF545454),
            fontSize: 14,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: "새로운 노트",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: TextStyle(color: Color(0xFF545454)),  // 입력할 때 글자 색상 지정
          onTap: () {
            if (textController.text == currentName) {
              textController.clear();
            }
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('취소', style: TextStyle(color: Color(0xFFFFA17A))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('저장', style: TextStyle(color: Color(0xFF545454))),
            onPressed: () async {
              String newName = textController.text;
              await renameItem(newName);
              setState(() {
                _noteName = newName;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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
            .child('uploads/${userProvider.user!.userKey}/${getFolderIdByName(_selectedFolder)}/$lecturefileId/show_handle/${fileName}_${id}');
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
          FirebaseStorage.instance.ref().child('uploads/$userKey/${getFolderIdByName(_selectedFolder)}/$lecturefileId/pdf_handle/page_$i.jpg');
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
      3. 가능한 한 명확하고 간결하게 작성해 주세요. 문단 구분은 [n 페이지 설명 시작], [n 페이지 설명 끝]을 구분할 때를 제외하고 최대한 넣지 말아주세요.
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
//데베에 폴더id,파일이름을 삽입하는 함수 
  Future<int> saveLectureFile({required int folderId, required String noteName}) async {
    final response = await http.post(
        Uri.parse('${API.baseUrl}/api/lecture-files'),
        headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
            'folder_id': folderId,
            'file_name': noteName,
        }),
    );

    if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['id'];
    } else {
        throw Exception('Failed to save lecture file');
    }
}
// 데베 업데이트 file URL,lecture name,type 
Future<void> updateLectureDetails(int lecturefileId, String fileUrl, String lectureName, int type) async {
  final response = await http.post(
    Uri.parse('${API.baseUrl}/api/update-lecture-details'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'lecturefileId': lecturefileId,
      'file_url': fileUrl,
      'lecture_name': lectureName,
      'type': type,
    }),
  );

  if (response.statusCode == 200) {
    print('Lecture details updated successfully');
  } else {
    throw Exception('Failed to update lecture details');
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    int currentFolderId =
                        folderList.isNotEmpty ? folderList.first['id'] : 0;
                    // showQuickMenu 호출
                    showQuickMenu(
                      context,
                      () => fetchOtherFolders('lecture', currentFolderId),
                      folderList,
                      _selectFolder,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/folder_search.png'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '폴더 분류 > $_selectedFolder',
                          style: const TextStyle(
                            color: Color(0xFF575757),
                            fontSize: 12,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    showRenameDialog2(
                        context,
                        _noteName,
                        renameItem,
                        setState,
                        "파일 이름 바꾸기", // 다이얼로그 제목
                        "file_name" // 변경할 항목 타입
                        );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/text.png'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _noteName,
                          style: const TextStyle(
                            color: Color(0xFF575757),
                            fontSize: 12,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
  child: ClickButton(
    text: _isMaterialEmbedded ? '강의 자료 학습 시작하기' : '강의 자료를 임베드하세요',
    onPressed: () async {
      if (!_isMaterialEmbedded) {
        print("Starting file upload");
        try {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          // API 호출
          lecturefileId = await saveLectureFile(
            folderId: getFolderIdByName(_selectedFolder),
            noteName: _noteName, //노트이름
          );
          print("Lecture file saved with ID: $lecturefileId");
          await _pickFile(); // 파일 선택 후 업로드

          setState(() {
            _isMaterialEmbedded = true;
          });
        } catch (e) {
          print('Error: $e');
        }
      } else {
        print("Starting learning with file: $_selectedFileName");
        print("대체텍스트 선택 여부: $isAlternativeTextEnabled");
        print("실시간자막 선택 여부: $isRealTimeSttEnabled");
        if (_selectedFileName != null && _downloadURL != null && _isMaterialEmbedded) {
          showLearningDialog(context, _selectedFileName!, _downloadURL!, _progressNotifier);
          try {
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            int type = isAlternativeTextEnabled ? 0 : 1; // 대체면 0, 실시간이면 1
            //데베에 fileUrl, lecturename, type
            print(lecturefileId!);
            print(type);
            await updateLectureDetails(lecturefileId!, _downloadURL!, _selectedFileName!, type);
            if (_isPDF && _fileBytes != null) {
              handlePdfUpload(_fileBytes!, userProvider.user!.userKey).then((imageUrls) async {
                final responseUrl = await callChatGPT4API(
                  imageUrls,
                  isAlternativeTextEnabled,
                  isRealTimeSttEnabled,
                  userProvider.user!.userKey,
                  _selectedFileName!
                );
                print("GPT-4 Response: $responseUrl");
                if (Navigator.canPop(context)) {
                  Navigator.of(context, rootNavigator: true).pop();
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LectureStartPage(
                      lectureName: _selectedFileName!,
                      fileURL: _downloadURL!,
                      responseUrl: responseUrl ?? '', // null일 경우 빈 문자열 전달
                      type: type, // 대체인지 실시간인지 전달해줌
                      lecturefileId: lecturefileId!, // Inserted ID 전달
                    ),
                  ),
                );
              });
            } else {
              final response = await callChatGPT4API(
                [_downloadURL!],
                isAlternativeTextEnabled,
                isRealTimeSttEnabled,
                userProvider.user!.userKey,
                _selectedFileName!
              );
              print("GPT-4 Response: $response");
              if (Navigator.canPop(context)) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LectureStartPage(
                    lectureName: _selectedFileName!,
                    fileURL: _downloadURL!,
                    responseUrl: response,// 실시간 자막일 때는 그냥 response 전달하고 안쓰면됨
                    type: type,
                    lecturefileId: lecturefileId!, // Inserted ID 전달
                    selectedFolder: _selectedFolder,
                    noteName: _noteName,
                  ),
                ),
              );
            }
          } catch (e) {
            if (Navigator.canPop(context)) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            print('Error: $e');
          }
        } else {
          print('Error: File name, URL, or embedded material is missing.');
        }
      }
    },
    width: MediaQuery.of(context).size.width * 0.7,
    height: 50.0,
    iconPath: _isIconVisible ? 'assets/Vector.png' : null,
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
