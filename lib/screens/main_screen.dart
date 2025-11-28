import 'package:flutter/material.dart';
import './learning_screen.dart';
import './community_screen.dart';
import './my_page_screen.dart';
import './vocabulary_feature_screen.dart';
import '../widgets/fade_page_route.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 각 탭에 해당하는 화면들
  static const List<Widget> _widgetOptions = <Widget>[
    LearningScreen(),
    SizedBox.shrink(), // 단어장 탭은 화면 전환용으로 실제 화면 없음
    CommunityScreen(),
    MyPageScreen(),
  ];

  // 각 탭에 해당하는 앱 바 제목들
  static const List<String> _appBarTitles = <String>[
    '학습', 
    '단어장', // 사용되지 않음
    '커뮤니티', 
    '마이페이지', 
  ];

  void _onItemTapped(int index) {
    // '단어장' 탭을 누르면 별도의 화면으로 이동
    if (index == 1) {
      Navigator.push(context, FadePageRoute(child: const VocabularyFeatureScreen()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: '학습'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: '단어장'),
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), activeIcon: Icon(Icons.forum), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '마이페이지'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
