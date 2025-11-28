import 'package:flutter/material.dart';
import './vocabulary_list_screen.dart';
import './add_word_screen.dart';
import './quiz_screen.dart';
import './calendar_screen.dart';

class VocabularyFeatureScreen extends StatefulWidget {
  const VocabularyFeatureScreen({super.key});

  @override
  State<VocabularyFeatureScreen> createState() => _VocabularyFeatureScreenState();
}

class _VocabularyFeatureScreenState extends State<VocabularyFeatureScreen> {
  int _selectedIndex = 0; // '단어장 목록' 탭이 기본

  final List<Widget> _widgetOptions = <Widget>[
    const VocabularyListScreen(),
    const AddWordScreen(),
    const QuizScreen(),
    const CalendarScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('단어장')),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: '목록'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: '추가'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz_outlined), activeIcon: Icon(Icons.quiz), label: '퀴즈'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: '달력'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
