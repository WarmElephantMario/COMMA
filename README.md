# 수정 및 변경 사항

### firebase 연동
- firebase 계정 : warmelephantmario@gmail.com<br>
- 강의자료 업로드시 firebase storage의 uploads 폴더에 저장<br>
- $ firebase login<br>
- 참고: 
  [https://velog.io/@qazws78941/Flutter-%ED%8C%8C%EC%9D%B4%EC%96%B4%EB%B2%A0%EC%9D%B4%EC%8A%A4-%EC%97%B0%EB%8F%99](https://velog.io/@qazws78941/Flutter-%ED%8C%8C%EC%9D%B4%EC%96%B4%EB%B2%A0%EC%9D%B4%EC%8A%A4-%EC%97%B0%EB%8F%99) <br><br>

### TODO
- 유저 정보랑 마이페이지 연결 필요<br>
- 디자인 수정 필요(현재 실행시켰을 때 기본 글자는 흐린 회색으로 보임, 새로 만든 페이지도 디자인 수정 필요)<br>
- 로그인 후 뒤로가기 버튼을 누르면 다시 로그인창으로 돌아가버림 해결 필요할 듯<br>
- showquickmenu 체크박스2 디자인 수정<br>
- created_at 시간 포맷함수 수정<br><br>

### 수정
- 학습시작 부분 유저 정보랑 연결시킴
- 콜론 폴더 새로 생성 시, 로그인한 유저의 user_id 함께 저장
- 강의자료 업로드 시, uploads/user_id 폴더에 저장되도록 수정
- 파일 불러오기 오류 수정
- 사용되지 않는 import 모두 삭제


**데이터베이스 테이블 구조**<br>
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


