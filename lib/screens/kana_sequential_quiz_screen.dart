import 'package:flutter/material.dart';
import '../data/database_helper.dart';

class KanaSequentialQuizScreen extends StatefulWidget {
  final List<Kana> kanaList;
  final String title;

  const KanaSequentialQuizScreen({
    super.key,
    required this.kanaList,
    required this.title,
  });

  @override
  State<KanaSequentialQuizScreen> createState() => _KanaSequentialQuizScreenState();
}

class _KanaSequentialQuizScreenState extends State<KanaSequentialQuizScreen> {
  late List<Kana> _quizList;
  int _currentIndex = 0;
  bool _isAnswerVisible = false;

  @override
  void initState() {
    super.initState();
    // 순서 퀴즈이므로, 전달받은 리스트에서 빈 칸만 걸러내고 순서는 그대로 유지합니다.
    _quizList = widget.kanaList.where((kana) => kana.id != -1).toList();
  }

  void _nextCard() {
    setState(() {
      if (_currentIndex < _quizList.length - 1) {
        _currentIndex++;
        _isAnswerVisible = false;
      } else {
        // 마지막 카드일 경우, 퀴즈 완료 처리 (예: 화면 닫기)
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('퀴즈를 완료했습니다!')),
        );
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
        _isAnswerVisible = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_quizList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.title} 순서 퀴즈')),
        body: const Center(child: Text('퀴즈에 필요한 데이터가 없습니다.')),
      );
    }

    final currentKana = _quizList[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} 순서 퀴즈'),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text(
                      _currentIndex == _quizList.length - 1 ? '완료' : '다음',
                      style: const TextStyle(fontSize: 18)
                    ),
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
