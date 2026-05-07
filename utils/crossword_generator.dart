import 'dart:math';

class CrosswordClue {
  final int number;
  final String word;
  final String clue;
  final int row;
  final int col;
  final bool isAcross;

  CrosswordClue({
    required this.number,
    required this.word,
    required this.clue,
    required this.row,
    required this.col,
    required this.isAcross,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'word': word,
        'clue': clue,
        'row': row,
        'col': col,
        'isAcross': isAcross,
      };

  factory CrosswordClue.fromJson(Map<String, dynamic> json) => CrosswordClue(
        number: json['number'] as int,
        word: json['word'] as String,
        clue: json['clue'] as String,
        row: json['row'] as int,
        col: json['col'] as int,
        isAcross: json['isAcross'] as bool,
      );
}

class CrosswordGame {
  final int size;
  final List<List<String>> solution; // empty string = black cell
  final List<List<String>> board; // user's input
  final List<List<int>> numbers; // clue numbers per cell, 0 = none
  final List<List<bool>> isBlack;
  final List<CrosswordClue> clues;

  CrosswordGame({
    required this.size,
    required this.solution,
    required this.board,
    required this.numbers,
    required this.isBlack,
    required this.clues,
  });

  List<CrosswordClue> get acrossClues => clues.where((c) => c.isAcross).toList()
    ..sort((a, b) => a.number.compareTo(b.number));

  List<CrosswordClue> get downClues => clues.where((c) => !c.isAcross).toList()
    ..sort((a, b) => a.number.compareTo(b.number));

  void operator [](String other) {}

  static fromJson(void challenge) {}
}

/// Word bank organized by length and difficulty
/// Each entry: word -> clue
class WordBank {
  // Easy words (3-5 letters, common)
  static const Map<String, String> easyWords = {
    'CAT': 'Feline pet',
    'DOG': 'Loyal companion',
    'SUN': 'Star at center of solar system',
    'MOON': 'Earth\'s natural satellite',
    'STAR': 'Twinkling night light',
    'TREE': 'Has leaves and trunk',
    'BOOK': 'Pages bound together',
    'FISH': 'Swims in water',
    'BIRD': 'Has wings and feathers',
    'CAKE': 'Birthday dessert',
    'MILK': 'White dairy drink',
    'RAIN': 'Water from clouds',
    'SNOW': 'Cold white precipitation',
    'WIND': 'Moving air',
    'FIRE': 'Hot flames',
    'ROCK': 'Solid mineral mass',
    'SAND': 'Beach grains',
    'LAKE': 'Body of fresh water',
    'ROAD': 'Path for vehicles',
    'DOOR': 'Entrance to a room',
    'CHAIR': 'Place to sit',
    'TABLE': 'Has four legs and a top',
    'HOUSE': 'Place to live',
    'APPLE': 'Red or green fruit',
    'BREAD': 'Baked from flour',
    'WATER': 'H2O',
    'GREEN': 'Color of grass',
    'HAPPY': 'Feeling joy',
    'SMILE': 'Curved lips of joy',
    'LAUGH': 'Sound of joy',
    'CLOUD': 'Sky puff',
    'OCEAN': 'Vast salt water',
    'RIVER': 'Flowing water',
    'BEACH': 'Sandy shore',
    'PLANT': 'Grows from soil',
    'MUSIC': 'Organized sound',
    'DANCE': 'Move to music',
    'SLEEP': 'Nightly rest',
    'DREAM': 'Sleep vision',
    'LIGHT': 'Opposite of dark',
  };

  // Medium words (4-7 letters)
  static const Map<String, String> mediumWords = {
    'PLANET': 'Orbits a star',
    'GARDEN': 'Where plants grow',
    'WINDOW': 'Glass opening',
    'BRIDGE': 'Crosses a gap',
    'CASTLE': 'Royal fortress',
    'FOREST': 'Many trees',
    'ANIMAL': 'Living creature',
    'FRIEND': 'Close companion',
    'FAMILY': 'Related people',
    'SCHOOL': 'Place of learning',
    'PENCIL': 'Writing tool with eraser',
    'COFFEE': 'Morning brew',
    'WINTER': 'Cold season',
    'SUMMER': 'Hot season',
    'SPRING': 'Season of bloom',
    'AUTUMN': 'Fall season',
    'NATURE': 'The natural world',
    'ROCKET': 'Space vehicle',
    'SCIENCE': 'Study of the world',
    'MUSEUM': 'House of artifacts',
    'GUITAR': 'Six-string instrument',
    'PIANO': 'Keyboard instrument',
    'VIOLIN': 'Bowed string instrument',
    'DOCTOR': 'Medical professional',
    'TEACHER': 'Educator',
    'STUDENT': 'Learner',
    'LIBRARY': 'House of books',
    'KITCHEN': 'Where food is cooked',
    'BEDROOM': 'Where you sleep',
    'CAMERA': 'Captures images',
    'PHOTO': 'Captured image',
    'PAINT': 'Artist\'s medium',
    'BRUSH': 'Painter\'s tool',
    'CANVAS': 'Painting surface',
    'PUZZLE': 'Brain teaser',
    'RIDDLE': 'Mind teaser',
    'TRAVEL': 'Go on a journey',
    'ISLAND': 'Land surrounded by water',
    'DESERT': 'Dry sandy region',
    'JUNGLE': 'Dense tropical forest',
  };

  // Hard words (5-8 letters)
  static const Map<String, String> hardWords = {
    'MYSTERY': 'Unsolved puzzle',
    'JOURNEY': 'Long trip',
    'KINGDOM': 'Realm of a king',
    'FREEDOM': 'State of liberty',
    'COURAGE': 'Bravery',
    'WISDOM': 'Deep knowledge',
    'HARMONY': 'Pleasing combination',
    'JUSTICE': 'Fair treatment',
    'VICTORY': 'Triumphant win',
    'GALAXY': 'Star system',
    'COMET': 'Icy space body',
    'ECLIPSE': 'Celestial blockage',
    'AURORA': 'Northern lights',
    'GLACIER': 'Slow ice river',
    'VOLCANO': 'Erupting mountain',
    'TSUNAMI': 'Giant ocean wave',
    'PYRAMID': 'Egyptian tomb',
    'SPHINX': 'Mythical creature',
    'PHOENIX': 'Reborn firebird',
    'DRAGON': 'Mythical fire beast',
    'WIZARD': 'Magic user',
    'KNIGHT': 'Armored warrior',
    'CASTLE': 'Royal stronghold',
    'EMPIRE': 'Vast realm',
    'ANCIENT': 'Very old',
    'MODERN': 'Of the present',
    'FUTURE': 'Time ahead',
    'HISTORY': 'Study of the past',
    'SCIENCE': 'Knowledge pursuit',
    'MACHINE': 'Mechanical device',
    'COMPUTER': 'Electronic brain',
    'NETWORK': 'Connected system',
    'PROGRAM': 'Coded instructions',
    'WEBSITE': 'Internet location',
    'MEMORY': 'Mental recall',
    'THOUGHT': 'Mental idea',
    'EMOTION': 'Feeling',
    'MIRACLE': 'Wondrous event',
    'TREASURE': 'Hoarded wealth',
    'DIAMOND': 'Precious stone',
  };

  // Expert words (6-9 letters, less common)
  static const Map<String, String> expertWords = {
    'ELOQUENT': 'Fluently expressive',
    'SERENITY': 'Calm peacefulness',
    'INTRIGUE': 'Curious interest',
    'RADIANT': 'Brightly shining',
    'PROFOUND': 'Deeply meaningful',
    'TRANQUIL': 'Peacefully quiet',
    'WHIMSICAL': 'Playfully fanciful',
    'RESILIENT': 'Bounces back',
    'ETHEREAL': 'Heavenly light',
    'LUMINOUS': 'Glowing brightly',
    'VIBRANT': 'Full of energy',
    'MAJESTIC': 'Grandly impressive',
    'PERPETUAL': 'Never-ending',
    'ENIGMATIC': 'Mysteriously puzzling',
    'PARADIGM': 'Model example',
    'SYNERGY': 'Combined effect',
    'NEBULA': 'Cosmic dust cloud',
    'COSMOS': 'The universe',
    'QUANTUM': 'Tiny physics unit',
    'PRISM': 'Light splitter',
  };

  static Map<String, String> getWordsForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Newbie':
      case 'Easy':
        return easyWords;
      case 'Regular':
        return {...easyWords, ...mediumWords};
      case 'Hard':
        return mediumWords;
      case 'Expert':
        return {...mediumWords, ...hardWords};
      case 'Professional':
        return hardWords;
      case 'Extreme':
        return {...hardWords, ...expertWords};
      default:
        return easyWords;
    }
  }
}

/// Generates a crossword puzzle by placing words on a grid with crossings
class CrosswordGenerator {
  static const int defaultSize = 13;

  static CrosswordGame generate(String difficulty, {int? seed}) {
    final size = _gridSizeForDifficulty(difficulty);
    final targetWords = _targetWordCountForDifficulty(difficulty);
    final wordPool = WordBank.getWordsForDifficulty(difficulty);

    final rand = seed != null ? Random(seed) : Random();

    // Try a few times to make a good grid
    CrosswordGame? best;
    int bestCount = 0;

    for (int attempt = 0; attempt < 8; attempt++) {
      final game = _attemptBuild(
          size, wordPool, targetWords, Random(rand.nextInt(1 << 30)));
      if (game.clues.length > bestCount) {
        best = game;
        bestCount = game.clues.length;
        if (bestCount >= targetWords) break;
      }
    }

    return best!;
  }

  static int _gridSizeForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Newbie':
        return 9;
      case 'Easy':
        return 10;
      case 'Regular':
        return 11;
      case 'Hard':
        return 12;
      case 'Expert':
        return 13;
      case 'Professional':
        return 14;
      case 'Extreme':
        return 15;
      default:
        return 11;
    }
  }

  static int _targetWordCountForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Newbie':
        return 6;
      case 'Easy':
        return 8;
      case 'Regular':
        return 10;
      case 'Hard':
        return 12;
      case 'Expert':
        return 14;
      case 'Professional':
        return 16;
      case 'Extreme':
        return 18;
      default:
        return 10;
    }
  }

  static CrosswordGame _attemptBuild(
    int size,
    Map<String, String> wordPool,
    int targetWords,
    Random rand,
  ) {
    // Initialize empty grid
    final grid = List.generate(size, (_) => List.filled(size, ''));

    // Sort words by length (longer first - they're easier to place)
    final sortedWords = wordPool.entries
        .where((e) => e.key.length <= size && e.key.length >= 3)
        .toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    sortedWords.shuffle(rand);

    final placedWords = <_PlacedWord>[];

    // Place first word horizontally near the center
    if (sortedWords.isNotEmpty) {
      final first = sortedWords.first;
      final startRow = size ~/ 2;
      final startCol = (size - first.key.length) ~/ 2;
      _writeWord(grid, first.key, startRow, startCol, true);
      placedWords.add(_PlacedWord(
        word: first.key,
        clue: first.value,
        row: startRow,
        col: startCol,
        isAcross: true,
      ));
      sortedWords.removeAt(0);
    }

    // Try to place remaining words by finding crossings
    for (final entry in sortedWords) {
      if (placedWords.length >= targetWords) break;

      final word = entry.key;
      final placement = _findBestPlacement(grid, word, size, rand);
      if (placement != null) {
        _writeWord(
            grid, word, placement.row, placement.col, placement.isAcross);
        placedWords.add(_PlacedWord(
          word: word,
          clue: entry.value,
          row: placement.row,
          col: placement.col,
          isAcross: placement.isAcross,
        ));
      }
    }

    // Trim grid to bounding box and rebuild
    return _finalize(grid, placedWords, size);
  }

  static _Placement? _findBestPlacement(
    List<List<String>> grid,
    String word,
    int size,
    Random rand,
  ) {
    final candidates = <_Placement>[];

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        for (int i = 0; i < word.length; i++) {
          // Try across
          final startCol = c - i;
          if (startCol >= 0 && startCol + word.length <= size) {
            if (_canPlace(grid, word, r, startCol, true, size)) {
              candidates.add(_Placement(row: r, col: startCol, isAcross: true));
            }
          }
          // Try down
          final startRow = r - i;
          if (startRow >= 0 && startRow + word.length <= size) {
            if (_canPlace(grid, word, startRow, c, false, size)) {
              candidates
                  .add(_Placement(row: startRow, col: c, isAcross: false));
            }
          }
        }
      }
    }

    if (candidates.isEmpty) return null;
    candidates.shuffle(rand);
    return candidates.first;
  }

  static bool _canPlace(
    List<List<String>> grid,
    String word,
    int row,
    int col,
    bool isAcross,
    int size,
  ) {
    // Need at least one crossing
    int crossings = 0;

    for (int i = 0; i < word.length; i++) {
      final r = isAcross ? row : row + i;
      final c = isAcross ? col + i : col;
      final ch = word[i];
      final existing = grid[r][c];

      if (existing.isEmpty) {
        // Adjacent cells (perpendicular) must be empty to avoid touching
        if (isAcross) {
          if (r > 0 && grid[r - 1][c].isNotEmpty) return false;
          if (r < size - 1 && grid[r + 1][c].isNotEmpty) return false;
        } else {
          if (c > 0 && grid[r][c - 1].isNotEmpty) return false;
          if (c < size - 1 && grid[r][c + 1].isNotEmpty) return false;
        }
      } else {
        if (existing != ch) return false;
        crossings++;
      }
    }

    // Cell before start must be empty/out of bounds
    if (isAcross) {
      if (col > 0 && grid[row][col - 1].isNotEmpty) return false;
      if (col + word.length < size && grid[row][col + word.length].isNotEmpty)
        return false;
    } else {
      if (row > 0 && grid[row - 1][col].isNotEmpty) return false;
      if (row + word.length < size && grid[row + word.length][col].isNotEmpty)
        return false;
    }

    return crossings >= 1;
  }

  static void _writeWord(
    List<List<String>> grid,
    String word,
    int row,
    int col,
    bool isAcross,
  ) {
    for (int i = 0; i < word.length; i++) {
      final r = isAcross ? row : row + i;
      final c = isAcross ? col + i : col;
      grid[r][c] = word[i];
    }
  }

  static CrosswordGame _finalize(
    List<List<String>> grid,
    List<_PlacedWord> placedWords,
    int originalSize,
  ) {
    // Find bounding box
    int minR = originalSize, maxR = -1, minC = originalSize, maxC = -1;
    for (int r = 0; r < originalSize; r++) {
      for (int c = 0; c < originalSize; c++) {
        if (grid[r][c].isNotEmpty) {
          if (r < minR) minR = r;
          if (r > maxR) maxR = r;
          if (c < minC) minC = c;
          if (c > maxC) maxC = c;
        }
      }
    }

    if (maxR < 0) {
      // Empty - return minimal game
      return CrosswordGame(
        size: 1,
        solution: [
          ['']
        ],
        board: [
          ['']
        ],
        numbers: [
          [0]
        ],
        isBlack: [
          [true]
        ],
        clues: [],
      );
    }

    // Add 1 cell padding
    minR = (minR - 1).clamp(0, originalSize - 1);
    minC = (minC - 1).clamp(0, originalSize - 1);
    maxR = (maxR + 1).clamp(0, originalSize - 1);
    maxC = (maxC + 1).clamp(0, originalSize - 1);

    final newRows = maxR - minR + 1;
    final newCols = maxC - minC + 1;
    final size = newRows > newCols ? newRows : newCols;

    final solution = List.generate(size, (_) => List.filled(size, ''));
    final board = List.generate(size, (_) => List.filled(size, ''));
    final isBlack = List.generate(size, (_) => List.filled(size, true));

    for (int r = 0; r < newRows; r++) {
      for (int c = 0; c < newCols; c++) {
        final ch = grid[r + minR][c + minC];
        if (ch.isNotEmpty) {
          solution[r][c] = ch;
          isBlack[r][c] = false;
        }
      }
    }

    // Adjust word positions
    final adjustedWords = placedWords
        .map((w) => _PlacedWord(
              word: w.word,
              clue: w.clue,
              row: w.row - minR,
              col: w.col - minC,
              isAcross: w.isAcross,
            ))
        .toList();

    // Number the cells
    final numbers = List.generate(size, (_) => List.filled(size, 0));
    int currentNumber = 1;
    final cellNumbers = <String, int>{}; // "row,col" -> number

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (isBlack[r][c]) continue;
        final startsAcross =
            (c == 0 || isBlack[r][c - 1]) && c + 1 < size && !isBlack[r][c + 1];
        final startsDown =
            (r == 0 || isBlack[r - 1][c]) && r + 1 < size && !isBlack[r + 1][c];
        if (startsAcross || startsDown) {
          numbers[r][c] = currentNumber;
          cellNumbers['$r,$c'] = currentNumber;
          currentNumber++;
        }
      }
    }

    // Build clues with numbers
    final clues = <CrosswordClue>[];
    for (final w in adjustedWords) {
      final num = cellNumbers['${w.row},${w.col}'];
      if (num != null) {
        clues.add(CrosswordClue(
          number: num,
          word: w.word,
          clue: w.clue,
          row: w.row,
          col: w.col,
          isAcross: w.isAcross,
        ));
      }
    }

    return CrosswordGame(
      size: size,
      solution: solution,
      board: board,
      numbers: numbers,
      isBlack: isBlack,
      clues: clues,
    );
  }
}

class _PlacedWord {
  final String word;
  final String clue;
  final int row;
  final int col;
  final bool isAcross;

  _PlacedWord({
    required this.word,
    required this.clue,
    required this.row,
    required this.col,
    required this.isAcross,
  });
}

class _Placement {
  final int row;
  final int col;
  final bool isAcross;

  _Placement({required this.row, required this.col, required this.isAcross});
}
