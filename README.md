# 수정 및 변경 사항

### 1. 수정
- 메인페이지, 폴더페이지를 유저랑 연결시킴(로그인한 유저의 폴더와 파일만 뜸)<br>
- provider 패키지 새로 설치(전역 상태로 사용자 정보를 관리)<br>
- 회원가입하면 자동으로 강의폴더에는 '기본 폴더', 콜론폴더에는 '기본 폴더 (:)' 가 생성되도록 수정<br>
- 콜론폴더 새로 추가할 때 폴더명 뒤에 (:) 붙도록 수정<br><br>

**메인페이지**<br>
- 파일 전체보기 완료(디자인은 수정 필요)<br>
- 파일 생성시간 표시가 데이터베이스랑 똑같도록 변경<br><br>

**바뀐 데이터베이스 테이블 구조**<br>
```sql
CREATE TABLE User_Table(
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_email VARCHAR(255),
    user_phone VARCHAR(255),
    user_password VARCHAR(32) NOT NULL
);

CREATE TABLE LectureFolders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folder_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES User_Table(user_id) ON DELETE CASCADE
);

CREATE TABLE ColonFolders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folder_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES User_Table(user_id) ON DELETE CASCADE
);

CREATE TABLE LectureFiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folder_id INT,
    file_name VARCHAR(255),
    file_url VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (folder_id) REFERENCES LectureFolders(id) ON DELETE CASCADE
);

CREATE TABLE ColonFiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folder_id INT,
    file_name VARCHAR(255),
    file_url VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (folder_id) REFERENCES ColonFolders(id) ON DELETE CASCADE
);
```

### 2. TODO
- 유저 정보랑 마이페이지 연결 필요<br>
- 디자인 수정 필요(현재 실행시켰을 때 내 노트북에서는 네비게이션바는 검정색으로, 기본 글자는 흐린 회색으로 보임, 새로 만든 페이지도 디자인 수정 필요)<br>
- 로그인 후 뒤로가기 버튼을 누르면 다시 로그인창으로 돌아가버림 해결 필요할 듯