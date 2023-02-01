# 🏞 CrwalCrwal!
 - 구글 이미지 크롤러
 
---
### 기능
- 텍스트를 입력하면 구글 이미지에서 검색된 결과들을 가져와 리스트로 보여줍니다.
- 가져온 이미지들은 개별/일괄 디바이스에 다운로드가 가능합니다.


---
### 사용 기술
 - RxSwift, SnapKit, SwiftSoup


---

<img width="250" alt="스크린샷 2022-11-22 오후 2 24 45" src="https://user-images.githubusercontent.com/44960073/203229197-a0eac7cb-68fe-4144-a0ed-e47fb53136b5.png">  <img width="250" alt="스크린샷 2022-11-22 오후 2 24 59" src="https://user-images.githubusercontent.com/44960073/203230154-dbe6d847-46cf-4fb0-af2b-8a0a720f2d27.png">
 
---
### 트러블 슈팅
 [검색 후 일시적으로 UI가 멈추는 현상]
  - HTML 파싱 및 다운로드 로직인데 무의식적으로 해당 로직을 DispatchQueue.main.async 블록에 넣어버렸다.
  - 어이없는 실수에 감탄하며 DispatchQueue.global.async로 바꿔서 해결했다!
 
