# 🧭 SwiftUI 프로젝트 실행 가이드

이 프로젝트는 **SwiftUI 프론트엔드**, **FastAPI 기반 AI 서버**, **Spring Boot 백엔드**로 구성되어 있습니다.  
아래 순서대로 서버를 구동한 뒤 Xcode에서 앱을 실행하세요.

---

## ⚙️ 실행 순서 요약

1️⃣ **AI 서버 실행 (Python / FastAPI)**  
2️⃣ **백엔드 서버 실행 (Spring Boot)**  
3️⃣ **iOS 앱 실행 (SwiftUI)**  

---

## 🤖 1. AI 서버 실행

프로젝트 루트 또는 `ai-server` 폴더에서 가상환경을 활성화하고 FastAPI 서버를 실행합니다.

```bash
source .venv/bin/activate
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
서버가 정상 실행되면 http://127.0.0.1:8000/docs 에서 API 문서를 확인할 수 있습니다.

🧱 2. 백엔드 서버 실행
backend 폴더에서 Gradle 명령으로 서버를 실행합니다.

bash
코드 복사
./gradlew bootRun
실행 권한이 없을 경우 아래 명령을 먼저 실행하세요.

bash
코드 복사
chmod +x gradlew
서버가 정상적으로 실행되면 http://localhost:8080 에서 백엔드가 동작 중인지 확인할 수 있습니다.

📱 3. SwiftUI 프론트 실행
이제 Xcode로 iOS 앱을 실행합니다.

bash
코드 복사
git clone https://github.com/your-repo/ProjectName.git
cd ProjectName
이후 ProjectName.xcodeproj 또는 ProjectName.xcworkspace 파일을 Xcode로 엽니다.
상단의 Scheme 메뉴에서 실행할 Device 또는 Simulator를 선택한 뒤,
⌘ + R (또는 ▶️ Run 버튼)을 눌러 앱을 빌드하고 실행합니다.

⚙️ 빌드 문제 해결
빌드 오류가 발생할 경우 아래 순서대로 점검해 보세요.

패키지 캐시 재설정:
File ▸ Packages ▸ Reset Package Caches

클린 빌드:
단축키 ⇧ + ⌘ + K

DerivedData 삭제:
Xcode ▸ Settings ▸ Locations 탭에서 DerivedData 폴더 삭제

이 과정을 거치면 대부분의 빌드 문제를 해결할 수 있습니다.
