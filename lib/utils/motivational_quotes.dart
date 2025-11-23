import 'dart:math';

/// Quote model with text and author
class Quote {
  final String text;
  final String author;

  const Quote(this.text, this.author);

  @override
  String toString() => text;
}

/// Motivational quotes system for study motivation
class MotivationalQuotes {
  static final Random _random = Random();

  static final List<Quote> _quotes = [
    Quote("오늘도 화이팅!", "익명"),
    Quote("꾸준함이 천재성을 이긴다.", "익명"),
    Quote("작은 진보도 진보입니다.", "익명"),
    Quote("포기하지 않으면 실패하지 않는다.", "익명"),
    Quote("지금 이 순간을 즐기세요.", "익명"),
    Quote("당신은 할 수 있습니다!", "익명"),
    Quote("천재는 1%의 재능과 99%의 노력으로 만들어진다.", "토마스 에디슨"),
    Quote("한 걸음씩 꾸준히!", "익명"),
    Quote("실수는 배움의 기회입니다.", "익명"),
    Quote("믿음을 가지고 전진하세요.", "익명"),
    Quote("성공은 준비된 자에게 찾아옵니다.", "익명"),
    Quote("지금 이 순간에 집중하세요.", "익명"),
    Quote("노력은 배신하지 않습니다.", "익명"),
    Quote("당신의 가능성을 믿으세요.", "익명"),
    Quote("오늘 하루도 최선을 다하세요!", "익명"),
    Quote("작은 목표부터 달성해보세요.", "익명"),
    Quote("집중력이 성공의 열쇠입니다.", "익명"),
    Quote("매일 조금씩 성장하세요.", "익명"),
    Quote("도전은 성장의 시작입니다.", "익명"),
    Quote("실패는 성공의 어머니.", "익명"),
    Quote("지금 시작하세요, 완벽할 필요 없습니다.", "익명"),
    Quote("긍정적인 마음이 좋은 결과를 만듭니다.", "익명"),
    Quote("끈기있게 계속하세요!", "익명"),
    Quote("시작하는 것이 앞서가는 비결이다.", "마크 트웨인"),
    Quote("성공은 최종이 아니며, 실패는 치명적이지 않다.", "윈스턴 처칠"),
    Quote("할 수 있다고 믿으면 이미 절반은 이룬 것이다.", "시어도어 루스벨트"),
    Quote("위대한 일을 하는 유일한 방법은 당신이 하는 일을 사랑하는 것이다.", "스티브 잡스"),
    Quote("해낼 때까지는 항상 불가능해 보인다.", "넬슨 만델라"),
    Quote("시계를 보지 말고, 시계처럼 행동하라. 계속 가라.", "샘 레븐슨"),
    Quote("미래는 오늘 당신이 무엇을 하느냐에 달려있다.", "마하트마 간디"),
    Quote("멈추지 않는 한 얼마나 천천히 가는지는 중요하지 않다.", "공자"),
    Quote("당신이 원했던 모든 것은 두려움 너머에 있다.", "조지 아다이르"),
    Quote("배움에 있어서 나이는 중요하지 않다.", "익명"),
    Quote("행동이 모든 성공의 기본 열쇠다.", "파블로 피카소"),
    Quote("가장 큰 위험은 위험을 전혀 감수하지 않는 것이다.", "마크 저커버그"),
  ];

  static final List<Quote> _morningQuotes = [
    Quote("좋은 아침! 오늘도 힘차게 시작해봐요.", "익명"),
    Quote("새로운 하루, 새로운 기회입니다.", "익명"),
    Quote("아침의 선택이 하루를 결정합니다.", "익명"),
    Quote("오늘도 멋진 하루 되세요!", "익명"),
    Quote("일찍 일어난 새가 먹이를 잡는다.", "속담"),
  ];

  static final List<Quote> _afternoonQuotes = [
    Quote("오후에도 집중력을 유지하세요!", "익명"),
    Quote("점심 후 슬럼프를 이겨내세요.", "익명"),
    Quote("오후가 가장 생산적인 시간입니다.", "익명"),
    Quote("조금만 더 힘내세요!", "익명"),
    Quote("오후의 노력이 빛을 발합니다.", "익명"),
  ];

  static final List<Quote> _eveningQuotes = [
    Quote("오늘 하루 고생하셨습니다!", "익명"),
    Quote("저녁 시간도 소중히 활용하세요.", "익명"),
    Quote("오늘의 마무리를 멋지게!", "익명"),
    Quote("밤 시간도 귀중한 학습 시간입니다.", "익명"),
    Quote("내일을 위해 오늘을 정리하세요.", "익명"),
  ];

  /// Get a random quote
  static Quote getRandomQuote() {
    return _quotes[_random.nextInt(_quotes.length)];
  }

  /// Get a time-based quote
  static Quote getTimeBasedQuote() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning
      return _morningQuotes[_random.nextInt(_morningQuotes.length)];
    } else if (hour >= 12 && hour < 18) {
      // Afternoon
      return _afternoonQuotes[_random.nextInt(_afternoonQuotes.length)];
    } else {
      // Evening/Night
      return _eveningQuotes[_random.nextInt(_eveningQuotes.length)];
    }
  }

  /// Get a study-focused quote
  static Quote getStudyQuote() {
    final studyQuotes = _quotes.where((q) =>
      q.text.contains('학습') ||
      q.text.contains('배움') ||
      q.text.contains('집중') ||
      q.text.contains('노력')
    ).toList();

    if (studyQuotes.isEmpty) return getRandomQuote();
    return studyQuotes[_random.nextInt(studyQuotes.length)];
  }

  /// Get daily quote (changes once per day)
  static Quote getDailyQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }
}
