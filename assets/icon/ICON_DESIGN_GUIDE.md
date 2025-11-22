# 공스타그램 앱 아이콘 디자인 가이드

## 디자인 컨셉
**공스타그램(Gong-stagram)** 감성의 미니멀하고 깔끔한 디자인

## 색상 팔레트
- **Primary Color**: #667EEA (보라-파랑 계열)
- **Secondary Color**: #764BA2 (진한 보라)
- **Accent**: #FFFAF0 (아이보리 배경)
- **White**: #FFFFFF

## 아이콘 모티브

### 권장 디자인 요소:
1. **펜 아이콘** 🖊️
   - 간단한 펜 실루엣
   - 45도 각도로 기울어진 모습
   - 깔끔한 라인워크

2. **노트/종이 아이콘** 📄
   - 모서리가 둥근 사각형
   - 최소한의 선으로 표현

3. **조합 아이콘** (추천)
   - 펜 + 노트를 조합
   - 펜이 노트 위에 있는 모습
   - 그라데이션 효과 적용

## 아이콘 사양

### 기본 아이콘 (app_icon.png)
- **크기**: 1024x1024 px
- **포맷**: PNG (투명 배경 없음)
- **DPI**: 72

### Android Adaptive Icon (app_icon_foreground.png)
- **크기**: 1024x1024 px
- **포맷**: PNG (투명 배경 포함)
- **Safe Zone**: 중앙 432x432px 영역 내에 주요 요소 배치
- **Background**: #667EEA (설정됨)

### iOS 아이콘
- 동일한 app_icon.png 사용
- 모서리는 iOS가 자동으로 둥글게 처리

## 디자인 도구

### 온라인 생성기:
1. **Canva** (https://www.canva.com)
   - 템플릿: App Icon
   - 사이즈: 1024x1024px

2. **Figma** (https://www.figma.com)
   - 무료로 사용 가능
   - 벡터 기반 디자인

3. **App Icon Generator**
   - https://appicon.co
   - PNG 업로드 후 모든 사이즈 자동 생성

### 디자인 예시 (간단한 SVG 코드):

```svg
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <!-- Background gradient -->
  <defs>
    <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667EEA;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#764BA2;stop-opacity:1" />
    </linearGradient>
  </defs>

  <!-- Background -->
  <rect width="1024" height="1024" fill="url(#gradient)" rx="180"/>

  <!-- Note paper -->
  <rect x="200" y="180" width="624" height="664" fill="white" rx="40" opacity="0.95"/>

  <!-- Pen -->
  <g transform="translate(600, 300) rotate(45)">
    <rect x="-20" y="0" width="40" height="400" fill="#FFD700" rx="20"/>
    <polygon points="-20,400 20,400 0,450" fill="#FFA500"/>
    <rect x="-20" y="0" width="40" height="60" fill="#4A4A4A" rx="20"/>
  </g>

  <!-- Decorative lines on paper -->
  <line x1="280" y1="340" x2="600" y2="340" stroke="#667EEA" stroke-width="8" opacity="0.3"/>
  <line x1="280" y1="420" x2="700" y2="420" stroke="#667EEA" stroke-width="8" opacity="0.3"/>
  <line x1="280" y1="500" x2="650" y2="500" stroke="#667EEA" stroke-width="8" opacity="0.3"/>
</svg>
```

## 아이콘 생성 후

1. **app_icon.png** 파일을 `assets/icon/`에 저장
2. **app_icon_foreground.png** 파일을 `assets/icon/`에 저장 (투명 배경)

3. 터미널에서 실행:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

4. 앱 재빌드:
```bash
flutter clean
flutter build apk  # Android
flutter build ios  # iOS
```

## 체크리스트

- [ ] 아이콘 이미지 1024x1024px 준비
- [ ] app_icon.png 파일 생성 (일반 아이콘)
- [ ] app_icon_foreground.png 파일 생성 (Android 전경)
- [ ] assets/icon/ 폴더에 파일 저장
- [ ] `flutter pub get` 실행
- [ ] `flutter pub run flutter_launcher_icons` 실행
- [ ] 앱 재빌드 및 테스트

## 브랜딩 가이드라인

### Do ✅
- 미니멀하고 깔끔한 디자인
- 브랜드 컬러 (#667EEA, #764BA2) 사용
- 명확한 펜/노트 모티브
- 가독성 있는 심볼

### Don't ❌
- 너무 복잡한 디테일
- 어두운 색상 위주
- 작은 텍스트 포함
- 여러 요소를 한꺼번에 넣기

---

**참고**: 실제 아이콘 제작은 디자이너나 온라인 도구를 활용하는 것을 권장합니다.
