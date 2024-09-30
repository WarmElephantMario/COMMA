<!-- Template for PROJECT REPORT of CapstoneDesign 2024-2H, initially written by khyoo -->
<!-- 본 파일은 2024년도 컴공 졸업프로젝트의 <1차보고서> 작성을 위한 기본 양식입니다. -->
<!-- 아래에 "*"..."*" 표시는 italic체로 출력하기 위해서 사용한 것입니다. -->
<!-- "내용"에 해당하는 부분을 지우고, 여러분 과제의 내용을 작성해 주세요. -->

# Team-Info
| (1) 과제명 | **COMMA : 시·청각장애 학습자를 위한 AI 기반 학습 보조 프로그램**
|:---  |---  |
| (2) 팀 번호 / 팀 이름 | 01-따뜻한 코끼리 마리오 |
| (3) 팀 구성원 | 양지원(2176211): 리더, AI <br> 최시원(2271061): 팀원,백엔드<br> 박예나(2271028): 팀원, 프론트엔드 	 |
| (4) 팀 지도교수 | 심재형 교수님 |
| (5) 팀 멘토 | 김기휘 / CTO / Fliption |
| (6) 과제 분류 | 산학과제 |
| (6) 과제 키워드 | STT, NLP, Vision, Gen AI  |
| (7) 과제 내용 요약 | COMMA는 **시각 · 청각장애 학습자**를 위해, 강의 자료를 학습하여 실시간 수업 시 맞춤형 도움을 제공하는 인공지능 학습 어플리케이션입니다. COMMA는 다음의 세 가지 주요 기능을 제공합니다.<br><br>1. (시각장애인) 수업 자료 pdf를 인식하여, 이에 자동으로 *대체텍스트를 생성합니다.<br>2. (청각장애인) 수업 자료 pdf를 인식하여, 당일 수업 자료와 연관된 단어의 인식률을 높인 실시간 자막 서비스를 지원합니다.<br>3. (공통) 수업 자료 ppt의 슬라이드 내용에 맞춰 강의 전사 파일을 분리한 복습 자료 ‘콜론’을 생성합니다.<br> |

<br>

# Project-Summary
| 항목 | 내용 |
|:---  |---  |
| (1) 문제 정의 |**[Target Customer]**<br>: 비장애인 도우미로부터 벗어나 **학습 자립**을 **시도**하는 **시·청각 장애 학습자**<br><br>**[주목한 Pain Point]**<br> **1. Pain Point 1 (시각 장애인)**<br> • 강의 보조 자료(pdf, ppt 등)를 활용하려면 사비를 들여 직접 대체자료를 제작해야 하고, 이마저도 제작에 소요되는 시간이 매우 길다.<br>• 강의 보조 자료(pdf, ppt 등)을 pdf 리더기 등을 활용해 음성으로 들으며 학습할 수 있으나, 도표나 그래프 등은 문자 인식 리더기로 인식이 불가능하다.<br><br>**2. Pain Point 2 (청각 장애인)**<br>• 실시간 STT 서비스를 활용할 수 있으나, 전공 수업의 전문적인 용어를 표기하는 데 정확도가 떨어진다.<br><br>**3. Pain Point 3 (시·청각 장애인 공통)**<br>• 신체적 한계에 따른 한정적인 공부 방식으로 복습에 비효율을 겪는다.<br>ex) 시각장애인 : 강의 녹음본을 처음부터 끝까지 돌려 들으며 공부<br>ex) 청각장애인 : 강의 보조 자료와 속기 자료를 일일이 대조하며 공부<br><br> |
| (2) 기존연구와의 비교 | **1. Pain Point 1와 관련된 유사사례 - 소리앨범**<br>: 업로드한 사진에 자동으로 대체텍스트를 생성해 주는 어플리케이션.<br>(1) 개별 .jpg 파일만 변환하며, .pdf 파일은 지원하지 않음.<br>(2) 학습용 자료가 아닌 일상적인 사진에 대해 특화되어, 문자 인식 기능의 정확도가 떨어짐.<br> ⇒ COMMA는 .pdf, .jpg 등 **더 다양한 형식**의 강의 자료를 변환할 수 있으며, 일상적인 설명보다 **더 전문적인 대체텍스트**를 생성함.<br><br>**2. Pain Point 2와 관련된 유사사례 - 네이버 클로바 노트**<br>: 녹음 파일을 텍스트 파일로 변환해 주는 서비스.<br>(1) 녹음이 완료된 파일을 사후적으로 변환하는 기능만 지원하며, 실시간 STT는 지원하지 않음.<br>(2) 생성되는 전사 파일의 정확도를 높이기 위해서는 사용자가 ‘연관 단어’를 일일이 등록해야 함.<br> ⇒ COMMA는 강의 자료로부터 **수업 연관 키워드**를 추출하여, **실시간 STT 기능** 제공 시 자동으로 **해당 키워드에 대한 인식 정확률**을 향상함.<br><br> |
| (3) 제안 내용 | **1. 시각장애인** : COMMA는 .pdf, .jpg 등 **더 다양한 형식**의 강의 자료를 변환할 수 있으며, 일상적인 설명보다 **더 전문적인 대체텍스트**를 생성할 수 있다.<br><br>**2. 청각장애인** : COMMA는 강의 자료에서 자주 사용된 **수업 연관 키워드**에 대해 인식 정확률이 향상된 **실시간 STT 기능**을 제공한다.<br><br>**3. 공통** : 수업 자료와 강의 전사 파일을 슬라이드별로 분리한 **‘콜론’** 파일을 생성한다. 이를 활용하여 장애인의 **학습 비효율을 완화**한다<br><br>즉, COMMA는 강의 자료를 인공지능에 학습시켜 제공하는 3가지 주기능으로 실시간 수업 환경에서 시각·청각 장애인 학습자가 효과적으로 학습할 수 있도록 보조한다.<br><br> |
| (4) 기대효과 및 의의 |**1. 장애인 학습자의 진정한 학습 자립** : 시각 및 청각 장애인 학습자들이 외부의 도움 없이 강의 자료를 활용할 수 있도록 돕는다.<br><br>**2. 기존의 서비스에 비해 정확도 향상** : OpenAI-4o 및 OCR 기술을 활용한 솔루션으로 기존의 장애인 지원 기술보다 정확하고 편리한 서비스를 제공한다.<br><br>**3. 학습 효율성 증대** :  OpenAI 기술을 활용한 솔루션으로 슬라이드별로 강의 전사 파일을 분리하여, 장애인 학생들의 효율적인 복습을 돕는다.<br><br> |
| (5) 주요 기능 리스트 |**1. 주기능 1 (시각 장애인)** : 수업 자료 이미지를 OpenAI-4o로 인식하여 이에 자동으로 대체텍스트를 생성한다.<br><br>**2. 주기능 2 (청각 장애인)** : 수업 자료 이미지를 OpenAI-4o로 인식하여, 수업 자료에서 자주 사용된 단어를 추출한다. Deepgram을 사용하여 수업 연관 단어의 정확도를 높인 실시간 자막 서비스(STT)를 지원한다.<br><br>**3. 주기능 3 (시·청각 장애인 공통)** : OpenAI-4o를 활용해 강의 전사 파일을 수업 자료의 각 슬라이드 내용에 맞춰 분리한 복습 자료 ‘콜론’을 생성한다.<br>|

<br>
 
<h1 id="Project-Design">Project-Design</h1>

| 항목 | 내용 |
|:---  |---  |
| (1) 요구사항 정의 |**(1) 기능별 상세 요구사항**<br>[요구사항 명세서로 이동하기](#요구사항-명세서)<br><br> **(2) E-R 다이어그램**<br> <img src="readme\comma erd.jpg" width="530" height="760" /><br><br> |
| (2) 전체 시스템 구성 | **SW 구조**<br><br> <img src="readme\SW구조.png" width="700" /><br> [크게보기](#sw-구조)<br><br> |
| (3) 진척도 및 검증내역 | **1. 대체텍스트 생성 기술 검증**<br>(1) 사용 기술 : OpenAI GPT-4-turbo 모델<br>- 사진 자료에 대한 대체텍스트 생성 및 화면 출력 검증<br>(2) 진척도 : 90 %<br>- GPT-4o 모델로 변경 후 기술 검증 완료<br>- 대체텍스트 생성 및 데이터베이스 저장 검증 완료<br>- 대체텍스트 앱 화면 출력 검증 완료<br>- 현재 작업 : 대체텍스트 길이 선택 기능(기본/자세하게) 구현 마무리 단계 <br><br> **2. 실시간 자막 생성 기술 검증**<br>(1) 사용 API : Google Speech-to-text API <br>- 실시간 자막 생성 및 화면 출력 검증<br>(2) 진척도 : 90 %<br>- Deepgram의 Speech-to-text API로 변경 후 기술 검증 완료<br>- 강의자료에서 핵심 키워드를 추출하여 키워드 부스팅 기능 개발 완료<br>- 키워드 부스팅을 포함한 실시간 자막 생성 및 출력 검증 완료<br>- 현재 작업 : 키워드 추출 프롬프팅 수정 마무리 단계 |
| (4) 기타 | COMMA는 시각장애인이 사용자임을 고려하여 모바일 애플리케이션 콘텐츠 접근성 지침 2.0과 W3C 웹 접근성 지침(WCAG)을 준수하였다.<br><br>**1. 폰트 크기 조절 기능**: 사용자가 폰트 크기를 1.0배, 1.5배, 1.7배로 자유롭게 조절할 수 있음<br>**2. 명도 대비 강화**: 시각장애인이 콘텐츠를 명확히 인식할 수 있도록 일반 텍스트는 4.5:1 이상의 명도 대비를, 큰 텍스트는 3:1 이상의 명도 대비를 유지함<br>**3. 대체텍스트\* 제공**: 시각장애인이 스크린리더\*를 통해 어플을 원활하게 사용할 수 있도록, 이미지 및 버튼 등의 비텍스트 콘텐츠에 대체텍스트를 제공함<br>**4. 초점 관리**: 스크린리더\* 사용시 모든 사용자 인터페이스 컴포넌트에 초점\*이 적용되며, 초점은 논리적인 순서로 이동하도록 설계함<br><br>\* 대체텍스트: 이미지나 비텍스트 콘텐츠를 설명하기 위한 텍스트로, 시각장애인을 위해 사용<br>\* 스크린리더: 시각장애인이 모바일 기기를 이용할 때, 화면의 내용을 음성으로 읽어주어 조작을 도와주는 기능<br>\* 초점: 화면에서 현재 선택된 컴포넌트를 화면 낭독 프로그램이 적절히 인식할 수 있도록 돕는 기능 |

<br>


# 요구사항 명세서

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
      <td class="col5">사용자가 시각장애인,청각장애인 모드를 선택할 수 있는 기능</td>
      <td class="col6">1. 시각장애인 & 청각장애인 유형 선택</td>
      <td class="col7"></td>
      <td class="col8">1. user_table : dis_type</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">USER01-MODE02</td>
      <td class="col4">사용자 모드 변경</td>
      <td class="col5">사용자가 시각장애인, 청각장애인 모드를 변경할 수 있는 기능</td>
      <td class="col6">1. 시각장애인 & 청각장애인 유형 선택</td>
      <td class="col7"></td>
      <td class="col8">1. user_table : dis_type</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">USER02-NAME01</td>
      <td class="col4">닉네임 변경하기</td>
      <td class="col5">기본 이름에서 사용자가 원하는 이름으로 변경하는 기능</td>
      <td class="col6"></td>
      <td class="col7">1. 닉네임</td>
      <td class="col8">1. user_table : user_nickname</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">USER03-DROP01</td>
      <td class="col4">회원탈퇴</td>
      <td class="col5">사용자가 회원 계정을 삭제할 수 있는 기능</td>
      <td class="col6"></td>
      <td class="col7"></td>
      <td class="col8">1. user_table : userKey</td>
    </tr>
    <tr>
      <td class="col1">FOLDER</td>
      <td class="col2">폴더 수정</td>
      <td class="col3">FOLDER01-ADD01</td>
      <td class="col4">강의폴더 추가</td>
      <td class="col5">새로운 강의폴더를 생성하는 기능</td>
      <td class="col6"></td>
      <td class="col7">1. 강의폴더 이름</td>
      <td class="col8">1. LectureFolders : folder_name</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FOLDER01-DROP01</td>
      <td class="col4">강의폴더 삭제</td>
      <td class="col5">선택한 강의폴더를 삭제하는 기능</td>
      <td class="col6"></td>
      <td class="col7"></td>
      <td class="col8">1. LectureFolders : id</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FOLDER01-NAME01</td>
      <td class="col4">강의폴더 이름 변경</td>
      <td class="col5">선택한 강의폴더의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td class="col6">1. 새 강의폴더 이름</td>
      <td class="col7"></td>
      <td class="col8">1. LectureFolders : folder_name</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FOLDER02-ADD01</td>
      <td class="col4">콜론폴더 추가</td>
      <td class="col5">새로운 콜론폴더를 생성하는 기능</td>
      <td class="col6"></td>
      <td class="col7">1. 강의폴더 이름</td>
      <td class="col8">1. ColonFolders : folder_name</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FOLDER02-DROP01</td>
      <td class="col4">콜론폴더 삭제</td>
      <td class="col5">선택한 콜론폴더를 삭제하는 기능</td>
      <td class="col6"></td>
      <td class="col7"></td>
      <td class="col8">1. ColonFolders : id</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FOLDER02-NAME01</td>
      <td class="col4">콜론폴더 이름 변경</td>
      <td class="col5">선택한 콜론폴더의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td class="col6">1. 새 강의폴더 이름</td>
      <td class="col7"></td>
      <td class="col8">1. LectureFiles : lecture_name</td>
    </tr>
    <tr>
      <td class="col1">FILE</td>
      <td class="col2">파일 수정</td>
      <td class="col3">FILE01-DROP01</td>
      <td class="col4">강의파일 삭제</td>
      <td class="col5">선택한 강의파일을 삭제하는 기능</td>
      <td class="col6"></td>
      <td class="col7"></td>
      <td class="col8">1. LectureFiles : id</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FILE01-MOVE01</td>
      <td class="col4">강의파일 이동</td>
      <td class="col5">선택한 강의파일을 다른 폴더로 이동하는 기능</td>
      <td class="col6">1. 이동 강의폴더 선택</td>
      <td class="col7"></td>
      <td class="col8">1. LectureFiles : folder_id</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FILE01-NAME01</td>
      <td class="col4">강의 파일 이름 변경</td>
      <td class="col5">선택한 강의파일의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td class="col6">1. 새 강의파일 이름</td>
      <td class="col7"></td>
      <td class="col8">1. LectureFiles : lecture_name</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FILE02-DROP01</td>
      <td class="col4">콜론파일 삭제</td>
      <td class="col5">선택한 콜론파일을 삭제하는 기능</td>
      <td class="col6"></td>
      <td class="col7"></td>
      <td class="col8">1. ColonFiles : id</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FILE02-MOVE01</td>
      <td class="col4">콜론파일 이동</td>
      <td class="col5">선택한 콜론파일을 다른 폴더로 이동하는 기능</td>
      <td class="col6">1. 이동 콜론폴더 선택</td>
      <td class="col7"></td>
      <td class="col8">1. ColonFiles : folder_id</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">FILE02-NAME01</td>
      <td class="col4">콜론파일 이름 변경</td>
      <td class="col5">선택한 콜론파일의 이름을 사용자가 원하는 이름으로 변경하는 기능</td>
      <td class="col6">1. 새 콜론파일 이름</td>
      <td class="col7"></td>
      <td class="col8">1. ColonFiles : file_name</td>
    </tr>
    <tr>
      <td class="col1">BLIND</td>
      <td class="col2">대체텍스트</td>
      <td class="col3">BLIND01</td>
      <td class="col4">대체텍스트 생성</td>
      <td class="col5">강의자료학습하기 버튼 클릭 시 OPEN AI를 통해 대체텍스트를 생성하는 기능</td>
      <td class="col6">1. 강의자료</td>
      <td class="col7">2. 강의폴더 이름</td>
      <td class="col8">1. LectureFiles : file_url<br>2. LectureFolders : folder_name<br>3. LectureFiles : lecture_name</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">BLIND02-LOAD01</td>
      <td class="col4">대체텍스트 로드</td>
      <td class="col5">DB에 저장된 대체텍스트를 로드하는 기능</td>
      <td class="col6">1. 강의자료</td>
      <td class="col7">2. 강의폴더 이름</td>
      <td class="col8">1. LectureFiles : file_url<br>2. Alt_table : alternative_text_url<br>3. LectureFolders : folder_name<br>4. LectureFiles : lecture_name</td>
    </tr>
    <tr>
      <td class="col1">DEAF</td>
      <td class="col2">실시간자막</td>
      <td class="col3">DEAF01-KEY01</td>
      <td class="col4">키워드 추출</td>
      <td class="col5">강의자료학습하기 버튼 클릭 시 OPEN AI를 통해 키워드를 추출하는 기능</td>
      <td class="col6">1. 강의자료</td>
      <td class="col7"></td>
      <td class="col8">1. LectureFiles : file_url<br>2. Keywords_table : keywords_url</td>
    </tr>
    <tr>
      <td class="col1"></td>
      <td class="col2"></td>
      <td class="col3">DEAF02-LOAD01</td>
      <td class="col4">실시간자막 로드</td>
      <td class="col5">녹음 버튼 클릭 시 deepgram api를 통해 자막을 출력하는 기능</td>
      <td class="col6">1. 강의자료</td>
      <td class="col7">3. 폴더 이름</td>
      <td class="col8">1. LectureFiles : file_url<br>2. Keywords_table : keywords_url<br>3. LectureFolders : folder_name<br>4. LectureFiles : lecture_name</td>
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



[돌아가기](#Project-Design)

# SW 구조
<img src="readme\SW구조.png" /><br>[돌아가기](#sw-구조)<br>
