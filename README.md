# 수정 및 변경 사항

- folder_search 이미지 안 뜨는 것 해결
- 학습 시작 페이지에서 '대체텍스트 생성', '실시간 자막 생성' 중 하나만 선택 가능하도록 수정
- CustomRadioButton 추가


**데이터베이스 테이블 구조**
***수정 필요***<br>

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
