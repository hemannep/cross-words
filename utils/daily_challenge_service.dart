import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'crossword_generator.dart';

class DailyChallengeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'dailyCrosswordChallenges';

  static final Map<String, CrosswordGame> _cache = {};

  static Future<CrosswordGame> getTodayChallenge() async {
    final today = _getTodayDateString();
    return _getChallengeForDate(today);
  }

  static Future<CrosswordGame> getChallengeForDate(DateTime date) async {
    final dateString = _formatDate(date);
    return _getChallengeForDate(dateString);
  }

  static Future<CrosswordGame> _getChallengeForDate(String dateString) async {
    if (_cache.containsKey(dateString)) {
      return _cache[dateString]!;
    }

    try {
      print('🔍 Checking Firebase for crossword challenge: $dateString');
      final doc =
          await _firestore.collection(_collection).doc(dateString).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('✅ FOUND crossword challenge in Firebase for $dateString');
        final game = _parseCrosswordGame(data);
        _cache[dateString] = game;
        return game;
      } else {
        print('⚠️ Challenge does NOT exist for $dateString');
        print('🎲 AUTO-GENERATING new crossword challenge...');
        final challenge = _generateNewChallenge(dateString);
        await _saveChallengeToFirebase(dateString, challenge);
        _cache[dateString] = challenge;
        print('✅ Crossword challenge auto-generated and saved!');
        return challenge;
      }
    } catch (e) {
      print('❌ ERROR: $e');
      return _generateNewChallenge(dateString);
    }
  }

  static Future<bool> hasUserCompletedChallenge(
    String userId,
    String dateString,
  ) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(dateString)
          .collection('completions')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  static Future<void> markChallengeCompleted(
    String userId,
    String dateString,
    int score,
    int timeSpent,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(dateString)
          .collection('completions')
          .doc(userId)
          .set({
        'userId': userId,
        'score': score,
        'timeSpent': timeSpent,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking completion: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLeaderboardForDate(
    String dateString,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .doc(dateString)
          .collection('completions')
          .orderBy('score', descending: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTodayLeaderboard() async {
    return getLeaderboardForDate(_getTodayDateString());
  }

  static Future<void> generateAndSaveChallengeToFirebase(
    String dateString,
  ) async {
    try {
      final existing =
          await _firestore.collection(_collection).doc(dateString).get();
      if (existing.exists) {
        print('⚠️ Crossword challenge already exists for $dateString');
        return;
      }
      final challenge = _generateNewChallenge(dateString);
      await _saveChallengeToFirebase(dateString, challenge);
      print('✅ SAVED to Firebase!');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  static CrosswordGame _generateNewChallenge(String dateString) {
    // Use date as seed so the same date always produces the same puzzle locally
    // (in addition to being saved on Firebase for global consistency)
    final seed = dateString.hashCode;
    final difficulties = [
      'Newbie',
      'Easy',
      'Regular',
      'Hard',
      'Expert',
    ];
    final selectedDifficulty = difficulties[seed.abs() % difficulties.length];
    print('🎲 Daily difficulty: $selectedDifficulty');
    return CrosswordGenerator.generate(selectedDifficulty, seed: seed);
  }

  static Future<void> _saveChallengeToFirebase(
    String dateString,
    CrosswordGame game,
  ) async {
    try {
      await _firestore.collection(_collection).doc(dateString).set({
        'date': dateString,
        'size': game.size,
        'solution': jsonEncode(game.solution),
        'numbers': jsonEncode(game.numbers),
        'isBlack': jsonEncode(game.isBlack),
        'clues': jsonEncode(game.clues.map((c) => c.toJson()).toList()),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error saving challenge: $e');
      rethrow;
    }
  }

  static CrosswordGame _parseCrosswordGame(Map<String, dynamic> data) {
    try {
      final size = data['size'] as int;
      final solutionString = data['solution'] as String;
      final numbersString = data['numbers'] as String;
      final isBlackString = data['isBlack'] as String;
      final cluesString = data['clues'] as String;

      final solution = List<List<String>>.from(
        (jsonDecode(solutionString) as List)
            .map((row) => List<String>.from((row as List).cast<String>())),
      );
      final numbers = List<List<int>>.from(
        (jsonDecode(numbersString) as List)
            .map((row) => List<int>.from((row as List).cast<int>())),
      );
      final isBlack = List<List<bool>>.from(
        (jsonDecode(isBlackString) as List)
            .map((row) => List<bool>.from((row as List).cast<bool>())),
      );
      final clues = (jsonDecode(cluesString) as List)
          .map((c) => CrosswordClue.fromJson(c as Map<String, dynamic>))
          .toList();

      // Build empty board same shape as solution
      final board = List.generate(size, (_) => List.filled(size, ''));

      return CrosswordGame(
        size: size,
        solution: solution,
        board: board,
        numbers: numbers,
        isBlack: isBlack,
        clues: clues,
      );
    } catch (e) {
      print('❌ Error parsing crossword: $e');
      return CrosswordGenerator.generate('Easy');
    }
  }

  static String _getTodayDateString() => _formatDate(DateTime.now());

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static Future<dynamic> hasCompletedToday() async {}
}
