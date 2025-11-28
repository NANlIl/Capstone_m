import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/fade_page_route.dart';
import './word_detail_screen.dart';

class VocabularyListScreen extends StatelessWidget {
  const VocabularyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('단어장을 보려면 로그인이 필요합니다.'));
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
            return const Center(child: Text('아직 단어장이 없습니다. 우측 하단의 + 버튼으로 새 단어장을 만들어보세요!'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final bookData = docs[index].data() as Map<String, dynamic>;
              final bookId = docs[index].id;
              final bookName = bookData['name'] as String? ?? '이름 없는 단어장';
              final wordCount = bookData['wordCount'] ?? 0;

              return ListTile(
                title: Text(bookName),
                onTap: () {
                  Navigator.push(
                    context,
                    FadePageRoute(child: WordDetailScreen(bookId: bookId, bookName: bookName)),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$wordCount 단어', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, bookId, bookName);
                      },
                      splashRadius: 20,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBookBottomSheet(context); // 바텀 시트를 호출하도록 변경
        },
        child: const Icon(Icons.add),
        tooltip: '새 단어장 추가',
      ),
    );
  }

  // 단어장 추가를 위한 바텀 시트 UI
  void _showAddBookBottomSheet(BuildContext context) {
    final bookNameController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드가 올라올 때 UI가 가려지지 않도록 설정
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // 키보드 높이만큼 패딩 추가
            left: 24, right: 24, top: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                '새 단어장 만들기',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: bookNameController,
                decoration: const InputDecoration(labelText: '단어장 이름'),
                autofocus: true,
                onFieldSubmitted: (_) { // 키보드에서 완료 버튼을 눌렀을 때
                  if (bookNameController.text.trim().isNotEmpty) {
                    _addVocabularyBook(bookNameController.text.trim());
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (bookNameController.text.trim().isNotEmpty) {
                    _addVocabularyBook(bookNameController.text.trim());
                    Navigator.of(context).pop(); // 바텀 시트 닫기
                  }
                },
                child: const Text('만들기'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addVocabularyBook(String bookName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('vocabulary_books').add({
      'name': bookName,
      'ownerUid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'wordCount': 0,
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, String bookId, String bookName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('단어장 삭제'),
          content: Text('\'$bookName\' 단어장을 정말 삭제하시겠습니까?\n포함된 모든 단어가 영구적으로 삭제됩니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteVocabularyBook(context, bookId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVocabularyBook(BuildContext context, String bookId) async {
    final bookRef = FirebaseFirestore.instance.collection('vocabulary_books').doc(bookId);
    try {
      final wordsSnapshot = await bookRef.collection('words').get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in wordsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(bookRef);
      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('단어장이 성공적으로 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('단어장 삭제 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
}
