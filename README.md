# Digital Note - Flutter

태블릿 최적화 디지털 필기 앱 (Flutter 버전)

## 📱 Features

### 기본 기능
- ✏️ **자연스러운 필기**: 압력 감지 지원 (Apple Pencil, S Pen)
- 🎨 **다양한 색상**: 6가지 프리셋 + 커스텀 색상 선택기
- 🧹 **지우개**: 픽셀 단위 지우기
- ↶↷ **Undo/Redo**: 최대 50단계
- 🌙 **다크 모드**: 눈 편안한 어두운 테마
- 💾 **이미지 저장**: PNG 형식으로 갤러리에 저장
- 📐 **선 두께 조절**: 1-30px
- 💧 **투명도 조절**: 0.1-1.0
- 👆 **제스처 지원**:
  - 2손가락 탭: Undo
  - 3손가락 탭: Redo
- 📱 **반응형**: 세로/가로 모드 모두 지원

### 🔥 NEW! OCR 기능
- 📝 **손글씨 인식**: Google ML Kit 기반 텍스트 인식
- 🔢 **수학 공식 인식**: 수식 자동 감지 및 LaTeX 변환
- ⬚ **선택 도구**: 드래그하여 인식할 영역 선택
- 📋 **복사 기능**: 인식된 텍스트/수식 클립보드 복사
- ✨ **LaTeX 렌더링**: 아름다운 수식 표시

#### 지원하는 수학 기호
- 기본 연산: +, -, ×, ÷, =
- 고급 기호: √, ∫, ∑, π, α, β, θ
- 비교 연산: ≠, ≤, ≥, ∞
- 자동 변환: 분수, 지수, 제곱근

## 🛠 Tech Stack

- **Flutter 3.0+**
- **Dart 3.0+**
- **Provider** (상태 관리)
- **CustomPainter** (고성능 드로잉)
- **Google ML Kit** (텍스트 인식)
- **flutter_math_fork** (LaTeX 렌더링)
- **path_provider** (파일 저장)
- **image_gallery_saver** (이미지 저장)

## 📂 Project Structure

```
lib/
├── main.dart                      # 앱 진입점
├── models/
│   └── drawing_stroke.dart        # 드로잉 데이터 모델
├── providers/
│   └── drawing_provider.dart      # 상태 관리 (+ OCR)
├── services/
│   └── ocr_service.dart          # OCR & LaTeX 변환 서비스
├── screens/
│   └── canvas_screen.dart         # 메인 화면
└── widgets/
    ├── drawing_canvas.dart        # CustomPainter 캔버스
    ├── header.dart                # 상단 헤더
    ├── floating_toolbar.dart      # 하단 툴바 (+ OCR 버튼)
    ├── slider_panel.dart          # 슬라이더 패널
    └── ocr_result_dialog.dart    # OCR 결과 다이얼로그
```

## 📖 OCR 사용법

### 1. 텍스트 인식
1. 툴바에서 선택 도구 (⬚) 클릭
2. 인식할 손글씨 영역을 드래그하여 선택
3. 나타나는 "텍스트" 버튼 클릭
4. 인식된 텍스트를 복사하거나 확인

### 2. 수학 공식 인식
1. 툴바에서 선택 도구 (⬚) 클릭
2. 수식이 포함된 영역을 드래그하여 선택
3. 나타나는 "수식" 버튼 클릭
4. 수식이 LaTeX로 변환되어 표시됨
5. 렌더링된 수식 확인 및 LaTeX 코드 복사

### 수식 작성 팁
- 명확하게 작성: 글자 간 충분한 간격
- 표준 기호 사용: ×, ÷, √ 등
- 간단한 식부터: 복잡한 식은 단계별로
- 예시:
  - `2 + 3 = 5` ✅
  - `x^2 + 2x + 1` ✅
  - `√(16) = 4` ✅
  - `∫ f(x) dx` ✅

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode (for platform-specific builds)

### Installation

```bash
# 1. 의존성 설치
flutter pub get

# 2. 개발 서버 실행
flutter run

# 3. Android APK 빌드
flutter build apk --release

# 4. iOS IPA 빌드 (macOS만 가능)
flutter build ios --release
```

### Run on Specific Device

```bash
# 연결된 기기 확인
flutter devices

# 특정 기기에서 실행
flutter run -d <device-id>

# iPad 시뮬레이터에서 실행
flutter run -d "iPad Pro (12.9-inch)"

# Android 에뮬레이터에서 실행
flutter run -d emulator-5554
```

## 🎯 Key Components

### DrawingProvider
상태 관리 클래스로 모든 드로잉 상태를 관리합니다:
- 획(strokes) 저장 및 관리
- Undo/Redo 히스토리
- 도구 설정 (색상, 두께, 투명도)
- 다크 모드 토글

### DrawingCanvas
CustomPainter를 사용하여 고성능 벡터 드로잉을 구현:
- 압력 감지 지원
- 부드러운 선 렌더링
- 실시간 드로잉 업데이트

### UI Components
- **Header**: 상단 액션 버튼 (Undo, Redo, Clear, Save, Dark Mode)
- **FloatingToolbar**: 하단 플로팅 툴바 (펜/지우개, 색상 선택)
- **SliderPanel**: 좌측 패널 (두께, 투명도 조절)

## 📱 Supported Platforms

- ✅ iOS (iPad optimized)
- ✅ Android (Tablet optimized)
- ✅ Web (experimental)
- ✅ macOS
- ✅ Windows

## 🎨 Design System

- **Primary Color**: `#667EEA` (Purple)
- **Secondary Color**: `#764BA2` (Purple)
- **Gradient**: Linear gradient from purple to violet
- **Dark Mode**: Deep blue-gray background
- **Typography**: SF Pro / Roboto

## 🔧 Configuration

### Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save your drawings</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library</string>
```

## 🐛 Known Issues

- 제스처 힌트가 일부 기기에서 표시되지 않을 수 있음
- 매우 긴 획을 그릴 때 성능 저하 가능성

## 🚧 Future Enhancements

- [ ] 레이어 시스템
- [ ] PDF 가져오기/주석
- [ ] 손글씨 인식 (OCR)
- [ ] 클라우드 동기화
- [ ] 페이지 관리
- [ ] 도형 인식 (자동 교정)
- [ ] 텍스트 도구
- [ ] 이미지 삽입

## 📄 License

MIT License

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or support, please open an issue on GitHub.
