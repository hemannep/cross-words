import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Ads/banner_ads.dart';
import '../../Ads/interstitial_ads.dart';
import '../../Ads/rewared_ads.dart';
import '../../utils/game_state.dart';
import '../../utils/crossword_generator.dart';
import '../../widgets/bottom_actions.dart';
import '../../widgets/letter_keyboard.dart';
import '../../widgets/clue_bar.dart';
import 'game_header.dart';
import 'pause_overlay.dart';
import 'board_display.dart';

class GameScreen extends StatefulWidget {
  final String difficulty;
  final bool isContinue;
  final bool isDailyChallenge;
  final DateTime? challengeDate;
  final CrosswordGame? customGame;

  const GameScreen({
    super.key,
    required this.difficulty,
    this.isContinue = false,
    this.isDailyChallenge = false,
    this.challengeDate,
    this.customGame,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _timer;
  bool _dialogShown = false;
  late NavigatorState _navigator;
  int _undoEraseCount = 0;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        _initializeGame();
        _hasInitialized = true;
      }
    });
  }

  void _initializeGame() {
    final gameState = context.read<GameState>();

    if (widget.isDailyChallenge && widget.customGame != null) {
      gameState.initDailyChallenge(widget.customGame!, widget.difficulty);
    } else {
      gameState.initGame(widget.difficulty, isContinue: widget.isContinue);
    }
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigator = Navigator.of(context);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final gameState = context.read<GameState>();
        gameState.incrementSeconds();

        bool isGameComplete = gameState.isBoardComplete();
        bool isGameOverByMistakes = gameState.checkGameOver();

        if ((isGameComplete || isGameOverByMistakes) && !_dialogShown) {
          _dialogShown = true;
          gameState.markGameOverShown();
          _showGameOverDialog(gameState);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleUndoErase(VoidCallback action) async {
    _undoEraseCount++;
    if (_undoEraseCount % 3 == 0) {
      await InterstitialAdHelper.showInterstitialAd();
    }
    action();
  }

  Future<void> _handleHint() async {
    final gameState = context.read<GameState>();
    if (RewardedAdHelper.isRewardedAdReady()) {
      await RewardedAdHelper.showRewardedAd(
        onRewardEarned: () => gameState.hint(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad not ready, please try again'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleRevealWord() async {
    final gameState = context.read<GameState>();
    if (RewardedAdHelper.isRewardedAdReady()) {
      await RewardedAdHelper.showRewardedAd(
        onRewardEarned: () => gameState.revealWord(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad not ready, please try again'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateClue(GameState gameState, {required bool next}) {
    final activeClue = gameState.activeClue;
    if (activeClue == null) return;
    final allClues = [
      ...gameState.game.acrossClues,
      ...gameState.game.downClues,
    ];
    final currentIndex = allClues.indexWhere(
      (c) => c.number == activeClue.number && c.isAcross == activeClue.isAcross,
    );
    if (currentIndex == -1) return;
    final newIndex = next
        ? (currentIndex + 1) % allClues.length
        : (currentIndex - 1 + allClues.length) % allClues.length;
    gameState.selectClue(allClues[newIndex]);
  }

  void _toggleDirection(GameState gameState) {
    if (gameState.selectedRow >= 0 && gameState.selectedCol >= 0) {
      gameState.selectCell(gameState.selectedRow, gameState.selectedCol);
    }
  }

  void _showGameOverDialog(GameState gameState) {
    if (!mounted) return;

    final isGameWon = gameState.isBoardComplete();
    final canContinue = gameState.canContinue();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isGameWon
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isGameWon
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    isGameWon ? Icons.check_circle : Icons.favorite_border,
                    color: isGameWon
                        ? Colors.green.shade500
                        : Colors.red.shade500,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isGameWon
                      ? '🎉 Congratulations! 🎉'
                      : (canContinue ? 'Game Over!' : 'Final Game Over!'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isGameWon
                      ? 'You solved the crossword perfectly!'
                      : (canContinue
                          ? "You've reached the maximum number of mistakes"
                          : 'No more chances left!'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isGameWon
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isGameWon
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: isGameWon
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                            size: 26,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Final Score',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isGameWon
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${gameState.score}',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: isGameWon
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _StatBadge(
                              icon: Icons.schedule_rounded,
                              label: gameState.formattedTime,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBadge(
                              icon: Icons.error_outline_rounded,
                              label: '${gameState.mistakes} mistakes',
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                if (!isGameWon && canContinue)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            if (RewardedAdHelper.isRewardedAdReady()) {
                              await RewardedAdHelper.showRewardedAd(
                                onRewardEarned: () {
                                  if (Navigator.of(dialogContext).canPop()) {
                                    _dialogShown = false;
                                    gameState.addExtraChance();
                                    Navigator.of(dialogContext).pop();
                                  }
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ad not ready'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            if (Navigator.of(dialogContext).canPop()) {
                              _timer?.cancel();
                              _dialogShown = false;
                              gameState.clearGameProgress();
                              Navigator.of(dialogContext).pop();
                              _navigator.pop();
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Home',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isGameWon
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        if (Navigator.of(dialogContext).canPop()) {
                          _timer?.cancel();
                          _dialogShown = false;
                          if (isGameWon) {
                            await gameState.completeGame();
                          }
                          gameState.clearGameProgress();
                          Navigator.of(dialogContext).pop();
                          _navigator.pop();
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Home',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _timer?.cancel();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _GameHeaderWidget(
                        onBack: () {
                          _timer?.cancel();
                          _navigator.pop();
                        },
                      ),
                      const SizedBox(height: 16),
                      const _BoardDisplayWidget(),
                      const SizedBox(height: 12),
                      _ClueBarWidget(
                        onPrevious: (gs) => _navigateClue(gs, next: false),
                        onNext: (gs) => _navigateClue(gs, next: true),
                        onToggleDirection: _toggleDirection,
                      ),
                      const SizedBox(height: 14),
                      _ControlsWidget(
                        onUndoErase: _handleUndoErase,
                        onRevealWord: _handleRevealWord,
                        onHint: _handleHint,
                      ),
                      const SizedBox(height: 14),
                      const _KeyboardWidget(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameHeaderWidget extends StatelessWidget {
  final VoidCallback onBack;

  const _GameHeaderWidget({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        return GameHeader(
          gameState: gameState,
          onBack: onBack,
          onPauseToggle: () => gameState.togglePause(),
        );
      },
    );
  }
}

class _BoardDisplayWidget extends StatelessWidget {
  const _BoardDisplayWidget();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        return BoardDisplay(gameState: gameState);
      },
    );
  }
}

class _ClueBarWidget extends StatelessWidget {
  final void Function(GameState) onPrevious;
  final void Function(GameState) onNext;
  final void Function(GameState) onToggleDirection;

  const _ClueBarWidget({
    required this.onPrevious,
    required this.onNext,
    required this.onToggleDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        return ClueBar(
          activeClue: gameState.activeClue,
          onPrevious: () => onPrevious(gameState),
          onNext: () => onNext(gameState),
          onToggleDirection: () => onToggleDirection(gameState),
        );
      },
    );
  }
}

class _ControlsWidget extends StatelessWidget {
  final Future<void> Function(VoidCallback) onUndoErase;
  final Future<void> Function() onRevealWord;
  final Future<void> Function() onHint;

  const _ControlsWidget({
    required this.onUndoErase,
    required this.onRevealWord,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        if (gameState.isPaused) {
          return PauseOverlay(
            onResume: () async {
              if (RewardedAdHelper.isRewardedAdReady()) {
                await RewardedAdHelper.showRewardedAd(
                  onRewardEarned: () => gameState.togglePause(),
                );
              } else {
                gameState.togglePause();
              }
            },
          );
        }

        return BottomActions(
          onUndo: () => onUndoErase(gameState.undo),
          onErase: () => onUndoErase(gameState.erase),
          onRevealWord: onRevealWord,
          onHint: onHint,
          canUndo: gameState.history.isNotEmpty,
        );
      },
    );
  }
}

class _KeyboardWidget extends StatelessWidget {
  const _KeyboardWidget();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        if (gameState.isPaused) return const SizedBox.shrink();
        return LetterKeyboard(
          onLetterTap: gameState.inputLetter,
          onBackspace: gameState.erase,
        );
      },
    );
  }
}
