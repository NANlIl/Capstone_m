import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBookId;
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('단어를 추가하려면 로그인이 필요합니다.'));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const Text('1. 단어장 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('vocabulary_books')
                    .where('ownerUid', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();

                  var books = snapshot.data!.docs;
                  List<DropdownMenuItem<String>> dropdownItems = books.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc['name']),
                    );
                  }).toList();

                  dropdownItems.insert(0, const DropdownMenuItem(
                    value: '__NEW__',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text('새 단어장 만들기', style: TextStyle(color: Colors.blueAccent)),
                      ],
                    ),
                  ));

                  return DropdownButtonFormField<String>(
                    value: _selectedBookId,
                    hint: const Text('단어장을 선택하세요'),
                    items: dropdownItems,
                    onChanged: (value) async {
                      if (value == '__NEW__') {
                        final newBookName = await _showAddBookBottomSheet(context);
                        if (newBookName != null && newBookName.isNotEmpty) {
                          final newBookId = await _addVocabularyBook(newBookName);
                          // setState를 호출하지 않고 변수 값만 변경하여 불필요한 리빌드 방지
                          _selectedBookId = newBookId;
                          // DropdownButtonFormField는 스스로 UI를 업데이트하므로 화면 전체를 갱신할 필요 없음
                          _formKey.currentState?.validate(); // 선택이 완료되었음을 알려주기 위해 유효성 검사 트리거
                        } 
                      } else {
                        _selectedBookId = value;
                      }
                    },
                    validator: (value) => value == null || value == '__NEW__' ? '단어장을 선택해주세요.' : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('2. 단어 정보 입력', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wordController,
                decoration: const InputDecoration(labelText: '단어 (예: こんにちは)'),
                validator: (value) => value!.isEmpty ? '단어를 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _meaningController,
                decoration: const InputDecoration(labelText: '의미 (예: 안녕하세요)'),
                validator: (value) => value!.isEmpty ? '의미를 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: '추가 노트 (선택사항)'),
              ),
              const SizedBox(height: 32),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveWord,
                      child: const Text('단어 저장하기'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showAddBookBottomSheet(BuildContext context) {
    final bookNameController = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        // 위젯이 화면에서 사라질 때 컨트롤러를 정리합니다.
        // 단, 여기서는 _showAddBookBottomSheet 함수가 종료될 때이므로, 
        // 이 방식보다는 StatefulWidget으로 분리하는 것이 더 정석적인 방법입니다.
        // 하지만 현재 구조에서는 이 방법이 가장 간단합니다.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) bookNameController.dispose();
        });

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                onFieldSubmitted: (value) {
                  Navigator.of(context).pop(value.trim());
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(bookNameController.text.trim());
                },
                child: const Text('만들기'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // 바텀 시트가 닫힐 때 컨트롤러를 확실히 해제합니다.
      bookNameController.dispose();
    });
  }

  Future<String> _addVocabularyBook(String bookName) async {
    final user = FirebaseAuth.instance.currentUser!;
    final newBook = await FirebaseFirestore.instance.collection('vocabulary_books').add({
      'name': bookName,
      'ownerUid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'wordCount': 0,
    });
    return newBook.id;
  }

  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate() || _selectedBookId == null || _selectedBookId == '__NEW__') {
      // __NEW__ 상태에서도 저장이 눌리는 것을 방지
      _formKey.currentState!.validate();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser!;

    try {
      final wordData = {
        'word': _wordController.text,
        'meaning': _meaningController.text,
        'notes': _notesController.text,
        'addedAt': FieldValue.serverTimestamp(),
        'ownerUid': user.uid,
        'correctAnswers': 0,
        'totalAttempts': 0,
      };

      final bookRef = FirebaseFirestore.instance.collection('vocabulary_books').doc(_selectedBookId);
      await bookRef.collection('words').add(wordData);
      await bookRef.update({'wordCount': FieldValue.increment(1)});

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('단어가 성공적으로 저장되었습니다!')),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _wordController.clear();
    _meaningController.clear();
    _notesController.clear();
    setState(() {
      _selectedBookId = null;
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
