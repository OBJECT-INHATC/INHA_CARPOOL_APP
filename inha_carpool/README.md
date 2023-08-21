# 파일 설명
1. common 
    1. colors -> 앱에서 사용할 색상들의 폴더 ( 미리 정의 된 색상을 재정의)
    2. data -> sharedPreferences 대체 코드를 포함한 폴더
    3. extension -> 내장 클래스에 확장 함수들을 구현해논 클래스들의 폴더 
    4. languagem, util -> json 파일을 통한 언어, 오픈소스 등의 파일 접근을 위한 폴더
    5. widget -> 잘 구현된 위젯 참고 소스 (개발 하는 동안 참고 후 삭제 예정)
    6. theme -> theme 관련 코드 ( 검토 예정)
    //★★★★★★★★★★★★★★★
       1. ★ abs_theme_colors  -> 앱에서 개발자가 위젯 색상을 정의해서 공통으로 사용할 색상 ★
          ★★/////////////
       
2. constants.dart -> static 으로 사용할 경로의 집합 폴더 
3. common.dart -> export를 활용한 임포트를 쉽게 하기 위한 클래스
------------- App 버전 추가 파일 설명 끝 ---------------- 
ㅂ★
4. fragment -> 프레그먼트의 집합 파일

5. screen -> 화면 스크린의 집합 파일
    1. dialog -> 다이알로그 위젯 집합
    2. login -> 로그인 관련 집함
    3. main 
       1. tab* -> 각 프레그먼트 별 코드 집합
       2. tab_item -> 하단 네비게이션 아이템 집합
       3. tab_navigator -> ""

     4. opensource -> 오픈 소스 관련
     5. recruit 
     6. register 

6. app, main -> 앱 실행 및 초기화 과정 
          