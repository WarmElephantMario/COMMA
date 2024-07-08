# 수정 및 변경 사항

### 1. 주석처리
16_homepage_move.dart 화면 연결 수정<br>
- MainPage()->RecordPage() 수정 중<br>
- MainPage()->ColonPage() 수정 중<br><br>

### 2. 수정
- 37_folder_files_screen.dart 수정<br>
- components.dart 수정<br>
- index.js 수정 (서버)<br><br>
- 60prepare.dart 수정<br>
- 62lecture_start.dart 수정<br>
- 63record.dart 수정<br>
- 66colon.dart 수정<br>
- fire.base.json 

### 3.완료한 기능
내비게이션바 배경색 흰색<br><br>

학습시작 <br>
- 강의자료 업로드시 firebase storage에 업로드 <br>
- 오늘의 학습시작하기 폴더변경 & 노트 이름 변경 <br>
- 녹음 시작 화면 : 폴더이름 & 노트이름 & 강의자료(업로드한 파일 이름) 연동<br>
- 녹음 버튼 : 해당 강의 폴더에 파일 생성및 데베에 (file_name,file_url,lecture_name,created_at) 삽입<br>
- 녹음 종료 버튼 : created_at으로 생성된 시간 표시<br>
- 콜론 생성 버튼 : "강의 폴더(:)" 형태로 콜론 폴더와 파일생성 & 동일한 콜론폴더 존재시 해당 폴더에 콜론 파일 생성<br><br>

폴더<br>
- 해당 파일 선택시 이동<br><br>

### 4. TODO
- showquickmenu 체크박스2 디자인 수정<br>
- created_at 시간 포맷함수 수정<br>
- 16_homepage_move.dart 화면 연결 수정<br>

### 5. 데이터베이스 수정
강의자료(업로드한 파일이름)를 강의파일및 콜론파일에 표기해야해서 추가<br>
- LectureFiles의 lecture_name 추가 <br>
- ColonFiles의 lecture_name 추가 <br>

'''
CREATE TABLE LectureFolders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folder_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ColonFolders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folder_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
'''
