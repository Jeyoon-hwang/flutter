import 'dart:math';

/// Motivational quotes system for study motivation
class MotivationalQuotes {
  static final Random _random = Random();

  static final List<String> _quotes = [
    "오늘도 화이팅! 🔥",
    "꾸준함이 천재성을 이긴다 ✨",
    "작은 진보도 진보입니다 📈",
    "포기하지 않으면 실패하지 않는다 💪",
    "지금 이 순간을 즐기세요 😊",
    "당신은 할 수 있습니다! 🌟",
    "배움에는 끝이 없습니다 📚",
    "오늘의 노력이 내일의 성과를 만듭니다 🌱",
    "한 걸음씩 꾸준히! 🚶",
    "실수는 배움의 기회입니다 💡",
    "믿음을 가지고 전진하세요 🎯",
    "성공은 준비된 자에게 찾아옵니다 🏆",
    "지금 이 순간에 집중하세요 🎯",
    "노력은 배신하지 않습니다 💎",
    "당신의 가능성을 믿으세요 ⭐",
    "오늘 하루도 최선을 다하세요! 🌈",
    "작은 목표부터 달성해보세요 🎯",
    "학습은 평생의 여정입니다 🛤️",
    "집중력이 성공의 열쇠입니다 🔑",
    "매일 조금씩 성장하세요 📊",
    "도전은 성장의 시작입니다 🚀",
    "실패는 성공의 어머니 🌟",
    "지금 시작하세요, 완벽할 필요 없습니다 ✅",
    "긍정적인 마음이 좋은 결과를 만듭니다 😊",
    "끈기있게 계속하세요! 🎓",
    "The secret of getting ahead is getting started.",
    "Success is not final, failure is not fatal.",
    "Believe you can and you're halfway there.",
    "The only way to do great work is to love what you do.",
    "It always seems impossible until it's done.",
    "Don't watch the clock; do what it does. Keep going.",
    "The future depends on what you do today.",
    "You are never too old to set another goal.",
    "It does not matter how slowly you go as long as you do not stop.",
    "Everything you've ever wanted is on the other side of fear.",
  ];

  static final List<String> _morningQuotes = [
    "좋은 아침! 오늘도 힘차게 시작해봐요 🌅",
    "새로운 하루, 새로운 기회입니다 ☀️",
    "아침의 선택이 하루를 결정합니다 🌄",
    "오늘도 멋진 하루 되세요! 🌞",
    "일찍 일어난 새가 먹이를 잡습니다 🐦",
  ];

  static final List<String> _afternoonQuotes = [
    "오후에도 집중력을 유지하세요! ☕",
    "점심 후 슬럼프를 이겨내세요 💪",
    "오후가 가장 생산적인 시간입니다 📖",
    "조금만 더 힘내세요! 🌟",
    "오후의 노력이 빛을 발합니다 ✨",
  ];

  static final List<String> _eveningQuotes = [
    "오늘 하루 고생하셨습니다! 🌙",
    "저녁 시간도 소중히 활용하세요 ⭐",
    "오늘의 마무리를 멋지게! 🌃",
    "밤 시간도 귀중한 학습 시간입니다 📚",
    "내일을 위해 오늘을 정리하세요 🌆",
  ];

  /// Get a random quote
  static String getRandomQuote() {
    return _quotes[_random.nextInt(_quotes.length)];
  }

  /// Get a time-based quote
  static String getTimeBasedQuote() {
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
  static String getStudyQuote() {
    final studyQuotes = _quotes.where((q) =>
      q.contains('학습') ||
      q.contains('배움') ||
      q.contains('study') ||
      q.contains('learn')
    ).toList();

    if (studyQuotes.isEmpty) return getRandomQuote();
    return studyQuotes[_random.nextInt(studyQuotes.length)];
  }

  /// Get daily quote (changes once per day)
  static String getDailyQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }
}
