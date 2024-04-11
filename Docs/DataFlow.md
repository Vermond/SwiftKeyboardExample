#  데이터 흐름 정리

## JSON
- 목적 : 키보드 정보 저장, 공유
- 구성방식 예시

{
    name: "",
    rows: [
        {
            keys: [
                {
                    width : 100,
                    charColor: 'Black',
                    backColor: 'White',
                    radius: 10,
                    mainText: 'ㄱ',
                    topText: 'ㄹ',
                    keyAction: 'input:self',
                },
                {
                    //repeat key
                },
            ],
            backColor: 'gray',
        },
        {
            //repeat row
        },
    ],
    // other parameters
}


## Data Model
- 목적 : Json 데이터를 뷰 개별 데이터로 변환할 준비
- 위치 : Keyboard - Model
- 동작
    * 초기 키보드 데이터 구성
    * 화면 크기 변경 or 가로/세로 변경시 길이 재조절
    * 키보드 변경시 새로운 키보드로 데이터 변경
    

## View Model
- 목적 : 1:1로 연결된 뷰에 필요한 데이터 저장, 관리
- 위치 : 각 뷰의 내부에 선언
- 동작
    * 뷰 데이터 보존
    * 키보드 길이 정보 변경시 신규 적용
    * 키보드 변경시 새로운 키보드 정보 저장
    

## 각 모델별 연결

- JSON -> Data Model
    * 키보드 초기 연결 or 키보드 변경시 수행
    * 1:1 변환
    * json decode 통해 데이터 획득

- Data Model -> JSON
    * 키보드 설정 저장시 수행
    * 1:1 변환
    * json encode로 변환
    * 필요시 파일로 저장
    
- Data Model -> View Model
    * 데이터 모델 내용 변경 or 화면 크기, 가로/세로 변경시
    * 초기 1회는 직접 뷰와 뷰 모델 작성하면서 입력
    * 이후 업데이트는 이벤트 등을 통하여 알림, 데이터 갱신
    
** View Model은 뷰 외부로 데이터 전송하지 않는다. 데이터 관리 자체는 데이터 모델이 수행


