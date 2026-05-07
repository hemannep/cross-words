import 'package:flutter/material.dart';

class LetterKeyboard extends StatelessWidget {
  final Function(String) onLetterTap;
  final VoidCallback onBackspace;

  const LetterKeyboard({
    super.key,
    required this.onLetterTap,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    const row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
    const row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
    const row3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildRow(row1),
            const SizedBox(height: 8),
            _buildRow(row2),
            const SizedBox(height: 8),
            _buildBottomRow(row3),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> letters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters
          .map((l) => Expanded(child: _LetterKey(letter: l, onTap: onLetterTap)))
          .toList(),
    );
  }

  Widget _buildBottomRow(List<String> letters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...letters
            .map((l) => Expanded(child: _LetterKey(letter: l, onTap: onLetterTap))),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onBackspace,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.backspace_outlined,
                color: Colors.grey.shade700,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LetterKey extends StatefulWidget {
  final String letter;
  final Function(String) onTap;

  const _LetterKey({required this.letter, required this.onTap});

  @override
  State<_LetterKey> createState() => _LetterKeyState();
}

class _LetterKeyState extends State<_LetterKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => widget.onTap(widget.letter),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: _pressed
              ? LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                )
              : null,
          color: _pressed ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            widget.letter,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _pressed ? Colors.white : Colors.grey.shade800,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }
}
