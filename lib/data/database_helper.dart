import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 데이터 모델 클래스
class Kana {
  final int id;
  final String type;
  final String character;
  final String pronunciation;

  const Kana({
    required this.id,
    required this.type,
    required this.character,
    required this.pronunciation,
  });

  // 빈 칸을 표현하기 위한 가짜 Kana 객체
  static const empty = Kana(id: -1, type: '', character: '', pronunciation: '');

  factory Kana.fromMap(Map<String, dynamic> map) {
    return Kana(
      id: map['id'],
      type: map['type'],
      character: map['character'],
      pronunciation: map['pronunciation'],
    );
  }
}

class DatabaseHelper {
  // Singleton 패턴을 위한 코드
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDB();

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nihongo.db');
    debugPrint("DB 경로: $path");

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 데이터베이스 테이블을 생성하고 초기 데이터를 삽입하는 메소드
  Future<void> _onCreate(Database db, int version) async {
    // 1. 테이블 생성
    await db.execute('''
      CREATE TABLE kana (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL, -- 'hiragana' or 'katakana'
        character TEXT NOT NULL,
        pronunciation TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE kanji (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        character TEXT NOT NULL,
        meaning TEXT NOT NULL,
        onyomi TEXT,
        kunyomi TEXT,
        strokes INTEGER,
        jlpt_level INTEGER
      )
    ''');

    // 2. 애셋 JSON 파일 읽어오기
    final String response = await rootBundle.loadString('assets/data/kana.json');
    final data = await json.decode(response);

    // 3. 읽어온 데이터로 'kana' 테이블 채우기
    final batch = db.batch();
    for (var kana in data['hiragana']) {
      batch.insert('kana', {'type': 'hiragana', 'character': kana['character'], 'pronunciation': kana['pronunciation']});
    }
    for (var kana in data['katakana']) {
      batch.insert('kana', {'type': 'katakana', 'character': kana['character'], 'pronunciation': kana['pronunciation']});
    }
    await batch.commit(noResult: true);
  }

  // 50음도 표 순서 정의
  static const _hiraganaOrder = [
    'あ', 'い', 'う', 'え', 'お',
    'か', 'き', 'く', 'け', 'こ',
    'さ', 'し', 'す', 'せ', 'そ',
    'た', 'ち', 'つ', 'て', 'と',
    'な', 'に', 'ぬ', 'ね', 'の',
    'は', 'ひ', 'ふ', 'へ', 'ほ',
    'ま', 'み', 'む', 'め', 'も',
    'や', '',   'ゆ', '',   'よ',
    'ら', 'り', 'る', 'れ', 'ろ',
    'わ', '',   '',   '',   'を',
    'ん', '',   '',   '',   ''
  ];

  static const _katakanaOrder = [
    'ア', 'イ', 'ウ', 'エ', 'オ',
    'カ', 'キ', 'ク', 'ケ', 'コ',
    'サ', 'シ', 'ス', 'セ', 'ソ',
    'タ', 'チ', 'ツ', 'テ', 'ト',
    'ナ', 'ニ', 'ヌ', 'ネ', 'ノ',
    'ハ', 'ヒ', 'フ', 'ヘ', 'ホ',
    'マ', 'ミ', 'ム', 'メ', 'モ',
    'ヤ', '',   'ユ', '',   'ヨ',
    'ラ', 'リ', 'ル', 'レ', 'ロ',
    'ワ', '',   '',   '',   'ヲ',
    'ン', '',   '',   '',   ''
  ];

  // 'kana' 테이블에서 데이터를 50음도 표 순서에 맞게 읽기
  Future<List<Kana>> getKana(String type) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kana',
      where: 'type = ?',
      whereArgs: [type],
    );

    // DB에서 읽어온 데이터를 Map 형태로 변환 (빠른 조회를 위해)
    final kanaMap = {for (var map in maps) map['character']: Kana.fromMap(map)};

    // 정렬 순서 리스트 선택
    final orderList = (type == 'hiragana') ? _hiraganaOrder : _katakanaOrder;

    // 50음도 표 순서에 따라 최종 리스트 생성
    final orderedKanaList = <Kana>[];
    for (String char in orderList) {
      if (char.isEmpty) {
        // 순서 리스트에 빈 문자열이 있으면, 비어있는 Kana 객체를 추가
        orderedKanaList.add(Kana.empty);
      } else {
        // 해당하는 문자가 있으면 Map에서 찾아서 추가
        if (kanaMap.containsKey(char)) {
          orderedKanaList.add(kanaMap[char]!);
        }
      }
    }
    return orderedKanaList;
  }
}
