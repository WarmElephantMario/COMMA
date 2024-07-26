# 수정 및 변경 사항

- debugflag -> false
- 메인페이지의 뒤로가기 아이콘 없앰 : 로그인 후 누르면 다시 로그인 전 화면으로 돌아가버리는 거 방지
<br><br>

## 스크린리더 관련 수정
**화면 수정**
- 첫 앱 로고 화면 : '앱 로고 COMMA' 대체텍스트 추가
- 온보딩 화면 : 이전 → 다음 → 바로시작하기 순서로 초점 순서 맞춤, 다음 버튼 선택 시 초점 초기화
- 회원가입 화면 : 화면설명 → 아이디/비밀번호/이메일 → 인증코드 전송하기 → 로그인 → 비밀번호 순서로 초점 순서 맞춤, 한글로 입력창 설명 바꿈
- 로그인 화면 : 한글로 입력창 설명 바꿈, login successfully → 로그인 성공 으로 변경
- 메인 화면 : 검색 버튼 대체텍스트 추가, 초점 초기화 설정, 이름 → 최근에학습한강의파일 → 전체보기 → 파일목록 순서로 설정
- 폴더 첫화면 : 초점 초기화 설정, 강의폴더(콜론폴더) → 추가하기 → 전체보기 → 폴더목록 순서로 설정.
- 학습 시작 첫화면 : 초점 초기화 설정, '저장할 폴더를 선택하세요'/'파일 이름을 설정하세요' 대체텍스트 추가
- 마이페이지 첫화면 : 초점 초기화 설정


<br>

**컴포넌트 수정**
- 네비게이션 바 : 다른 페이지로 이동해도 초점 초기화 되도록 변경
- 파일 메뉴 햄버거 버튼 : '파일 메뉴 버튼' 대체텍스트 추가
- 폴더 메뉴 햄버거 버튼 : '폴더 메뉴 버튼' 대체텍스트 추가

<br>

**TODO**
- 녹음 종료 다이얼로그 초점 설정 : 해봤는데 안돼서 수정 필요
- 마이페이지-프로필정보 초점 설정
- 마이페이지 속 세부 페이지 설정 필요
- 폴더 추가하기 다이얼로그

<br>

*초점 설정 했는데도 초기화 안되고 그런 오류 가끔 발생 중*

<br>


<br>

**deepgram 관련**
- deepgram flutter 관련 튜토리얼 : https://deepgram.com/learn/flutter-speech-to-text-tutorial
- 따코마 구글 계정으로 가입함(카드 등록 X, 현재 190 달러 무료 사용 중, 약 500시간 정도)
- 이후 10달러부터 충전 가능
- 0.0059달러/분


<br>

**데이터베이스 테이블 구조**

<br>

```sql
CREATE TABLE user_table (
  userKey INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(255) NOT NULL,
  user_email VARCHAR(255) NOT NULL UNIQUE,
  user_password VARCHAR(255) NOT NULL,
  user_nickname VARCHAR(50) NOT NULL DEFAULT 'Guest'
);


CREATE TABLE LectureFolders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folder_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    userKey INT,
    FOREIGN KEY (userKey) REFERENCES User_Table(userKey) ON DELETE CASCADE
);

CREATE TABLE ColonFolders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folder_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    userKey INT,
    FOREIGN KEY (userKey) REFERENCES User_Table(userKey) ON DELETE CASCADE
);

CREATE TABLE LectureFiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folder_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(2048),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    userKey INT,
    type int,
    existColon INT,
    FOREIGN KEY (userKey) REFERENCES User_Table(userKey) ON DELETE CASCADE,
    FOREIGN KEY (existColon) REFERENCES ColonFiles(id) ON DELETE CASCADE
);

CREATE TABLE ColonFiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    folder_id INT,
    file_name VARCHAR(255),
    file_url VARCHAR(2048),
    lecture_name VARCHAR(255),
    created_at DATETIME,
    type int
);

CREATE TABLE DividedScript_Table (
    colonfile_id INT PRIMARY KEY,
    page INT,
    url varchar(2048),
    FOREIGN KEY (colonfile_id) REFERENCES ColonFiles(id) ON DELETE CASCADE
);


```
