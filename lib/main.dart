import 'package:flutter/material.dart';

void main() {
  runApp(const NihongoApp());
}

class NihongoApp extends StatelessWidget {
  const NihongoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nihongo App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
          labelStyle: TextStyle(color: Colors.black54),
          hintStyle: TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            side: const BorderSide(color: Colors.black, width: 1),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// --- 시작, 회원가입, 로그인 화면 ---

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Spacer(flex: 5),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0), textStyle: const TextStyle(fontSize: 18)),
              child: const Text('시작하기'),
            ),
            const SizedBox(height: 12.0),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
              child: const Text('이미 계정이 있습니다'),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(decoration: const InputDecoration(labelText: '아이디')),
            const SizedBox(height: 12.0),
            TextFormField(obscureText: true, decoration: const InputDecoration(labelText: '비밀번호')),
            const SizedBox(height: 12.0),
            TextFormField(obscureText: true, decoration: const InputDecoration(labelText: '비밀번호 확인')),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12.0)),
              child: const Text('회원가입 완료'),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen())),
              child: const Text('게스트로 로그인 하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  void _navigateToMainScreen() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(controller: _idController, decoration: const InputDecoration(labelText: '아이디')),
            const SizedBox(height: 12.0),
            TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: '비밀번호')),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _navigateToMainScreen,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12.0)),
              child: const Text('로그인')
            ),
            TextButton(onPressed: _navigateToMainScreen, child: const Text('게스트로 로그인 하기')),
            TextButton(onPressed: () { /* TODO: 계정찾기 */ }, child: const Text('계정찾기')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}


// --- 앱 메인 스크린 (기본 바텀 네비게이션 바) ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; 

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const VocabularyFeatureScreen()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const LearningScreen(),
      const SizedBox.shrink(), // 단어장 탭은 화면 전환용
      const CommunityScreen(),
      const MyPageScreen(),
      const MenuScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nihongo App'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.school), label: '학습'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '단어장'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: '메뉴'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --- 단어장 기능 메인 스크린 ---

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
      appBar: AppBar(
        title: const Text('단어장'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '단어장 목록'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: '단어 추가'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: '퀴즈'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '달력'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
      ),
    );
  }
}

// --- 탭별 화면들 ---

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildMenuButton(context, '문자 학습', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CharacterLearningScreen()))),
          const SizedBox(height: 16),
          _buildMenuButton(context, '한자 학습', () { /* TODO */ }),
          const SizedBox(height: 16),
          _buildMenuButton(context, '단어 학습', () { /* TODO */ }),
          const SizedBox(height: 16),
          _buildMenuButton(context, '문법/예문 학습', () { /* TODO */ }),
          const SizedBox(height: 16),
          _buildMenuButton(context, '실력평가', () { /* TODO */ }),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 24.0), textStyle: const TextStyle(fontSize: 20)),
      child: Text(title),
    );
  }
}

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('마이페이지 화면', style: TextStyle(fontSize: 24, color: Colors.black87)));
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('커뮤니티 화면', style: TextStyle(fontSize: 24, color: Colors.black87)));
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('메뉴 화면', style: TextStyle(fontSize: 24, color: Colors.black87)));
  }
}

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('퀴즈 화면', style: TextStyle(fontSize: 24, color: Colors.black87)));
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('달력 화면', style: TextStyle(fontSize: 24, color: Colors.black87)));
  }
}

// --- 단어장 기능 화면들 ---

class VocabularyListScreen extends StatelessWidget {
  const VocabularyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 단어장 목록 데이터와 연동
    final List<String> vocabularyBooks = ['기초 단어', 'JLPT N3 단어'];

    return Scaffold(
      body: ListView.builder(
        itemCount: vocabularyBooks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(vocabularyBooks[index]),
            onTap: () {
              // TODO: 해당 단어장의 단어 목록 보기 화면으로 이동
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddVocabularyBookScreen()));
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddVocabularyBookScreen extends StatelessWidget {
  const AddVocabularyBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 단어장 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: '단어장 이름'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // TODO: 단어장 추가 로직 구현
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
              child: const Text('만들기'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  // TODO: 실제 단어장 목록 데이터와 연동
  final List<String> _vocabularyBooks = ['기초 단어', 'JLPT N3 단어'];
  String? _selectedBook;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedBook,
              hint: const Text('단어장을 선택하세요'),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedBook = newValue;
                  });
                }
              },
              items: _vocabularyBooks.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16.0),
            // 드롭다운에서 단어장을 선택해야만 아래 입력칸들이 보임
            if (_selectedBook != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: '단어 (일본어)'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '의미 (한국어)'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '발음 (히라가나/가타카나/로마자)'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '설명 (예문 등)'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: 단어 추가 로직 구현
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                    child: const Text('단어 추가하기'),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('사전검색: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      TextButton(
                        onPressed: () {
                          // TODO: 네이버 사전 링크 열기
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(10, 10),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '네이버 사전',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}

// -- 기존 세부 화면들 --

class CharacterLearningScreen extends StatelessWidget {
  const CharacterLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문자 학습'),
      ),
      body: const Center(
        child: Text('여기에 문자 학습 콘텐츠가 표시됩니다.', style: TextStyle(fontSize: 24, color: Colors.black87)),
      ),
    );
  }
}
