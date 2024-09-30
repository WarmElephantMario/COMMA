| 요구사항 ID | 요구사항명 | 기능 ID | 기능명 | 상세설명 | 필수 데이터 | 선택 데이터 | 데이터베이스(테이블명:필드명) |
|-------------|-------------|----------|-----------|-----------|---------------|--------------|-----------------------------------|
| USER | 사용자 정보 | USER01-MODE01 | 사용자 모드 선택 | 사용자가 시각장애인, 청각장애인 모드를 선택할 수 있는 기능 | 1. 시각장애인 & 청각장애인 유형 선택 | | 1. user_table : dis_type(INT) |
| | | USER01-MODE02 | 사용자 모드 변경 | 사용자가 시각장애인, 청각장애인 모드를 변경할 수 있는 기능 | 1. 시각장애인 & 청각장애인 유형 선택 | | 1. user_table : dis_type(INT) |
| | | USER02-NAME01 | 닉네임 변경하기 | 기본 이름에서 사용자가 원하는 이름으로 변경하는 기능 | | 1. 닉네임 | 1. user_table : user_nickname(VARCHAR) |
| | | USER03-DROP01 | 회원탈퇴 | 사용자가 회원 계정을 삭제할 수 있는 기능 | | | 1. user_table : userKey(BIGINT) |
| FOLDER | 폴더 수정 | FOLDER01-ADD01 | 강의폴더 추가 | 새로운 강의폴더를 생성하는 기능 | | 1. 강의폴더 이름 | 1. LectureFolders : folder_name(VARCHAR) |
| | | FOLDER01-DROP01 | 강의폴더 삭제 | 선택한 강의폴더를 삭제하는 기능 | | | 1. LectureFolders : id (INT) |
| | | FOLDER01-NAME01 | 강의폴더 이름 변경 | 선택한 강의폴더의 이름을 사용자가 원하는 이름으로 변경하는 기능 | 1. 새 강의폴더 이름 | | 1. LectureFolders : folder_name(VARCHAR) |
| | | FOLDER02-ADD01 | 콜론폴더 추가 | 새로운 콜론폴더를 생성하는 기능 | | 1. 강의폴더 이름 | 1. ColonFolders : folder_name (VARCHAR) |
| | | FOLDER02-DROP01 | 콜론폴더 삭제 | 선택한 콜론폴더를 삭제하는 기능 | | | 1. ColonFolders : id (INT) |
| | | FOLDER02-NAME01 | 콜론폴더 이름 변경 | 선택한 콜론폴더의 이름을 사용자가 원하는 이름으로 변경하는 기능 | 1. 새 강의폴더 이름 | | 1. LectureFiles : lecture_name (VARCHAR) |
| FILE | 파일 수정 | FILE01-DROP01 | 강의파일 삭제 | 선택한 강의파일을 삭제하는 기능 | | | 1. LectureFiles : id (INT) |
| | | FILE01-MOVE01 | 강의파일 이동 | 선택한 강의파일을 다른 폴더로 이동하는 기능 | 1. 이동 강의폴더 선택 | | 1. LectureFiles : folder_id (INT) |
| | | FILE01-NAME01 | 강의 파일 이름 변경 | 선택한 강의파일의 이름을 사용자가 원하는 이름으로 변경하는 기능 | 1. 새 강의파일 이름 | | 1. LectureFiles : lecture_name (VARCHAR) |
| | | FILE02-DROP01 | 콜론파일 삭제 | 선택한 콜론파일을 삭제하는 기능 | | | 1. ColonFIles : id (INT) |
| | | FILE02-MOVE01 | 콜론파일 이동 | 선택한 콜론파일을 다른 폴더로 이동하는 기능 | 1. 이동 콜론폴더 선택 | | 1. ColonFIles : folder_id (INT) |
| | | FILE02-NAME01 | 콜론파일 이름 변경 | 선택한 콜론파일의 이름을 사용자가 원하는 이름으로 변경하는 기능 | 1. 새 콜론파일 이름 | | 1. ColonFIles : file_name (VARCHAR) |
| BLIND | 대체텍스트 | BLIND01 | 대체텍스트 생성 | 강의자료학습하기 버튼 클릭시 OPEN AI를 통해 대체텍스트를 생성하는 기능 | 1. 강의자료 | 2. 강의폴더 이름 | 1. LectureFiles : file_url (VARCHAR) <br>2. LectureFolders : folder_name(VARCHAR) <br>3. LectureFiles : lecture_name (VARCHAR) |
| | | BLIND02-LOAD01 | 대체텍스트 로드 | DB에 저장된 대체텍스트를 로드하는 기능 | 1. 강의자료 | 2. 강의폴더 이름 | 1. LectureFiles : file_url (VARCHAR)<br> 2. Alt_table : alternative_text_url (VARCHAR)<br> 3. LectureFolders : folder_name(VARCHAR)<br> 4. LectureFiles : lecture_name (VARCHAR) |
| DEAF | 실시간자막 | DEAF01-KEY01 | 키워드 추출 | 강의자료학습하기 버튼 클릭시 OPEN AI를 통해 키워드를 추출하는 기능 | 1. 강의자료 | | 1. LectureFiles : file_url (VARCHAR)<br> 2. Keywords_table : keywords_url (VARCHAR) |
| | | DEAF02-LOAD01 | 실시간자막 로드 | 녹음 버튼 클릭 시 deepgram api를 통해 자막을 출력하는 기능 | 1. 강의자료 | 3. 폴더 이름 | 1. LectureFiles : file_url (VARCHAR)<br> 2. Keywords_table : keywords_url (VARCHAR)<br> 3. LectureFolders : folder_name(VARCHAR)<br> 4. LectureFiles : lecture_name (VARCHAR) |
| ACC | 도움말 | ACC01-HELP01 | 도움말 | 애플리케이션 사용 방법에 대한 도움말을 제공하는 기능 | | | |
| | 글씨크기조정 | ACC02-FONT01 | 글씨크기조정 | 사용자가 화면에 표시되는 텍스트의 크기를 조절할 수 있는 기능 | 1. 크기 조절 옵션(3가지) 선택 | | |
