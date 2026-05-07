import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'game_progress.dart';
import 'crossword_generator.dart';

class Move {
  final int r, c;
  final String previousValue;

  Move(this.r, this.c, this.previousValue);

  Map<String, dynamic> toJson() => {
        'r': r,
        'c': c,
        'previousValue': previousValue,
      };

  factory Move.fromJson(Map<String, dynamic> json) => Move(
        json['r'] as int,
        json['c'] as int,
        json['previousValue'] as String,
      );
}

class GameState extends ChangeNotifier {
  late CrosswordGame game;
  final List<Move> history = [];

  int _selectedRow = -1;
  int _selectedCol = -1;
  bool _isAcrossDirection = true;
  int? _activeClueNumber;

  int _score = 0;
  int _mistakes = 0;
  int _seconds = 0;
  bool _isPaused = false;
  bool _showGameOverDialog = false;
  int _maxMistakes = 5;
  int _continueCount = 0;

  String difficulty = "Newbie";
  bool hasGameInProgress = false;

  String _unlockUntil = "";

  late GameProgress gameProgress;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  GameState() {
    game = CrosswordGenerator.generate('Newbie', seed: 1);
    gameProgress = GameProgress();
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    await _loadGameProgress();
    await _loadContinueGame();
    _isInitialized = true;
  }

  Future<void> _loadGameProgress() async {
    _prefs = await SharedPreferences.getInstance();
    final progressJson = _prefs.getString('gameProgress');
    if (progressJson != null) {
      gameProgress = GameProgress.fromJson(jsonDecode(progressJson));
    } else {
      gameProgress = GameProgress();
    }
    _unlockUntil = _prefs.getString('unlockUntil') ?? "";
    notifyListeners();
  }

  Future<void> _saveGameProgress() async {
    await _prefs.setString('gameProgress', jsonEncode(gameProgress.toJson()));
  }

  Future<void> _loadContinueGame() async {
    try {
      final continueGameJson = _prefs.getString('continueGame');
      if (continueGameJson != null) {
        final data = jsonDecode(continueGameJson) as Map<String, dynamic>;

        difficulty = data['difficulty'] as String;
        _score = data['score'] as int;
        _mistakes = data['mistakes'] as int;
        _seconds = data['seconds'] as int;
        _maxMistakes = data['maxMistakes'] as int;
        _continueCount = data['continueCount'] as int;

        final size = data['size'] as int;
        final solutionList = data['solution'] as List;
        final boardList = data['board'] as List;
        final numbersList = data['numbers'] as List;
        final isBlackList = data['isBlack'] as List;
        final cluesList = data['clues'] as List;

        final solution = List<List<String>>.from(
          solutionList.map((row) => List<String>.from((row as List).cast<String>())),
        );
        final board = List<List<String>>.from(
          boardList.map((row) => List<String>.from((row as List).cast<String>())),
        );
        final numbers = List<List<int>>.from(
          numbersList.map((row) => List<int>.from((row as List).cast<int>())),
        );
        final isBlack = List<List<bool>>.from(
          isBlackList.map((row) => List<bool>.from((row as List).cast<bool>())),
        );
        final clues = cluesList
            .map((c) => CrosswordClue.fromJson(c as Map<String, dynamic>))
            .toList();

        game = CrosswordGame(
          size: size,
          solution: solution,
          board: board,
          numbers: numbers,
          isBlack: isBlack,
          clues: clues,
        );

        final historyJson = data['history'] as List;
        history.clear();
        history.addAll(historyJson
            .map((m) => Move.fromJson(m as Map<String, dynamic>)));

        hasGameInProgress = true;
      }
    } catch (e) {
      debugPrint('Error loading continue game: $e');
      await _clearContinueGame();
    }
    notifyListeners();
  }

  Future<void> _saveContinueGame() async {
    try {
      final data = {
        'difficulty': difficulty,
        'score': _score,
        'mistakes': _mistakes,
        'seconds': _seconds,
        'maxMistakes': _maxMistakes,
        'continueCount': _continueCount,
        'size': game.size,
        'solution': game.solution,
        'board': game.board,
        'numbers': game.numbers,
        'isBlack': game.isBlack,
        'clues': game.clues.map((c) => c.toJson()).toList(),
        'history': history.map((m) => m.toJson()).toList(),
      };
      await _prefs.setString('continueGame', jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving continue game: $e');
    }
  }

  Future<void> _clearContinueGame() async {
    await _prefs.remove('continueGame');
    hasGameInProgress = false;
  }

  // Getters
  int get selectedRow => _selectedRow;
  int get selectedCol => _selectedCol;
  bool get isAcrossDirection => _isAcrossDirection;
  int? get activeClueNumber => _activeClueNumber;
  int get score => _score;
  int get mistakes => _mistakes;
  int get seconds => _seconds;
  bool get isPaused => _isPaused;
  bool get showGameOverDialog => _showGameOverDialog;
  int get maxMistakes => _maxMistakes;
  int get continueCount => _continueCount;

  String get formattedTime {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  CrosswordClue? get activeClue {
    if (_activeClueNumber == null) return null;
    return game.clues.firstWhere(
      (c) => c.number == _activeClueNumber && c.isAcross == _isAcrossDirection,
      orElse: () => game.clues.firstWhere(
        (c) => c.number == _activeClueNumber,
        orElse: () => game.clues.first,
      ),
    );
  }

  bool _isDailyUnlockActive() {
    if (_unlockUntil.isEmpty) return false;
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final unlockDate = DateTime.tryParse(_unlockUntil);
    final todayDate = DateTime.tryParse(todayString);
    if (unlockDate == null || todayDate == null) return false;
    return todayDate.isBefore(unlockDate) ||
        todayDate.isAtSameMomentAs(unlockDate);
  }

  bool isDifficultyLocked(String difficultyName) {
    if (_isDailyUnlockActive()) return false;

    switch (difficultyName) {
      case 'Newbie':
        return false;
      case 'Easy':
        return gameProgress.newbieGames < 3;
      case 'Regular':
        return gameProgress.easyGames < 7;
      case 'Hard':
        return gameProgress.regularGames < 13;
      case 'Expert':
        return gameProgress.hardGames < 20;
      case 'Professional':
        return gameProgress.expertGames < 25;
      case 'Extreme':
        return gameProgress.professionalGames < 30;
      default:
        return false;
    }
  }

  DifficultyRequirement getDifficultyRequirement(String difficultyName) {
    switch (difficultyName) {
      case 'Easy':
        return DifficultyRequirement(
          name: 'Easy',
          previousDifficulty: 'Newbie',
          requiredGames: 3,
          currentGames: gameProgress.newbieGames,
        );
      case 'Regular':
        return DifficultyRequirement(
          name: 'Regular',
          previousDifficulty: 'Easy',
          requiredGames: 7,
          currentGames: gameProgress.easyGames,
        );
      case 'Hard':
        return DifficultyRequirement(
          name: 'Hard',
          previousDifficulty: 'Regular',
          requiredGames: 13,
          currentGames: gameProgress.regularGames,
        );
      case 'Expert':
        return DifficultyRequirement(
          name: 'Expert',
          previousDifficulty: 'Hard',
          requiredGames: 20,
          currentGames: gameProgress.hardGames,
        );
      case 'Professional':
        return DifficultyRequirement(
          name: 'Professional',
          previousDifficulty: 'Expert',
          requiredGames: 25,
          currentGames: gameProgress.expertGames,
        );
      case 'Extreme':
        return DifficultyRequirement(
          name: 'Extreme',
          previousDifficulty: 'Professional',
          requiredGames: 30,
          currentGames: gameProgress.professionalGames,
        );
      default:
        return DifficultyRequirement(
          name: difficultyName,
          previousDifficulty: '',
          requiredGames: 0,
          currentGames: 0,
        );
    }
  }

  void initGame(String diff, {bool isContinue = false}) {
    if (!isContinue) {
      difficulty = diff;
      game = CrosswordGenerator.generate(diff);
      history.clear();
      _selectedRow = -1;
      _selectedCol = -1;
      _isAcrossDirection = true;
      _activeClueNumber = null;
      _score = 0;
      _mistakes = 0;
      _seconds = 0;
      _maxMistakes = 5;
      _showGameOverDialog = false;
      _continueCount = 0;

      // Auto-select first cell
      _selectFirstAvailableCell();
    }
    _isPaused = false;
    hasGameInProgress = true;
    notifyListeners();
    _saveContinueGame();
  }

  void initDailyChallenge(CrosswordGame customGame, String diff) {
    _resetGameState();
    difficulty = diff;
    game = customGame;
    _selectFirstAvailableCell();
    notifyListeners();
  }

  void _resetGameState() {
    history.clear();
    _selectedRow = -1;
    _selectedCol = -1;
    _isAcrossDirection = true;
    _activeClueNumber = null;
    _score = 0;
    _mistakes = 0;
    _seconds = 0;
    _maxMistakes = 5;
    _showGameOverDialog = false;
    _continueCount = 0;
    _isPaused = false;
    hasGameInProgress = true;
  }

  void _selectFirstAvailableCell() {
    for (int r = 0; r < game.size; r++) {
      for (int c = 0; c < game.size; c++) {
        if (!game.isBlack[r][c]) {
          _selectedRow = r;
          _selectedCol = c;
          _updateActiveClue();
          return;
        }
      }
    }
  }

  void _updateActiveClue() {
    if (_selectedRow < 0 || _selectedCol < 0) return;
    if (game.isBlack[_selectedRow][_selectedCol]) return;

    // Find the start of the word in the current direction
    int r = _selectedRow;
    int c = _selectedCol;

    if (_isAcrossDirection) {
      while (c > 0 && !game.isBlack[r][c - 1]) {
        c--;
      }
    } else {
      while (r > 0 && !game.isBlack[r - 1][c]) {
        r--;
      }
    }

    final num = game.numbers[r][c];
    if (num != 0) {
      // Check if a clue exists in this direction
      final hasClue = game.clues.any(
        (cl) => cl.number == num && cl.isAcross == _isAcrossDirection,
      );
      if (hasClue) {
        _activeClueNumber = num;
      } else {
        // Switch direction
        _isAcrossDirection = !_isAcrossDirection;
        _updateActiveClue();
      }
    }
  }

  Future<void> completeGame() async {
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (gameProgress.lastPlayedDate.isEmpty) {
      gameProgress.streak = 1;
    } else if (gameProgress.lastPlayedDate == todayString) {
      // same day, no change
    } else {
      final lastDate = DateTime.parse(gameProgress.lastPlayedDate);
      final difference = today.difference(lastDate).inDays;
      if (difference == 1) {
        gameProgress.streak++;
      } else {
        gameProgress.streak = 1;
      }
    }

    gameProgress.lastPlayedDate = todayString;

    switch (difficulty) {
      case 'Newbie':
        gameProgress.newbieGames++;
        break;
      case 'Easy':
        gameProgress.easyGames++;
        break;
      case 'Regular':
        gameProgress.regularGames++;
        break;
      case 'Hard':
        gameProgress.hardGames++;
        break;
      case 'Expert':
        gameProgress.expertGames++;
        break;
      case 'Professional':
        gameProgress.professionalGames++;
        break;
      case 'Extreme':
        gameProgress.extremeGames++;
        break;
    }

    await _saveGameProgress();
    await _clearContinueGame();
    notifyListeners();
  }

  void selectCell(int r, int c) {
    if (_isPaused || _showGameOverDialog) return;
    if (game.isBlack[r][c]) return;

    if (_selectedRow == r && _selectedCol == c) {
      // Toggle direction
      _isAcrossDirection = !_isAcrossDirection;
    } else {
      _selectedRow = r;
      _selectedCol = c;
    }
    _updateActiveClue();
    notifyListeners();
  }

  void selectClue(CrosswordClue clue) {
    if (_isPaused || _showGameOverDialog) return;
    _selectedRow = clue.row;
    _selectedCol = clue.col;
    _isAcrossDirection = clue.isAcross;
    _activeClueNumber = clue.number;
    notifyListeners();
  }

  void inputLetter(String letter) {
    if (_selectedRow == -1 ||
        _isPaused ||
        _showGameOverDialog ||
        game.isBlack[_selectedRow][_selectedCol]) {
      return;
    }

    final upperLetter = letter.toUpperCase();
    history.add(Move(
      _selectedRow,
      _selectedCol,
      game.board[_selectedRow][_selectedCol],
    ));

    game.board[_selectedRow][_selectedCol] = upperLetter;

    if (game.solution[_selectedRow][_selectedCol] == upperLetter) {
      _score += 10;
    } else {
      _mistakes++;
      _score = (_score - 5).clamp(0, 99999);
    }

    _moveToNextCell();

    if (isBoardComplete()) {
      _showGameOverDialog = true;
    }

    if (_mistakes >= _maxMistakes) {
      _showGameOverDialog = true;
    }

    notifyListeners();
    _saveContinueGame();
  }

  void _moveToNextCell() {
    int r = _selectedRow;
    int c = _selectedCol;
    if (_isAcrossDirection) {
      if (c + 1 < game.size && !game.isBlack[r][c + 1]) {
        _selectedCol = c + 1;
      }
    } else {
      if (r + 1 < game.size && !game.isBlack[r + 1][c]) {
        _selectedRow = r + 1;
      }
    }
    _updateActiveClue();
  }

  void erase() {
    if (_selectedRow == -1 ||
        _isPaused ||
        _showGameOverDialog ||
        game.isBlack[_selectedRow][_selectedCol]) {
      return;
    }
    history.add(Move(
      _selectedRow,
      _selectedCol,
      game.board[_selectedRow][_selectedCol],
    ));
    game.board[_selectedRow][_selectedCol] = '';
    notifyListeners();
    _saveContinueGame();
  }

  void undo() {
    if (history.isEmpty || _isPaused || _showGameOverDialog) return;
    final m = history.removeLast();
    game.board[m.r][m.c] = m.previousValue;
    _selectedRow = m.r;
    _selectedCol = m.c;
    _updateActiveClue();
    notifyListeners();
    _saveContinueGame();
  }

  void hint() {
    if (_selectedRow == -1 ||
        _isPaused ||
        _showGameOverDialog ||
        game.isBlack[_selectedRow][_selectedCol]) {
      return;
    }
    history.add(Move(
      _selectedRow,
      _selectedCol,
      game.board[_selectedRow][_selectedCol],
    ));
    game.board[_selectedRow][_selectedCol] =
        game.solution[_selectedRow][_selectedCol];
    _score = (_score - 15).clamp(0, 99999);
    _moveToNextCell();
    notifyListeners();
    _saveContinueGame();
  }

  void revealWord() {
    if (_activeClueNumber == null) return;
    final clue = activeClue;
    if (clue == null) return;
    for (int i = 0; i < clue.word.length; i++) {
      final r = clue.isAcross ? clue.row : clue.row + i;
      final c = clue.isAcross ? clue.col + i : clue.col;
      if (game.board[r][c] != game.solution[r][c]) {
        history.add(Move(r, c, game.board[r][c]));
        game.board[r][c] = game.solution[r][c];
      }
    }
    _score = (_score - 30).clamp(0, 99999);
    if (isBoardComplete()) _showGameOverDialog = true;
    notifyListeners();
    _saveContinueGame();
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void incrementSeconds() {
    if (!_isPaused && !_showGameOverDialog) {
      _seconds++;
      notifyListeners();
      if (_seconds % 5 == 0) _saveContinueGame();
    }
  }

  void addExtraChance() {
    if (!canContinue()) return;
    _continueCount++;
    _maxMistakes += 3;
    _showGameOverDialog = false;
    _mistakes = 0;
    notifyListeners();
    _saveContinueGame();
  }

  bool canContinue() => _continueCount < 3;

  bool isBoardComplete() {
    for (int r = 0; r < game.size; r++) {
      for (int c = 0; c < game.size; c++) {
        if (game.isBlack[r][c]) continue;
        if (game.board[r][c] != game.solution[r][c]) return false;
      }
    }
    return true;
  }

  bool checkGameOver() {
    return _mistakes >= _maxMistakes || isBoardComplete();
  }

  Future<void> unlockAllForDay() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowString =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    _unlockUntil = tomorrowString;
    await _prefs.setString('unlockUntil', tomorrowString);
    notifyListeners();
  }

  String getUnlockExpiryTime() {
    if (_unlockUntil.isEmpty) return "";
    try {
      final unlockDate = DateTime.parse(_unlockUntil);
      final now = DateTime.now();
      final diff = unlockDate.difference(now);
      if (diff.isNegative) return "";
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      if (hours > 0) return "$hours h $minutes m left";
      return "$minutes m left";
    } catch (e) {
      return "";
    }
  }

  void markGameOverShown() {
    _showGameOverDialog = true;
  }

  void clearGameProgress() {
    hasGameInProgress = false;
    _showGameOverDialog = false;
    _isPaused = false;
    _clearContinueGame();
    notifyListeners();
  }

  void resetGameOverDialog() {
    _showGameOverDialog = false;
    notifyListeners();
  }
}
