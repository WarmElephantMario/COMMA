<table>
 <thead>
    <tr>
      <th style="width:10%;">요구사항 ID</th>
      <th style="width:15%;">요구사항명</th>
      <th style="width:10%;">기능 ID</th>
      <th style="width:15%;">기능명</th>
      <th style="width:30%;">상세설명</th>
      <th style="width:10%;">필수 데이터</th>
      <th style="width:10%;">선택 데이터</th>
      <th style="width:30%;">데이터베이스(테이블명:필드명)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>USER</td>
      <td>사용자 정보</td>
      <td>USER01-MODE01</td>
      <td>사용자 모드 선택</td>
      <td>사용자가 시각장애인, 청각장애인 모드를 선택할 수 있는 기능</td>
      <td>1. 시각장애인 & 청각장애인 유형 선택</td>
      <td></td>
      <td>user_table : dis_type(INT)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>USER01-MODE02</td>
      <td>사용자 모드 변경</td>
      <td>사용자가 시각장애인, 청각장애인 모드를 변경할 수 있는 기능</td>
      <td>1. 시각장애인 & 청각장애인 유형 선택</td>
      <td></td>
      <td>user_table : dis_type(INT)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>USER02-NAME01</td>
      <td>닉네임 변경하기</td>
      <td>기본 이름에서 사용자가 원하는 이름으로 변경하는 기능</td>
      <td></td>
      <td>1. 닉네임</td>
      <td>user_table : user_nickname(VARCHAR)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>USER03-DROP01</td>
      <td>회원탈퇴</td>
      <td>사용자가 회원 계정을 삭제할 수 있는 기능</td>
      <td></td>
      <td></td>
      <td>user_table : userKey(BIGINT)</td>
    </tr>
    <tr>
      <td>FOLDER</td>
      <td>폴더 수정</td>
      <td>FOLDER01-ADD01</td>
      <td>강의폴더 추가</td>
      <td>새로운 강의폴더를 생성하는 기능</td>
      <td></td>
      <td>1. 강의폴더 이름</td>
      <td>LectureFolders : folder_name(VARCHAR)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>FOLDER01-DROP01</td>
      <td>강의폴더 삭제</td>
      <td>선택한 강의폴더를 삭제하는 기능</td>
      <td></td>
      <td></td>
      <td>LectureFolders : id (INT)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>FOLDER01-NAME01</td>
      <td>강의폴더 이름 변경</td>
      <td>선택한 강의폴더의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td>1. 새 강의폴더 이름</td>
      <td></td>
      <td>LectureFolders : folder_name(VARCHAR)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>FOLDER02-ADD01</td>
      <td>콜론폴더 추가</td>
      <td>새로운 콜론폴더를 생성하는 기능</td>
      <td></td>
      <td>1. 강의폴더 이름</td>
      <td>ColonFolders : folder_name (VARCHAR)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>FOLDER02-DROP01</td>
      <td>콜론폴더 삭제</td>
      <td>선택한 콜론폴더를 삭제하는 기능</td>
      <td></td>
      <td></td>
      <td>ColonFolders : id (INT)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>FOLDER02-NAME01</td>
      <td>콜론폴더 이름 변경</td>
      <td>선택한 콜론폴더의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td>1. 새 강의폴더 이름</td>
      <td></td>
      <td>LectureFiles : lecture_name (VARCHAR)</td>
    </tr>
    <tr>
      <td>FILE</td>
      <td>파일 수정</td>
      <td>FILE01-DROP01</td>
      <td>강의파일 삭제</td>
      <td>선택한 강의파일을 삭제하는 기능</td>
      <td></td>
      <td></td>
      <td>LectureFiles : id (INT)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>FILE01-MOVE01</td>
      <td>강의파일 이동</td>
      <td>선택한 강의파일을 다른 폴더로 이동하는 기능</td>
      <td>1. 이동 강의폴더 선택</td>
      <td></td>
      <td>LectureFiles : folder_id (INT)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>FILE01-NAME01</td>
      <td>강의 파일 이름 변경</td>
      <td>선택한 강의파일의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td>1. 새 강의파일 이름</td>
      <td></td>
      <td>LectureFiles : lecture_name (VARCHAR)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>FILE02-DROP01</td>
      <td>콜론파일 삭제</td>
      <td>선택한 콜론파일을 삭제하는 기능</td>
      <td></td>
      <td></td>
      <td>ColonFiles : id (INT)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>FILE02-MOVE01</td>
      <td>콜론파일 이동</td>
      <td>선택한 콜론파일을 다른 폴더로 이동하는 기능</td>
      <td>1. 이동 콜론폴더 선택</td>
      <td></td>
      <td>ColonFiles : folder_id (INT)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>FILE02-NAME01</td>
      <td>콜론파일 이름 변경</td>
      <td>선택한 콜론파일의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td>1. 새 콜론파일 이름</td>
      <td></td>
      <td>ColonFiles : file_name (VARCHAR)</td>
    </tr>
    <tr>
      <td>BLIND</td>
      <td>대체텍스트</td>
      <td>BLIND01</td>
      <td>대체텍스트 생성</td>
      <td>강의자료학습하기 버튼 클릭 시 OPEN AI를 통해 대체텍스트를 생성하는 기능</td>
      <td>1. 강의자료</td>
      <td>2. 강의폴더 이름</td>
      <td>LectureFiles : file_url (VARCHAR),<br>LectureFolders : folder_name (VARCHAR),<br>LectureFiles : lecture_name (VARCHAR)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>BLIND02-LOAD01</td>
      <td>대체텍스트 로드</td>
      <td>DB에 저장된 대체텍스트를 로드하는 기능</td>
      <td>1. 강의자료</td>
      <td>2. 강의폴더 이름</td>
      <td>LectureFiles : file_url (VARCHAR),<br>Alt_table : alternative_text_url (VARCHAR),<br>LectureFolders : folder_name (VARCHAR),<br>LectureFiles : lecture_name (VARCHAR)</td>
    </tr>
    <tr>
      <td>DEAF</td>
      <td>실시간자막</td>
      <td>DEAF01-KEY01</td>
      <td>키워드 추출</td>
      <td>강의자료학습하기 버튼 클릭 시 OPEN AI를 통해 키워드를 추출하는 기능</td>
      <td>1. 강의자료</td>
      <td></td>
      <td>LectureFiles : file_url (VARCHAR),<br>Keywords_table : keywords_url (VARCHAR)</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>DEAF02-LOAD01</td>
      <td>실시간자막 로드</td>
      <td>녹음 버튼 클릭 시 deepgram api를 통해 자막을 출력하는 기능</td>
      <td>1. 강의자료</td>
      <td>3. 폴더 이름</td>
      <td>LectureFiles : file_url (VARCHAR),<br>Keywords_table : keywords_url (VARCHAR),<br>LectureFolders : folder_name (VARCHAR),<br>LectureFiles : lecture_name (VARCHAR)</td>
    </tr>
    <tr>
      <td>ACC</td>
      <td>도움말</td>
      <td>ACC01-HELP01</td>
      <td>도움말</td>
      <td>애플리케이션 사용 방법에 대한 도움말을 제공하는 기능</td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>글씨크기조정</td>
      <td>ACC02-FONT01</td>
      <td>글씨크기조정</td>
      <td>사용자가 화면에 표시되는 텍스트의 크기를 조절할 수 있는 기능</td>
      <td>1. 크기 조절 옵션(3가지) 선택</td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>
