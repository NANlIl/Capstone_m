import 'package:flutter/material.dart';
import 'package:nihongo/data/database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

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

void main() async {
  debugPrint("--- main() 시작 ---");
  WidgetsFlutterBinding.ensureInitialized();

  // --- Firebase 초기화 ---
  debugPrint("--- Firebase 초기화 시작 ---");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("--- Firebase 초기화 완료 ---");

  runApp(const NihongoApp());
  debugPrint("--- runApp() 실행 완료 ---");
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
      home: const AuthGate(), // 앱의 시작점을 AuthGate로 변경
    );
  }
}

// --- 인증 상태에 따라 화면을 결정하는 위젯 ---
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 사용자가 로그인하지 않았으면 로그인 화면을 보여줍니다.
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // 사용자가 로그인했으면 메인 화면으로 이동합니다.
        return const MainScreen();
      },
    );
  }
}


// --- Google 로그인 화면 ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Google 로그인 흐름 시작
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // 사용자가 로그인 창을 닫은 경우
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. Google 계정으로부터 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Firebase에 사용자 인증
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 4. Firestore에 사용자 정보 저장 (첫 로그인 시에만)
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          userDoc.set({
            'displayName': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

    } catch (e) {
      // 오류 처리
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 중 오류가 발생했습니다: ${e.toString()}')),
        );
      }
    }
    // isLoading 상태는 AuthGate에 의해 화면이 전환되므로 여기서 false로 바꿀 필요가 없습니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.login), // 임시 아이콘으로 변경
                    label: const Text('Google 계정으로 로그인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
            const Spacer(flex: 1),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
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

  // 단어장 삭제 함수
  Future<void> _deleteVocabularyBook(BuildContext context, String bookId) async {
    // 확인 대화상자 표시
    final bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('단어장 삭제'),
          content: const Text('이 단어장을 정말 삭제하시겠습니까?\n단어장 안의 모든 단어가 함께 삭제됩니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // 취소
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // 삭제 확인
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // 사용자가 '삭제'를 확인했을 때만 실행
    if (confirmed == true) {
      try {
        final bookRef = FirebaseFirestore.instance.collection('vocabulary_books').doc(bookId);
        // 단어장 안의 모든 단어들을 먼저 삭제 (Batch-Commit)
        final wordsSnapshot = await bookRef.collection('words').get();
        final WriteBatch batch = FirebaseFirestore.instance.batch();
        for (final doc in wordsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        // 단어장 자체를 삭제
        await bookRef.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('단어장이 삭제되었습니다.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 중 오류가 발생했습니다: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('로그인이 필요합니다.'));
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vocabulary_books')
            .where('ownerUid', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('단어장을 추가해주세요.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final bookData = docs[index].data() as Map<String, dynamic>;
              final bookId = docs[index].id;
              final bookName = bookData['name'] as String;
              // 데이터에 'wordCount'가 없으면 0으로 처리
              final wordCount = bookData.containsKey('wordCount') ? bookData['wordCount'] as int : 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: const BorderSide(color: AppColors.border, width: 1),
                ),
                child: ListTile(
                  title: Text(bookName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  // <<<<<<< 바로 이 부분만 수정되었습니다!
                  subtitle: Text('$wordCount 단어'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteVocabularyBook(context, bookId);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('삭제'),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      FadePageRoute(
                        child: WordListScreen(
                          bookId: bookId,
                          bookName: bookName,
                        ),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, FadePageRoute(child: const AddVocabularyBookScreen())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddVocabularyBookScreen extends StatefulWidget {
  const AddVocabularyBookScreen({super.key});

  @override
  State<AddVocabularyBookScreen> createState() => _AddVocabularyBookScreenState();
}

class _AddVocabularyBookScreenState extends State<AddVocabularyBookScreen> {
  final _bookNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _bookNameController.dispose();
    super.dispose();
  }

  Future<void> _addVocabularyBook() async {
    if (_bookNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('단어장 이름을 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      await FirebaseFirestore.instance.collection('vocabulary_books').add({
        'name': _bookNameController.text.trim(),
        'ownerUid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'wordCount': 0, // <<<<<<< 수정된 부분
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('새 단어장이 추가되었습니다.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새 단어장 추가')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _bookNameController,
              decoration: const InputDecoration(labelText: '단어장 이름'),
            ),
            const SizedBox(height: 24.0),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _addVocabularyBook,
              child: const Text('만들기', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class WordListScreen extends StatelessWidget {
  final String bookId;
  final String bookName;

  const WordListScreen({super.key, required this.bookId, required this.bookName});

  // 단어 삭제 함수 (카운트 감소 포함)
  Future<void> _deleteWord(String wordId) async {
    final bookRef = FirebaseFirestore.instance.collection('vocabulary_books').doc(bookId);

    // 트랜잭션을 사용하여 데이터 일관성 보장
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.delete(bookRef.collection('words').doc(wordId));
      transaction.update(bookRef, {'wordCount': FieldValue.increment(-1)});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(bookName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vocabulary_books')
            .doc(bookId)
            .collection('words')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('아직 추가된 단어가 없습니다.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final word = docs[index];
              final wordData = word.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(word.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  await _deleteWord(word.id); // <<<<<<< 수정된 부분
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('\'${wordData['word']}\' 단어가 삭제되었습니다.')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(wordData['word'] as String),
                    subtitle: Text(wordData['meaning'] as String),
                  ),
                ),
              );
            },
          );
        },
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
  String? _selectedBookId;
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _pronunciationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 단어 추가 함수 (카운트 증가 포함)
  Future<void> _addWord() async {
    if (_selectedBookId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('단어장을 먼저 선택해주세요.')),
      );
      return;
    }
    if (_wordController.text.trim().isEmpty || _meaningController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('단어와 의미는 필수 입력 항목입니다.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final bookRef = FirebaseFirestore.instance.collection('vocabulary_books').doc(_selectedBookId);

      // 트랜잭션을 사용하여 데이터 일관성 보장
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 새 단어 추가
        transaction.set(bookRef.collection('words').doc(), {
          'word': _wordController.text.trim(),
          'meaning': _meaningController.text.trim(),
          'pronunciation': _pronunciationController.text.trim(),
          'description': _descriptionController.text.trim(),
          'ownerUid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 단어장 wordCount 필드 1 증가
        transaction.update(bookRef, {'wordCount': FieldValue.increment(1)});
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('새 단어가 추가되었습니다.')),
        );
        // 입력 필드 초기화
        _wordController.clear();
        _meaningController.clear();
        _pronunciationController.clear();
        _descriptionController.clear();
        FocusScope.of(context).unfocus();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vocabulary_books')
                  .where('ownerUid', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final books = snapshot.data!.docs.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(doc['name'] as String),
                  );
                }).toList();

                return DropdownButtonFormField<String>(
                  hint: const Text('단어장을 선택하세요'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBookId = newValue;
                    });
                  },
                  items: books,
                  decoration: const InputDecoration(),
                );
              },
            ),
            const SizedBox(height: 20.0),
            if (_selectedBookId != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _wordController,
                    decoration: const InputDecoration(labelText: '단어 (일본어)'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _meaningController,
                    decoration: const InputDecoration(labelText: '의미 (한국어)'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _pronunciationController,
                    decoration: const InputDecoration(labelText: '발음 (히라가나/가타카나/로마자)'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: '설명 (예문 등)'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32.0),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _addWord,
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
            onTap: () => Navigator.push(context, FadePageRoute(child: const KanaListScreen(title: '히라가나', type: 'hiragana'))),
          ),
          const SizedBox(height: 16),
          _buildKanaMenuCard(
            context,
            title: '가타카나',
            description: '주로 외래어나 의성어, 의태어를 표기할 때 사용해요.',
            onTap: () => Navigator.push(context, FadePageRoute(child: const KanaListScreen(title: '가타카나', type: 'katakana'))),
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

class KanaListScreen extends StatefulWidget {
  final String title;
  final String type; // 'hiragana' or 'katakana'

  const KanaListScreen({super.key, required this.title, required this.type});

  @override
  State<KanaListScreen> createState() => _KanaListScreenState();
}

class _KanaListScreenState extends State<KanaListScreen> {
  late Future<List<Kana>> _kanaListFuture;

  @override
  void initState() {
    super.initState();
    _kanaListFuture = DatabaseHelper.instance.getKana(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Kana>>(
        future: _kanaListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('데이터가 없습니다.'));
          }

          final kanaList = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, FadePageRoute(child: FlashcardScreen(title: widget.title, kanaList: kanaList)));
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
                          final randomList = [...kanaList].where((kana) => kana.character.isNotEmpty).toList()..shuffle();
                          Navigator.push(context, FadePageRoute(child: FlashcardScreen(title: '${widget.title} 랜덤 학습', kanaList: randomList)));
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
                      return Container(); // 빈 칸 렌더링
                    }
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(color: AppColors.border, width: 1),
                      ),
                      child: InkWell(
                        onTap: () { /* TODO */ },
                        borderRadius: BorderRadius.circular(12.0),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                kana.character,
                                style: const TextStyle(fontSize: 26, color: AppColors.headline),
                              ),
                              Text(
                                kana.pronunciation,
                                style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
    final filteredList = widget.kanaList.where((kana) => kana.character.isNotEmpty).toList();
    if (_currentIndex < filteredList.length - 1) {
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
    final filteredList = widget.kanaList.where((kana) => kana.character.isNotEmpty).toList();
    if (filteredList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('학습할 카드가 없습니다.')),
      );
    }

    // 현재 인덱스가 필터링된 리스트의 길이를 벗어나지 않도록 방지
    if (_currentIndex >= filteredList.length) {
      _currentIndex = filteredList.length - 1;
    }

    final kana = filteredList[_currentIndex];
    final progress = (_currentIndex + 1) / filteredList.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // 올바른 위치로 수정된 bottom 속성
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
                          ? Text(kana.pronunciation, key: ValueKey('pronunciation_${kana.id}'), style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: AppColors.primary))
                          : Text(kana.character, key: ValueKey('character_${kana.id}'), style: const TextStyle(fontSize: 100, color: AppColors.headline)),
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
                  '${_currentIndex + 1} / ${filteredList.length}',
                  style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: _currentIndex < filteredList.length - 1 ? _nextCard : null, child: const Text('다음')),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}