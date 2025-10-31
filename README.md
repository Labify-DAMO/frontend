# 🧭 SwiftUI 프로젝트 실행 가이드

이 프로젝트는 **SwiftUI 프론트엔드**, **FastAPI 기반 AI 서버**, **Spring Boot 백엔드**로 구성되어 있습니다.  
아래 순서대로 서버를 구동한 뒤 **Xcode**에서 앱을 실행하세요.

---

## ⚙️ 실행 순서 요약

1️⃣ **AI 서버 실행 (Python / FastAPI)**  
2️⃣ **백엔드 서버 실행 (Spring Boot)**  
3️⃣ **iOS 앱 실행 (SwiftUI)**  

---

## 🤖 AI 서버 실행

`ai-server` 폴더에서 가상환경을 활성화하고 FastAPI 서버를 실행합니다.

```bash
cd ai-server
source .venv/bin/activate
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
````

서버가 정상 실행되면 아래 주소에서 API 문서를 확인할 수 있습니다.
👉 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)

---

## 🧱 백엔드 서버 실행

`backend` 폴더에서 Gradle 명령으로 Spring Boot 서버를 실행합니다.

```bash
cd backend
./gradlew bootRun
```

만약 실행 권한이 없을 경우 다음 명령을 먼저 입력하세요:

```bash
chmod +x gradlew
```

서버가 정상적으로 실행되면 아래 주소에서 백엔드가 동작 중인지 확인할 수 있습니다.
👉 [http://localhost:8080](http://localhost:8080)

---

## 📱 SwiftUI 프론트 실행

이제 iOS 앱을 실행합니다.

```bash
git clone https://github.com/your-repo/ProjectName.git
cd ProjectName
```

이후 `ProjectName.xcodeproj` 또는 `ProjectName.xcworkspace` 파일을 **Xcode**로 엽니다.
상단의 **Scheme** 메뉴에서 실행할 **Device 또는 Simulator**를 선택한 뒤,
`⌘ + R` (또는 ▶️ **Run** 버튼)을 눌러 앱을 빌드하고 실행하세요.

---

## ⚙️ 빌드 문제 해결

빌드 오류가 발생할 경우 아래 순서대로 점검해 보세요.

### 1️⃣ 패키지 캐시 재설정

**Xcode 메뉴:**
`File ▸ Packages ▸ Reset Package Caches`

### 2️⃣ 클린 빌드

단축키
`⇧ + ⌘ + K`

### 3️⃣ DerivedData 삭제

**Xcode 경로:**
`Xcode ▸ Settings ▸ Locations` 탭에서 `DerivedData` 폴더 삭제

이 과정을 거치면 대부분의 빌드 문제를 해결할 수 있습니다.

---

## 💡 추가 팁

* 서버 간 포트 충돌이 없는지 확인하세요 (`8000`, `8080` 등)
* AI 서버와 백엔드 서버가 모두 실행 중이어야 앱이 정상 동작합니다
* iOS 시뮬레이터가 네트워크에 접근할 수 있는 환경인지 확인하세요
  
GitHub에 붙여넣으면 제목 계층, 코드 블록, 줄간격 전부 깔끔하게 나올 거예요.
```
