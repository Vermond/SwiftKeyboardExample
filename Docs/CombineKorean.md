#  한글 유니코드 입력 조합법

유니코드는 Hangul Jamo 라는 제목으로 한글을 저장하고 있다. 옛한글 단어나 자모도 있지만 정말 필요한 경우가 아니라면 사용하지 않아도 무방하다.
한글 자모 유니코드 시작은 ㄱ(1100)이며 마지막은 ㄴㄴ(ㄴ 2개 받침, 11FF)이다. 

##한글 자모 유니코드 영역

자모 조합형
1100(4352) - 11FF(4607)

자모 완성형
3131(12593) ~ 318E(12686)

한글
AC00(44032) ~ D7A3(55203)

참고 링크
https://blog.naver.com/PostView.nhn?blogId=techshare&logNo=221371791944
http://www.unicode.org/versions/Unicode7.0.0/ch03.pdf#G24646
https://www.unicode.org/versions/Unicode15.0.0/

##개수

자모 조합형 기준으로
자음은 (ㄱ) 1100에서 시작한다 -> LBase
모음은 (ㅏ) 1161에서 시작한다 -> VBase
받침은 (ㄱ) 11A7에서 시작한다 -> TBase

글자는 (가) AC00에서 시작한다 -> SBase

개별 개수는 각각 다음과 같다
자음 : 19 -> LCount
모음 : 21 -> VCount
받침 : 28 -> TCount

모음 x 받침 : 588 -> NCount
전체 자모 개수 : 11172 -> SCount


##분해 방식

1. 미리 구성된 한글 음절의 색인을 계산한다
SIndex = s - SBase

2. SIndex가 범위 내라면 (0 ~ SCount) 한글이다. 범위 외라면 그냥 입력한걸 보낸다

3. 분해한다.
자음, 모음으로만 이루어진 경우 (LV)
LIndex = SIndex / NCount
VIndex = (SIndex % NCount) / TCount

LPart = LBase + LIndex
VPart = VBase + VIndex

자음, 모음, 받침으로 이루어지는 경우 (LVT)
LVIndex = (SIndex / TCount) \* TCount
TIndex = SIndex % TCount
LVPart = SBase + LVIndex
TPart = TBase + TIndex

두 식을 합치면 자음, 모음, 받침 구하는건 이렇게 정리된다.
LPart = LBase + SIndex / NCount
VPart = VBase + (SIndex % NCount) / TCount
TPart = TBase + SIndex % TCount


##음절 구성 방식

1. 한글 글자가 L, V 이고 LPart가 1100 ~ 1112, VPart가 1161~1175라면 다음과 같이 계산이 가능하다
LIndex = LPart - LBase
VIndex = VPart - VBase
LVIndex = LIndex \* NCount + VIndex \* TCount
s = SBase + LVIndex

2. 한글 글자가 L, V, T이고 LPart가 1100 ~ 1112, VPart가 1161~1175, TPart가 11A8~11C2라면 다음과 같이 계산이 가능하다
LIndex = LPart - LBase
VIndex = VPart - VBase
TIndex = TPart - TBase
LVindex = LIndex \* NCount + VIndex \* TCount
s = SBase + LVIndex + TIndex

3. 한글 데이터가 정규적으로 분해되지 않은 경우의 처리를 위한 매핑을 추가한다.
LV, T 형식이며 LVPart가 한글 음절이고 TPart가 11A8~11C2라면 다음과 같이 계산한다.
TIndex = TPart - TBase
s = LVPart + TIndex



##입력 알고리즘
1. 커서 기준으로 직전 문자를 가져온다.
2. 문자의 스타일을 확인한다.

2-1. LV + 자음 글자 : 자음을 받침으로 변경한다
2-2. LV + 모음 글자 : V + 모음 가능 여부 체크 후 진행
2-3. LVT + 자음 글자 : T + 자음 가능 여부 확인 후 진행
2-4. LVT + 모음 글자 : T를 종성에서 초성으로 변경한다. 단, T가 합성자음이면 분리해서 뒤의 것만 변경한다.
2-5. 자음 글자 + 모음 글자 : 초성과 중성으로 변경한 다음 조합한다.
2-6. 이외의 상황은 그냥 글자끼리 단순 연결한다.


##변경 알고리즘
자음 글자 -> 초성
초성이나 종성의 나열과 글자의 나열이 다르므로 map을 활용한다.

모음 글자 - 중성
순서가 동일하므로 수학적으로 계산한다

종성 합성자음 - 종성 + 초성
tuple을 활용해 변환 가능 여부를 저장한다
