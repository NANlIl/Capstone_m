import 'package:flutter/material.dart';

// --- 1. 트렌디한 디자인을 위한 테마 정의 ---

class AppColors {
  static const Color primary = Color(0xFF5A67D8);
  static const Color background = Color(0xFFF7FAFC);
  static const Color textBlack = Color(0xFF2D3748);
  static const Color textGrey = Color(0xFF718096);
  static const Color headline = Color(0xFF1A202C);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
}

// --- 2. 부드러운 화면 전환(Fade) 애니메이션 효과 ---

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  FadePageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

void main() {
  runApp(const NihongoApp());
}

class NihongoApp extends StatelessWidget {
  const NihongoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nihongo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,

        // AppBar 테마
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textBlack,
          elevation: 0,
          shape: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
          titleTextStyle: TextStyle(
            color: AppColors.headline,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // 입력창 테마
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          labelStyle: TextStyle(color: AppColors.textGrey),
          hintStyle: TextStyle(color: AppColors.textGrey),
        ),

        // 버튼 테마
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),

        // 하단 네비게이션 바 테마
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textGrey,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// --- 3. 애니메이션이 적용된 시작 화면 ---

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Spacer(flex: 3),
            const Text(
              '일본어, nihongo와\n함께 시작해볼까요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headline,
                  height: 1.4),
            ),
            const Spacer(flex: 2),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, FadePageRoute(child: const SignUpScreen())),
                      child: const Text('시작하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12.0),
                    TextButton(
                      onPressed: () => Navigator.push(context, FadePageRoute(child: const LoginScreen())),
                      child: const Text('이미 계정이 있습니다'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }
}

// --- 회원가입 & 로그인 화면 ---

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextFormField(decoration: const InputDecoration(labelText: '아이디')),
            const SizedBox(height: 16.0),
            TextFormField(obscureText: true, decoration: const InputDecoration(labelText: '비밀번호')),
            const SizedBox(height: 16.0),
            TextFormField(obscureText: true, decoration: const InputDecoration(labelText: '비밀번호 확인')),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, FadePageRoute(child: const LoginScreen()));
              },
              child: const Text('회원가입 완료', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, FadePageRoute(child: const MainScreen())),
              child: const Text('게스트로 로그인 하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(decoration: const InputDecoration(labelText: '아이디')),
            const SizedBox(height: 16.0),
            TextFormField(obscureText: true, decoration: const InputDecoration(labelText: '비밀번호')),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, FadePageRoute(child: const MainScreen())),
              child: const Text('로그인', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextButton(onPressed: () => Navigator.pushReplacement(context, FadePageRoute(child: const MainScreen())), child: const Text('게스트로 로그인 하기')),
            TextButton(onPressed: () { /* TODO: 계정찾기 */ }, child: const Text('계정찾기')),
          ],
        ),
      ),
    );
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
      Navigator.push(context, FadePageRoute(child: const VocabularyFeatureScreen()));
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
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nihongo'),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack( // 부드러운 탭 전환을 위해 IndexedStack 사용
        index: _selectedIndex,
        children: widgetOptions,
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

// --- 탭별 화면들 ---

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        _buildMenuButton(context, '문자 학습', Icons.translate, () => Navigator.push(context, FadePageRoute(child: const CharacterLearningScreen()))),
        _buildMenuButton(context, '한자 학습', Icons.font_download, () { /* TODO */ }),
        _buildMenuButton(context, '단어 학습', Icons.style, () { /* TODO */ }),
        _buildMenuButton(context, '단어 퀴즈', Icons.quiz, () => Navigator.push(context, FadePageRoute(child: const QuizScreen()))),
        _buildMenuButton(context, '문법/예문 학습', Icons.short_text, () { /* TODO */ }),
        const Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),
        _buildMenuButton(context, '실력평가', Icons.leaderboard, () { /* TODO */ }, isPrimary: true),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, VoidCallback onPressed, {bool isPrimary = false}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: isPrimary ? AppColors.primary : AppColors.border, width: 1.5),
      ),
      color: isPrimary ? AppColors.primary.withAlpha(13) : AppColors.card,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Row(
            children: [
              Icon(icon, color: isPrimary ? AppColors.primary : AppColors.textGrey, size: 28),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.headline)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('마이페이지 화면', style: TextStyle(fontSize: 24, color: AppColors.textGrey)));
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('커뮤니티 화면', style: TextStyle(fontSize: 24, color: AppColors.textGrey)));
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('메뉴 화면', style: TextStyle(fontSize: 24, color: AppColors.textGrey)));
  }
}

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('퀴즈 화면', style: TextStyle(fontSize: 24, color: AppColors.textGrey)));
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('달력 화면', style: TextStyle(fontSize: 24, color: AppColors.textGrey)));
  }
}

// --- 단어장 기능 화면들 ---

class VocabularyListScreen extends StatelessWidget {
  const VocabularyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> vocabularyBooks = ['기초 단어', 'JLPT N3 단어', '비즈니스 일본어'];

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: vocabularyBooks.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(color: AppColors.border, width: 1),
            ),
            child: ListTile(
              title: Text(vocabularyBooks[index], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('150 단어'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () { /* TODO */ },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, FadePageRoute(child: const AddVocabularyBookScreen())),
        backgroundColor: AppColors.primary,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddVocabularyBookScreen extends StatelessWidget {
  const AddVocabularyBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새 단어장 추가')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(decoration: const InputDecoration(labelText: '단어장 이름')),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('만들기', style: TextStyle(fontWeight: FontWeight.bold)),
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
  final List<String> _vocabularyBooks = ['기초 단어', 'JLPT N3 단어', '비즈니스 일본어'];
  String? _selectedBook;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 화면 다른 곳 터치 시 키보드 숨기기
      child: SingleChildScrollView(
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
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 20.0),
            if (_selectedBook != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(decoration: const InputDecoration(labelText: '단어 (일본어)')),
                  const SizedBox(height: 16.0),
                  TextFormField(decoration: const InputDecoration(labelText: '의미 (한국어)')),
                  const SizedBox(height: 16.0),
                  TextFormField(decoration: const InputDecoration(labelText: '발음 (히라가나/가타카나/로마자)')),
                  const SizedBox(height: 16.0),
                  TextFormField(decoration: const InputDecoration(labelText: '설명 (예문 등)'), maxLines: 3),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: () { /* TODO: 단어 추가 로직 */ },
                    child: const Text('단어 추가하기', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// --- 문자 학습 기능 구현 ---

class Kana {
  final String character;
  final String pronunciation;

  const Kana({required this.character, required this.pronunciation});
}

// 가독성을 위해 행별로 그룹화 및 주석 추가
const hiraganaList = [
  // あ행
  Kana(character: 'あ', pronunciation: 'a'),
  Kana(character: 'い', pronunciation: 'i'),
  Kana(character: 'う', pronunciation: 'u'),
  Kana(character: 'え', pronunciation: 'e'),
  Kana(character: 'お', pronunciation: 'o'),
  // か행
  Kana(character: 'か', pronunciation: 'ka'),
  Kana(character: 'き', pronunciation: 'ki'),
  Kana(character: 'く', pronunciation: 'ku'),
  Kana(character: 'け', pronunciation: 'ke'),
  Kana(character: 'こ', pronunciation: 'ko'),
  // さ행
  Kana(character: 'さ', pronunciation: 'sa'),
  Kana(character: 'し', pronunciation: 'shi'),
  Kana(character: 'す', pronunciation: 'su'),
  Kana(character: 'せ', pronunciation: 'se'),
  Kana(character: 'そ', pronunciation: 'so'),
  // た행
  Kana(character: 'た', pronunciation: 'ta'),
  Kana(character: 'ち', pronunciation: 'chi'),
  Kana(character: 'つ', pronunciation: 'tsu'),
  Kana(character: 'て', pronunciation: 'te'),
  Kana(character: 'と', pronunciation: 'to'),
  // な행
  Kana(character: 'な', pronunciation: 'na'),
  Kana(character: 'に', pronunciation: 'ni'),
  Kana(character: 'ぬ', pronunciation: 'nu'),
  Kana(character: 'ね', pronunciation: 'ne'),
  Kana(character: 'の', pronunciation: 'no'),
  // は행
  Kana(character: 'は', pronunciation: 'ha'),
  Kana(character: 'ひ', pronunciation: 'hi'),
  Kana(character: 'ふ', pronunciation: 'fu'),
  Kana(character: 'へ', pronunciation: 'he'),
  Kana(character: 'ほ', pronunciation: 'ho'),
  // ま행
  Kana(character: 'ま', pronunciation: 'ma'),
  Kana(character: 'み', pronunciation: 'mi'),
  Kana(character: 'む', pronunciation: 'mu'),
  Kana(character: 'め', pronunciation: 'me'),
  Kana(character: 'も', pronunciation: 'mo'),
  // や행
  Kana(character: 'や', pronunciation: 'ya'),
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: 'ゆ', pronunciation: 'yu'),
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: 'よ', pronunciation: 'yo'),
  // ら행
  Kana(character: 'ら', pronunciation: 'ra'),
  Kana(character: 'り', pronunciation: 'ri'),
  Kana(character: 'る', pronunciation: 'ru'),
  Kana(character: 'れ', pronunciation: 're'),
  Kana(character: 'ろ', pronunciation: 'ro'),
  // わ행
  Kana(character: 'わ', pronunciation: 'wa'),
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: 'を', pronunciation: 'wo'),
  // ん
  Kana(character: 'ん', pronunciation: 'n'),
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: '', pronunciation: ''), // Placeholder
];

const katakanaList = [
  // ア행
  Kana(character: 'ア', pronunciation: 'a'),
  Kana(character: 'イ', pronunciation: 'i'),
  Kana(character: 'ウ', pronunciation: 'u'),
  Kana(character: 'エ', pronunciation: 'e'),
  Kana(character: 'オ', pronunciation: 'o'),
  // カ행
  Kana(character: 'カ', pronunciation: 'ka'),
  Kana(character: 'キ', pronunciation: 'ki'),
  Kana(character: 'ク', pronunciation: 'ku'),
  Kana(character: 'ケ', pronunciation: 'ke'),
  Kana(character: 'コ', pronunciation: 'ko'),
  // サ행
  Kana(character: 'サ', pronunciation: 'sa'),
  Kana(character: 'シ', pronunciation: 'shi'),
  Kana(character: 'ス', pronunciation: 'su'),
  Kana(character: 'セ', pronunciation: 'se'),
  Kana(character: 'ソ', pronunciation: 'so'),
  // タ행
  Kana(character: 'タ', pronunciation: 'ta'),
  Kana(character: 'チ', pronunciation: 'chi'),
  Kana(character: 'ツ', pronunciation: 'tsu'),
  Kana(character: 'テ', pronunciation: 'te'),
  Kana(character: 'ト', pronunciation: 'to'),
  // ナ행
  Kana(character: 'ナ', pronunciation: 'na'),
  Kana(character: 'ニ', pronunciation: 'ni'),
  Kana(character: 'ヌ', pronunciation: 'nu'),
  Kana(character: 'ネ', pronunciation: 'ne'),
  Kana(character: 'ノ', pronunciation: 'no'),
  // ハ행
  Kana(character: 'ハ', pronunciation: 'ha'),
  Kana(character: 'ヒ', pronunciation: 'hi'),
  Kana(character: 'フ', pronunciation: 'fu'),
  Kana(character: 'ヘ', pronunciation: 'he'),
  Kana(character: 'ホ', pronunciation: 'ho'),
  // マ행
  Kana(character: 'マ', pronunciation: 'ma'),
  Kana(character: 'ミ', pronunciation: 'mi'),
  Kana(character: 'ム', pronunciation: 'mu'),
  Kana(character: 'メ', pronunciation: 'me'),
  Kana(character: 'モ', pronunciation: 'mo'),
  // ヤ행
  Kana(character: 'ヤ', pronunciation: 'ya'),
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: 'ユ', pronunciation: 'yu'),
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: 'ヨ', pronunciation: 'yo'),
  // ラ행
  Kana(character: 'ラ', pronunciation: 'ra'),
  Kana(character: 'リ', pronunciation: 'ri'),
  Kana(character: 'ル', pronunciation: 'ru'),
  Kana(character: 'レ', pronunciation: 're'),
  Kana(character: 'ロ', pronunciation: 'ro'),
  // ワ행
  Kana(character: 'ワ', pronunciation: 'wa'),
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: 'ヲ', pronunciation: 'wo'),
  // ン
  Kana(character: 'ン', pronunciation: 'n'),
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: '', pronunciation: ''), // Placeholder
  Kana(character: '', pronunciation: ''), // Placeholder
];

class CharacterLearningScreen extends StatelessWidget {
  const CharacterLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('문자 학습')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildKanaMenuCard(
            context,
            title: '히라가나',
            description: '일본어의 가장 기본적인 문자입니다. 부드러운 곡선이 특징이에요.',
            onTap: () => Navigator.push(context, FadePageRoute(child: const KanaListScreen(title: '히라가나', kanaList: hiraganaList))),
          ),
          const SizedBox(height: 16),
          _buildKanaMenuCard(
            context,
            title: '가타카나',
            description: '주로 외래어나 의성어, 의태어를 표기할 때 사용해요.',
            onTap: () => Navigator.push(context, FadePageRoute(child: const KanaListScreen(title: '가타카나', kanaList: katakanaList))),
          ),
        ],
      ),
    );
  }

  Widget _buildKanaMenuCard(BuildContext context, {required String title, required String description, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.headline)),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(fontSize: 16, color: AppColors.textGrey)),
            ],
          ),
        ),
      ),
    );
  }
}

class KanaListScreen extends StatelessWidget {
  final String title;
  final List<Kana> kanaList;

  const KanaListScreen({super.key, required this.title, required this.kanaList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, FadePageRoute(child: FlashcardScreen(title: title, kanaList: kanaList.where((kana) => kana.character.isNotEmpty).toList())));
                    },
                    icon: const Icon(Icons.style, color: Colors.white, size: 20),
                    label: const Text('순서대로 학습', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final randomList = kanaList.where((kana) => kana.character.isNotEmpty).toList()..shuffle();
                      Navigator.push(context, FadePageRoute(child: FlashcardScreen(title: '$title 랜덤 학습', kanaList: randomList)));
                    },
                    icon: const Icon(Icons.shuffle, color: Colors.white, size: 20),
                    label: const Text('랜덤 학습', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: kanaList.length,
              itemBuilder: (context, index) {
                final kana = kanaList[index];
                if (kana.character.isEmpty) {
                  return Container(); // 빈 칸일 경우 아무것도 표시하지 않음
                }
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(color: AppColors.border, width: 1),
                  ),
                  child: InkWell(
                    onTap: () { /* TODO: 문자 선택 시 효과 (소리 재생 등) */ },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          kana.character,
                          style: const TextStyle(fontSize: 32, color: AppColors.headline),
                        ),
                        Text(
                          kana.pronunciation,
                          style: const TextStyle(fontSize: 16, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class FlashcardScreen extends StatefulWidget {
  final String title;
  final List<Kana> kanaList;

  const FlashcardScreen({super.key, required this.title, required this.kanaList});

  @override
  FlashcardScreenState createState() => FlashcardScreenState();
}

class FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;

  void _nextCard() {
    if (_currentIndex < widget.kanaList.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kana = widget.kanaList[_currentIndex];
    final progress = (_currentIndex + 1) / widget.kanaList.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            GestureDetector(
              onTap: _flipCard,
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isFlipped
                          ? Text(kana.pronunciation, key: const ValueKey('pronunciation'), style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: AppColors.primary))
                          : Text(kana.character, key: const ValueKey('character'), style: const TextStyle(fontSize: 100, color: AppColors.headline)),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: _currentIndex > 0 ? _previousCard : null, child: const Text('이전')),
                Text(
                  '${_currentIndex + 1} / ${widget.kanaList.length}',
                  style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: _currentIndex < widget.kanaList.length - 1 ? _nextCard : null, child: const Text('다음')),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
