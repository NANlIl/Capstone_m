import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WordDetailScreen extends StatelessWidget {
  final String bookId;
  final String bookName;

  const WordDetailScreen({super.key, required this.bookId, required this.bookName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vocabulary_books')
            .doc(bookId)
            .collection('words')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('아직 단어가 없습니다.'));
          }

          final wordDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: wordDocs.length,
            itemBuilder: (context, index) {
              final wordDoc = wordDocs[index];
              final wordData = wordDoc.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(wordDoc.id), // 각 항목을 고유하게 식별하기 위한 키
                direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로만 스와이프
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) { // 스와이프가 완료되면 호출
                  _deleteWord(wordDoc.id, bookId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('\'${wordData['word']}\' 단어를 삭제했습니다.')),
                  );
                },
                child: ListTile(
                  title: Text(wordData['word'] ?? ''),
                  subtitle: Text(wordData['meaning'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 단어 삭제 로직
  Future<void> _deleteWord(String wordId, String bookId) async {
    final bookRef = FirebaseFirestore.instance.collection('vocabulary_books').doc(bookId);

    // 트랜잭션을 사용하여 단어 삭제와 단어 개수 감소를 원자적으로 처리합니다.
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // 단어 문서 삭제
      transaction.delete(bookRef.collection('words').doc(wordId));
      // 단어장 문서의 wordCount 필드 1 감소
      transaction.update(bookRef, {'wordCount': FieldValue.increment(-1)});
    });
  }
}
