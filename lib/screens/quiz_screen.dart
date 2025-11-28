import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/fade_page_route.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('퀴즈를 만드시려면 로그인이 필요합니다.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('퀴즈 시작하기'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '퀴즈를 볼 단어장을 선택하세요.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vocabulary_books')
                  .where('ownerUid', isEqualTo: user.uid)
                  .where('wordCount', isGreaterThan: 0) // 단어가 하나 이상 있는 단어장만
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('퀴즈를 보려면 단어장에 단어를 1개 이상 추가해주세요.'));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final bookData = docs[index].data() as Map<String, dynamic>;
                    final bookId = docs[index].id;
                    final bookName = bookData['name'] as String;
                    final wordCount = bookData['wordCount'] ?? 0;

                    return ListTile(
                      title: Text(bookName),
                      subtitle: Text('$wordCount 단어'),
                      trailing: const Icon(Icons.quiz),
                      onTap: () {
                        Navigator.push(
                          context,
                          FadePageRoute(
                            child: WordQuizGameScreen(
                              bookId: bookId,
                              bookName: bookName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 퀴즈 게임이 진행될 화면 (뼈대)
class WordQuizGameScreen extends StatelessWidget {
  final String bookId;
  final String bookName;

  const WordQuizGameScreen({super.key, required this.bookId, required this.bookName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$bookName 퀴즈'),
      ),
      body: Center(
        child: Text('퀴즈 화면입니다! (단어장 ID: $bookId)'),
      ),
    );
  }
}
