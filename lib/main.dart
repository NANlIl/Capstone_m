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
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF00AFF0),
        // AppBar의 배경색도 통일감을 주기 위해 같은 색으로 설정 (color -> backgroundColor로 수정)
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF00AFF0)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// --- 시작, 회원가입, 로그인 화면 (Navigation 로직 수정) ---

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
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
              child: const Text('시작하기', style: TextStyle(fontSize: 18)),
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
            TextFormField(decoration: const InputDecoration(labelText: '아이디', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 12.0),
            TextFormField(obscureText: true, decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 12.0),
            TextFormField(obscureText: true, decoration: const InputDecoration(labelText: '비밀번호 확인', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              child: const Text('회원가입 완료'),
            ),
            TextButton(
              // 임시 뒤로가기를 위해 pushReplacement -> push 로 변경
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen())),
              child: const Text('게스트로 로그인 하기', style: TextStyle(color: Colors.white)),
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
    // 임시 뒤로가기를 위해 pushReplacement -> push 로 변경
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen()));
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
            TextFormField(controller: _idController, decoration: const InputDecoration(labelText: '아이디', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 12.0),
            TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 24.0),
            ElevatedButton(onPressed: _navigateToMainScreen, child: const Text('로그인')),
            TextButton(onPressed: _navigateToMainScreen, child: const Text('게스트로 로그인 하기', style: TextStyle(color: Colors.white))),
            TextButton(onPressed: () { /* TODO: 계정찾기 */ }, child: const Text('계정찾기', style: TextStyle(color: Colors.white))),
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


// --- 로그인 후 메인 화면 (바텀 네비게이션 바) ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 기본으로 '학습' 탭이 선택되도록 0으로 변경

  // 하단 탭에 표시될 화면 목록 (순서 변경)
  static const List<Widget> _widgetOptions = <Widget>[
    LearningScreen(),
    VocabularyScreen(),
    BoardScreen(),
    MyPageScreen(),
    MenuScreen(),
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
        title: const Text('Nihongo App'),
        automaticallyImplyLeading: true, // 뒤로가기 버튼 표시
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // 하단 탭 아이템 순서 변경
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '학습',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '단어장',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: '게시판',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '메뉴',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        type: BottomNavigationBarType.fixed, // 5개 아이템이 고정되도록 설정
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
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        textStyle: const TextStyle(fontSize: 20), 
      ),
      child: Text(title),
    );
  }
}


class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('마이페이지 화면', style: TextStyle(fontSize: 24, color: Colors.white)));
  }
}

// 새로 추가된 단어장 화면
class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('단어장 화면', style: TextStyle(fontSize: 24, color: Colors.white)));
  }
}

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('게시판 화면', style: TextStyle(fontSize: 24, color: Colors.white)));
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('메뉴 화면', style: TextStyle(fontSize: 24, color: Colors.white)));
  }
}


// 문자 학습 화면
class CharacterLearningScreen extends StatelessWidget {
  const CharacterLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문자 학습'),
      ),
      body: const Center(
        child: Text(
          '여기에 문자 학습 콘텐츠가 표시됩니다.',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
