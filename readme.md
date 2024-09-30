<style>
  table {
    table-layout: fixed;
    width: 100%;
    border-collapse: collapse;
  }
  th, td {
    border: 1px solid black;
    padding: 8px;
    text-align: left;
  }
  th {
    background-color: #f2f2f2;
  }
  /* 열 별로 너비를 조정할 수 있습니다. */
  .col1 { width: 10%; }
  .col2 { width: 15%; }
  .col3 { width: 10%; }
  .col4 { width: 15%; }
  .col5 { width: 30%; }
  .col6 { width: 10%; }
  .col7 { width: 10%; }
  .col8 { width: 30%; }
</style>

<table>
  <thead>
    <tr>
      <th class="col1">요구사항 ID</th>
      <th class="col2">요구사항명</th>
      <th class="col3">기능 ID</th>
      <th class="col4">기능명</th>
      <th class="col5">상세설명</th>
      <th class="col6">필수 데이터</th>
      <th class="col7">선택 데이터</th>
      <th class="col8">데이터베이스(테이블명:필드명)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class="col1">USER</td>
      <td class="col2">사용자 정보</td>
      <td class="col3">USER01-MODE01</td>
      <td class="col4">사용자 모드 선택</td>
      <td class="col5">사용자가 시각장애인, 청각장애인 모드를 선택할 수 있는 기능</td>
      <td class="col6">1. 시각장애인 & 청각장애인 유형 선택</td>
      <td class="col7"></td>
      <td class="col8">user_table : dis_type(INT)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">USER01-MODE02</td>
      <td class="col4">사용자 모드 변경</td>
      <td class="col5">사용자가 시각장애인, 청각장애인 모드를 변경할 수 있는 기능</td>
      <td class="col6">1. 시각장애인 & 청각장애인 유형 선택</td>
      <td class="col7"></td>
      <td class="col8">user_table : dis_type(INT)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">USER02-NAME01</td>
      <td class="col4">닉네임 변경하기</td>
      <td class="col5">기본 이름에서 사용자가 원하는 이름으로 변경하는 기능</td>
      <td class="col6"></td>
      <td class="col7">1. 닉네임</td>
      <td class="col8">user_table : user_nickname(VARCHAR)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">USER03-DROP01</td>
      <td class="col4">회원탈퇴</td>
      <td class="col5">사용자가 회원 계정을 삭제할 수 있는 기능</td>
      <td class="col6"></td>
      <td class="col7"></td>
      <td class="col8">user_table : userKey(BIGINT)</td>
    </tr>
    <tr>
      <td class="col1">FOLDER</td>
      <td class="col2">폴더 수정</td>
      <td class="col3">FOLDER01-ADD01</td>
      <td class="col4">강의폴더 추가</td>
      <td class="col5">새로운 강의폴더를 생성하는 기능</td>
      <td class="col6"></td>
      <td class="col7">1. 강의폴더 이름</td>
      <td class="col8">LectureFolders : folder_name(VARCHAR)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FOLDER01-DROP01</td>
      <td class="col4">강의폴더 삭제</td>
      <td class="col5">선택한 강의폴더를 삭제하는 기능</td>
      <td class="col6"></td>
      <td class="col7"></td>
      <td class="col8">LectureFolders : id (INT)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FOLDER01-NAME01</td>
      <td class="col4">강의폴더 이름 변경</td>
      <td class="col5">선택한 강의폴더의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td class="col6">1. 새 강의폴더 이름</td>
      <td class="col7"></td>
      <td class="col8">LectureFolders : folder_name(VARCHAR)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FOLDER02-ADD01</td>
      <td class="col4">콜론폴더 추가</td>
      <td class="col5">새로운 콜론폴더를 생성하는 기능</td>
      <td class="col6"></td>
      <td class="col7">1. 강의폴더 이름</td>
      <td class="col8">ColonFolders : folder_name (VARCHAR)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FOLDER02-DROP01</td>
      <td class="col4">콜론폴더 삭제</td>
      <td class="col5">선택한 콜론폴더를 삭제하는 기능</td>
      <td class="col6"></td>
      <td class="col7"></td>
      <td class="col8">ColonFolders : id (INT)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FOLDER02-NAME01</td>
      <td class="col4">콜론폴더 이름 변경</td>
      <td class="col5">선택한 콜론폴더의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td class="col6">1. 새 강의폴더 이름</td>
      <td class="col7"></td>
      <td class="col8">LectureFiles : lecture_name (VARCHAR)</td>
    </tr>
    <tr>
      <td class="col1">FILE</td>
      <td class="col2">파일 수정</td>
      <td class="col3">FILE01-DROP01</td>
      <td class="col4">강의파일 삭제</td>
      <td class="col5">선택한 강의파일을 삭제하는 기능</td>
      <td class="col6"></td>
      <td class="col7"></td>
      <td class="col8">LectureFiles : id (INT)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FILE01-MOVE01</td>
      <td class="col4">강의파일 이동</td>
      <td class="col5">선택한 강의파일을 다른 폴더로 이동하는 기능</td>
      <td class="col6">1. 이동 강의폴더 선택</td>
      <td class="col7"></td>
      <td class="col8">LectureFiles : folder_id (INT)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FILE01-NAME01</td>
      <td class="col4">강의 파일 이름 변경</td>
      <td class="col5">선택한 강의파일의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td class="col6">1. 새 강의파일 이름</td>
      <td class="col7"></td>
      <td class="col8">LectureFiles : lecture_name (VARCHAR)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FILE02-DROP01</td>
      <td class="col4">콜론파일 삭제</td>
      <td class="col5">선택한 콜론파일을 삭제하는 기능</td>
      <td class="col6"></td>
      <td class="col7"></td>
      <td class="col8">ColonFiles : id (INT)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FILE02-MOVE01</td>
      <td class="col4">콜론파일 이동</td>
      <td class="col5">선택한 콜론파일을 다른 폴더로 이동하는 기능</td>
      <td class="col6">1. 이동 콜론폴더 선택</td>
      <td class="col7"></td>
      <td class="col8">ColonFiles : folder_id (INT)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FILE02-NAME01</td>
      <td class="col4">콜론파일 이름 변경</td>
      <td class="col5">선택한 콜론파일의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td class="col6">1. 새 콜론파일 이름</td>
      <td class="col7"></td>
      <td class="col8">ColonFiles : file_name (VARCHAR)</td>
    </tr>
    <tr>
      <td class="col1">BLIND</td>
      <td class="col2">대체텍스트</td>
      <td class="col3">BLIND01</td>
      <td class="col4">대체텍스트 생성</td>
      <td class="col5">강의자료학습하기 버튼 클릭 시 OPEN AI를 통해 대체텍스트를 생성하는 기능</td>
      <td class="col6">1. 강의자료</td>
      <td class="col7">2. 강의폴더 이름</td>
      <td class="col8">LectureFiles : file_url (VARCHAR),<br>LectureFolders : folder_name (VARCHAR),<br>LectureFiles : lecture_name (VARCHAR)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">BLIND02-LOAD01</td>
      <td class="col4">대체텍스트 로드</td>
      <td class="col5">DB에 저장된 대체텍스트를 로드하는 기능</td>
      <td class="col6">1. 강의자료</td>
      <td class="col7">2. 강의폴더 이름</td>
      <td class="col8">LectureFiles : file_url (VARCHAR),<br>Alt_table : alternative_text_url (VARCHAR),<br>LectureFolders : folder_name (VARCHAR),<br>LectureFiles : lecture_name (VARCHAR)</td>
    </tr>
    <tr>
      <td class="col1">DEAF</td>
      <td class="col2">실시간자막</td>
      <td class="col3">DEAF01-KEY01</td>
      <td class="col4">키워드 추출</td>
      <td class="col5">강의자료학습하기 버튼 클릭 시 OPEN AI를 통해 키워드를 추출하는 기능</td>
      <td class="col6">1. 강의자료</td>
      <td class="col7"></td>
      <td class="col8">LectureFiles : file_url (VARCHAR),<br>Keywords_table : keywords_url (VARCHAR)</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">DEAF02-LOAD01</td>
      <td class="col4">실시간자막 로드</td>
      <td class="col5">녹음 버튼 클릭 시 deepgram api를 통해 자막을 출력하는 기능</td>
      <td class="col6">1. 강의자료</td>
      <td class="col7">3. 폴더 이름</td>
      <td class="col8">LectureFiles : file_url (VARCHAR),<br>Keywords_table : keywords_url (VARCHAR),<br>LectureFolders : folder_name (VARCHAR),<br>LectureFiles : lecture_name (VARCHAR)</td>
    </tr>
    <tr>
      <td class="col1">ACC</td>
      <td class="col2">도움말</td>
      <td class="col3">ACC01-HELP01</td>
      <td class="col4">도움말</td>
      <td class="col5">애플리케이션 사용 방법에 대한 도움말을 제공하는 기능</td>
      <td class="col6"></td>
      <td class="col7"></td>
      <td class="col8"></td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2">글씨크기조정</td>
      <td class="col3">ACC02-FONT01</td>
      <td class="col4">글씨크기조정</td>
      <td class="col5">사용자가 화면에 표시되는 텍스트의 크기를 조절할 수 있는 기능</td>
      <td class="col6">1. 크기 조절 옵션(3가지) 선택</td>
      <td class="col7"></td>
      <td class="col8"></td>
    </tr>
  </tbody>
</table>
