# 수정 및 변경 사항

- 자막 부분 deepgram STT API 사용으로 변경
- 자막 200자 이상되면 구두점에서 줄바꿈
- prepare에서 키워드 뽑아내기 → lecturestart → record 페이지로 키워드 전달 (this.keywords 추가)
- deepgram 쿼리로 키워드 전달
<br>
- deepgram flutter 관련 튜토리얼 : https://deepgram.com/learn/flutter-speech-to-text-tutorial
- 따코마 구글 계정으로 가입함(카드 등록 X, 200 달러 무료 사용 중, 약 500시간 정도)
- 이후 10달러부터 충전 가능
- 0.0059달러/분


<br>
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

//통 스크립트
CREATE TABLE Alt_table (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `lecturefile_id` INT,
  `colonfile_id` INT,
  `alternative_text_url` VARCHAR(2048),
  `page` INT,
  CONSTRAINT `fk_lecturefile` FOREIGN KEY (`lecturefile_id`) REFERENCES `LectureFiles` (`id`),
  CONSTRAINT `fk_colonfile` FOREIGN KEY (`colonfile_id`) REFERENCES `ColonFiles` (`id`)
);

//쪼개 스크립트
CREATE TABLE Alt_table2 (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `lecturefile_id` INT,
  `colonfile_id` INT,
  `alternative_text_url` VARCHAR(2048),
  `page` INT,
  CONSTRAINT `fk_lecturefile` FOREIGN KEY (`lecturefile_id`) REFERENCES `LectureFiles` (`id`),
  CONSTRAINT `fk_colonfile` FOREIGN KEY (`colonfile_id`) REFERENCES `ColonFiles` (`id`)
);


```
