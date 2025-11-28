import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import './kana_quiz_screen.dart';
import './kana_sequential_quiz_screen.dart';

//--- 메인 메뉴 화면 ---
class CharacterLearningScreen extends StatelessWidget {
  const CharacterLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문자 학습'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildCharacterMenu(
            context,
            '히라가나 (ひらがな)',
            '일본어의 기본 문자입니다.',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KanaLearningScreen(type: 'hiragana'))),
          ),
          const SizedBox(height: 16),
          _buildCharacterMenu(
            context,
            '가타카나 (カタカナ)',
            '외래어나 강조할 때 사용하는 문자입니다.',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KanaLearningScreen(type: 'katakana'))),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterMenu(BuildContext context, String title, String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}


//--- 히라가나/가타카나 50음도 표 학습 화면 ---
class KanaLearningScreen extends StatefulWidget {
  final String type; // 'hiragana' 또는 'katakana'

  const KanaLearningScreen({super.key, required this.type});

  @override
  State<KanaLearningScreen> createState() => _KanaLearningScreenState();
}

class _KanaLearningScreenState extends State<KanaLearningScreen> {
  late Future<List<Kana>> _kanaFuture;

  @override
  void initState() {
    super.initState();
    _kanaFuture = DatabaseHelper.instance.getKana(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'hiragana' ? '히라가나' : '가타카나';

    return Scaffold(
      appBar: AppBar(
        title: Text('$title 학습'),
        actions: [
          IconButton(
            onPressed: () async {
              final kanaList = await _kanaFuture;
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KanaSequentialQuizScreen(kanaList: kanaList, title: title)),
                );
              }
            },
            icon: const Icon(Icons.format_list_numbered), 
            tooltip: '순서대로 퀴즈',
          ),
          IconButton(
            onPressed: () async {
              final kanaList = await _kanaFuture;
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KanaQuizScreen(kanaList: kanaList, title: title)),
                );
              }
            },
            icon: const Icon(Icons.shuffle), // 아이콘 변경
            tooltip: '랜덤으로 퀴즈',
          ),
        ],
      ),
      body: FutureBuilder<List<Kana>>(
        future: _kanaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('데이터를 불러올 수 없습니다.'));
          }

          final kanaList = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0,
            ),
            itemCount: kanaList.length,
            itemBuilder: (context, index) {
              final kana = kanaList[index];
              if (kana.id == -1) return const SizedBox.shrink();
              
              return Card(
                elevation: 1.0,
                child: InkWell(
                  onTap: () { /* 아무 동작 안함 */ },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(kana.character, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(kana.pronunciation, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
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
