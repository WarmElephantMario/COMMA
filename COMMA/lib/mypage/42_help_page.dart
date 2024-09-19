import 'package:flutter/material.dart';
import 'package:flutter_plugin/components.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 48, 48, 48)),
        title: const Text(
          '도움말',
          style: TextStyle(
              color: Color.fromARGB(255, 48, 48, 48),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            '앱 사용 방법',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20.0),
          _buildHelpSection(
            title: 'COMMA란?',
            content:
                'COMMA는 시각 또는 청각장애를 가진 사용자를 위한 학습 보조 어플입니다. 실시간 대면 강의 환경에서 수업 내용과 연관된 강의 보조 자료가 주어지는 경우 본 어플을 유용하게 사용할 수 있습니다. ',
          ),
          _buildHelpSection(
            title: '기본 조작 방식 (시각 장애인용)',
            content:
                '1. 대면 수업에 참여하기 전, 당일 수업에서 사용될 강의 자료를 미리 어플에 업로드합니다.\n2. 대면 수업에 참여하기 전, 강의 자료에 생성된 대체텍스트를 미리 읽어보며 수업 자료를 활용할 수 있습니다.\n3. 수업이 시작되면 녹음 버튼을 눌러 수업 내용을 녹음합니다. 단, 이때는 사전에 교수자에게 녹음에 대한 허락을 받아야 합니다. \n4. 수업이 종료되면 콜론 생성하기 버튼을 눌러 강의 자료와 녹음 속기 파일이 연동된 복습 자료를 생성할 수 있습니다. ',
          ),
          _buildHelpSection(
            title: '기본 조작 방식 (청각 장애인용)',
            content:
                '1. 대면 수업에 참여하기 전, 당일 수업에서 사용될 강의 자료를 미리 어플에 업로드합니다.\n2. 대면 수업이 시작되면 녹음 버튼을 눌러 수업 내용을 녹음합니다. 단, 이때는 사전에 교수자에게 녹음에 대한 허락을 받아야 합니다. \n3. 수업이 종료되면 콜론 생성하기 버튼을 눌러 강의 자료와 녹음 속기 파일이 연동된 복습 자료를 생성할 수 있습니다. ',
          ),
          _buildHelpSection(
            title: '시각 장애인을 위한 부가 기능',
            content:
                '어플 내의 모든 버튼과 텍스트 설명은 스크린 리더와 높은 수준으로 호환됩니다. 또한, 설정에서 글자 크기 조정, 밝기 조절 및 고대비 모드 등을 설정할 수 있습니다. ',
          ),
          const SizedBox(height: 20.0),
          const Text(
            '데이터 수집 및 사용',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          const Text(
            '어플 사용 중 생성한 녹음 파일은 서버에 저장되지 않으며, 음성으로부터 텍스트를 추출한 직후 폐기됩니다.',
          ),

        ],
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }

  Widget _buildHelpSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
