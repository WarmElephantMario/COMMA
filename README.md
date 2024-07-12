# 수정 및 변경 사항

- 폴더 이름바꾸기 기능 수정
- 전체적으로 글씨나 아이콘 흐리게 보이는 것들 등 디자인 수정 및 색상 통일<br><br>

**로그인 페이지**
- 앱 바 수정
- 자동로그인 체크박스 수정(CustomCheckBox로 변경)
- 키보드 올라왔을 때 bottomoverflow 에러 수정<br><br>

**검색 페이지**
- 앱 바 수정
- 검색 버튼 수정<br><br>

**학습시작 페이지**
- 체크박스 수정<br><br>

**마이페이지**
- 앱 바 수정
- 리스트 디자인 수정
- 프로필 페이지, 도움말 페이지, 비밀번호 확인/변경 페이지 앱 바 수정<br><br>

**폴더 페이지**
- 추가하기 창 색상 수정
- 폴더메인-전체보기 앱 바 수정<br><br>


**TODO**
- 디자인 더 수정 필요<br><br>

**데이터베이스 테이블 구조**<br>
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
    folder_id INT,
    file_name VARCHAR(255),
    file_url VARCHAR(2048),
    lecture_name VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (folder_id) REFERENCES LectureFolders(id) ON DELETE CASCADE
);

CREATE TABLE ColonFiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folder_id INT,
    file_name VARCHAR(255),
    file_url VARCHAR(2048),
    lecture_name VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (folder_id) REFERENCES ColonFolders(id) ON DELETE CASCADE
);

```
