import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart'; // semantics 패키지 추가
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'components.dart';
import 'model/user_provider.dart';
import 'api/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _profileFocusNode = FocusNode();
  final FocusNode _nicknameFocusNode = FocusNode();
  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String email = "-";
  String id = "-";
  String nickname = "-";
  File? _image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    nickname = userProvider.user?.user_nickname ?? "-";
    email = userProvider.user?.user_email ?? "-";
    id = userProvider.user?.user_id ?? "-";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _profileFocusNode.dispose();
    _nicknameFocusNode.dispose();
    _idFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _showEditNameDialog() {
    final TextEditingController nicknameController =
        TextEditingController(text: nickname);

    final FocusNode titleFocusNode = FocusNode();
    final FocusNode contentFocusNode = FocusNode();
    final FocusNode cancelFocusNode = FocusNode();
    final FocusNode saveFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Semantics(
            sortKey: OrdinalSortKey(1.0),
            child: Focus(
              focusNode: titleFocusNode,
              child: const Text('닉네임 바꾸기'),
            ),
          ),
          content: Semantics(
            sortKey: OrdinalSortKey(2.0),
            child: Focus(
              focusNode: contentFocusNode,
              child: TextField(
                controller: nicknameController,
                decoration: const InputDecoration(hintText: '새 닉네임을 입력하세요'),
              ),
            ),
          ),
          actions: <Widget>[
            Semantics(
              sortKey: OrdinalSortKey(3.0),
              child: Focus(
                focusNode: cancelFocusNode,
                child: TextButton(
                  child: const Text('취소', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Semantics(
              sortKey: OrdinalSortKey(4.0),
              child: Focus(
                focusNode: saveFocusNode,
                child: TextButton(
                  child: const Text('저장'),
                  onPressed: () async {
                    String newNickname = nicknameController.text;
                    await _updateNickname(newNickname);
                    setState(() {
                      nickname = newNickname;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(titleFocusNode);
    });
  }

  Future<void> _updateNickname(String newNickname) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey ?? 0;

    final response = await http.put(
      Uri.parse('${API.baseUrl}/api/update_nickname'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userKey': userKey,
        'user_nickname': newNickname,
      }),
    );

    print('Request body: ${jsonEncode({
          'userKey': userKey,
          'user_nickname': newNickname,
        })}');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        userProvider.updateUserNickname(newNickname);
        Fluttertoast.showToast(msg: '닉네임이 성공적으로 업데이트되었습니다.');
      } else {
        Fluttertoast.showToast(msg: '닉네임 업데이트 중 오류가 발생했습니다.');
      }
    } else {
      Fluttertoast.showToast(msg: '서버 오류: 닉네임 업데이트 실패');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Widget _buildProfileItem(String label, String value, VoidCallback? onTap,
      {required OrdinalSortKey order, required FocusNode focusNode}) {
    return Semantics(
      sortKey: order,
      child: Focus(
        focusNode: focusNode,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 수정된 부분
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    nickname = userProvider.user?.user_nickname ?? "-";
    email = userProvider.user?.user_email ?? "-";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '프로필 정보',
          style: TextStyle(
              color: Color.fromARGB(255, 48, 48, 48),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 48, 48, 48)),
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: Column(
                  children: [
                    Semantics(
                      sortKey: OrdinalSortKey(1.0),
                      child: Focus(
                        focusNode: _profileFocusNode,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : const AssetImage('assets/profile.jpg')
                                      as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileItem('닉네임', nickname, _showEditNameDialog,
                        order: OrdinalSortKey(2.0),
                        focusNode: _nicknameFocusNode),
                    _buildProfileItem('아이디', id, null,
                        order: OrdinalSortKey(3.0), focusNode: _idFocusNode),
                    _buildProfileItem('이메일', email, null,
                        order: OrdinalSortKey(4.0), focusNode: _emailFocusNode),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
