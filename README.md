# 수정 및 변경 사항

- 자막 부분 deepgram STT API 사용으로 변경
- deepgram flutter 관련 튜토리얼 : https://deepgram.com/learn/flutter-speech-to-text-tutorial
- 따코마 구글 계정으로 가입함(카드 등록 X, 200 달러 무료 사용 중, 약 500시간 정도)
- 이후 10달러부터 충전 가능
- 0.0059달러/분



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
