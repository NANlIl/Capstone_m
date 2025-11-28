import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _logout() async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: '로그아웃',
      content: '정말 로그아웃 하시겠습니까?',
      confirmText: '로그아웃',
    );

    if (confirmed == true) {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: '계정 탈퇴',
      content: '정말 계정을 탈퇴하시겠습니까?\n모든 단어장과 단어 데이터가 영구적으로 삭제되며, 이 작업은 되돌릴 수 없습니다.',
      confirmText: '탈퇴',
    );

    if (confirmed == true && _user != null) {
      try {
        // 1. 사용자의 모든 단어장 및 단어 데이터 삭제
        final booksSnapshot = await FirebaseFirestore.instance
            .collection('vocabulary_books')
            .where('ownerUid', isEqualTo: _user!.uid)
            .get();

        final batch = FirebaseFirestore.instance.batch();

        for (final bookDoc in booksSnapshot.docs) {
          final wordsSnapshot = await bookDoc.reference.collection('words').get();
          for (final wordDoc in wordsSnapshot.docs) {
            batch.delete(wordDoc.reference); // 단어 삭제
          }
          batch.delete(bookDoc.reference); // 단어장 삭제
        }

        // 2. (선택사항) users 컬렉션의 사용자 정보 문서 삭제
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(_user!.uid);
        batch.delete(userDocRef);

        await batch.commit();

        // 3. Firebase Auth에서 사용자 계정 삭제
        await _user!.delete();
        await GoogleSignIn().signOut(); // 로그아웃 처리

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('계정이 성공적으로 삭제되었습니다.')),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('계정 삭제 실패: ${e.message}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('데이터 삭제 중 오류가 발생했습니다: $e')),
          );
        }
      }
    }
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog( // const 키워드 제거
        title: const Text('앱 정보'),
        content: const Text('Nihongo v1.0.0\n\n개발자: rlaej'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _user!.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
                child: _user!.photoURL == null ? const Icon(Icons.person, size: 50) : null,
              ),
              const SizedBox(height: 16),
              Text(
                _user!.displayName ?? '이름 없음',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _user!.email ?? '이메일 정보 없음',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: _logout,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('앱 정보'),
            onTap: _showAppInfo,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
            title: Text('계정 탈퇴', style: TextStyle(color: Colors.red.shade700)),
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }
}
