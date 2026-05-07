import 'package:flutter/material.dart';

class BottomActions extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onErase;
  final VoidCallback onRevealWord;
  final VoidCallback onHint;
  final bool canUndo;

  const BottomActions({
    super.key,
    required this.onUndo,
    required this.onErase,
    required this.onRevealWord,
    required this.onHint,
    this.canUndo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.undo_rounded,
            label: "Undo",
            onTap: onUndo,
            enabled: canUndo,
          ),
          _ActionButton(
            icon: Icons.delete_outline_rounded,
            label: "Erase",
            onTap: onErase,
          ),
          _ActionButton(
            icon: Icons.auto_awesome_rounded,
            label: "Reveal",
            onTap: onRevealWord,
          ),
          _ActionButton(
            icon: Icons.lightbulb_outline_rounded,
            label: "Hint",
            onTap: onHint,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool showGreen = isPressed;

    return GestureDetector(
      onTapDown:
          widget.enabled ? (_) => setState(() => isPressed = true) : null,
      onTapUp:
          widget.enabled ? (_) => setState(() => isPressed = false) : null,
      onTapCancel:
          widget.enabled ? () => setState(() => isPressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: !widget.enabled
                  ? null
                  : showGreen
                      ? LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600
                          ],
                        )
                      : null,
              color: !widget.enabled
                  ? Colors.grey.shade200
                  : showGreen
                      ? null
                      : Colors.grey.shade100,
              boxShadow: !widget.enabled
                  ? []
                  : [
                      BoxShadow(
                        color: showGreen
                            ? Colors.green.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(
              widget.icon,
              size: 22,
              color: !widget.enabled
                  ? Colors.grey.shade400
                  : showGreen
                      ? Colors.white
                      : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: widget.enabled ? Colors.black87 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
