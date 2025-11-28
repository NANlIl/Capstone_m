import 'package:flutter/material.dart';
import '../data/database_helper.dart';

class KanaQuizScreen extends StatefulWidget {
  final List<Kana> kanaList;
  final String title;

  const KanaQuizScreen({
    super.key,
    required this.kanaList,
    required this.title,
  });

  @override
  State<KanaQuizScreen> createState() => _KanaQuizScreenState();
}

class _KanaQuizScreenState extends State<KanaQuizScreen> {
  late List<Kana> _quizList;
  int _currentIndex = 0;
  bool _isAnswerVisible = false;

  @override
  void initState() {
    super.initState();
    _quizList = widget.kanaList.where((kana) => kana.id != -1).toList();
    _quizList.shuffle();
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _quizList.length;
      _isAnswerVisible = false;
    });
  }

  void _previousCard() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _quizList.length) % _quizList.length;
      _isAnswerVisible = false;
    });
  }

  void _shuffle() {
    setState(() {
      _quizList.shuffle();
      _currentIndex = 0;
      _isAnswerVisible = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('카드를 섞었습니다!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_quizList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.title} 퀴즈')),
        body: const Center(child: Text('퀴즈에 필요한 데이터가 없습니다.')),
      );
    }

    final currentKana = _quizList[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} 랜덤 퀴즈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _shuffle,
            tooltip: '순서 섞기',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${_currentIndex + 1} / ${_quizList.length}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 3 / 2,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isAnswerVisible = !_isAnswerVisible;
                  });
                },
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: _isAnswerVisible
                          ? Text( // 정답 (발음)
                              currentKana.pronunciation,
                              key: const ValueKey('pronunciation'),
                              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                            )
                          : Text( // 문제 (글자)
                              currentKana.character,
                              key: const ValueKey('character'),
                              style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilledButton.tonal(
                  onPressed: _previousCard,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text('이전', style: TextStyle(fontSize: 18)),
                  ),
                ),
                FilledButton(
                  onPressed: _nextCard,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text('다음', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
