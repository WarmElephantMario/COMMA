# 수정 및 변경 사항
*- dis_type : 0(시각장애인용, 대체텍스트 생성) / 1(청각장애인용, 실시간자막 생성)*<br>
*- GPT API KEY는 최신 키로 바꿔서 사용하세요*<br>
*- api/api.dart 는 서버 업데이트 되면 바꿔서 사용, 현재는 로컬*<br>


<br><br>

## 사용자 타입 관련 수정
**/lib**<br>
- main.dart : 코드 밑에 있던 SplashScreen 삭제
- 1_SplashScreen : 유저 아이디 유무에 따라 main/onboarding 페이지로 이동하는 코드 수정
- 10_typeselect(추가) :<br>
    대체텍스트 선택 --> db, provider, sharedpreferences 에 0 추가<br>
    실시간자막 선택 --> db, provider, sharedpreferences 에 1 추가<br>
- 60prepare : 대체텍스트/실시간생성 버튼 삭제, 사용자 타입에 따라 제목 변경, 사용자 타입에 따라 이후 화면 갈림
<br>

**/lib/model**<br>
- user : dis_type 추가
- user_provider : dis_type, 관련 메서드 추가
<br>

**흐름**
1. 로고화면에서 유저키 확인<br>
2-1. 없는 경우 온보딩 화면으로 --> 온보딩화면에서 '바로 시작하기' 버튼 누르면 유저 생성 --> 타입 선택 화면 --> 메인 화면<br>
2-2. 있는 경우 메인 화면으로
<br>


**SERVER**
- index.js : 사용자 학습 유형(장애 타입) 업데이트 코드 추가
<br>
<br>

