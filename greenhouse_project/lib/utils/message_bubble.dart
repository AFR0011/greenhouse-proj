import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final ThemeData theme;
  final String message;
  final bool isSender;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width * 0.4, // 40% of screen width
      ),
      child: Container(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color:
              isSender ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isSender ? const Radius.circular(12) : Radius.zero,
            bottomRight: isSender ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Text(
          message,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isSender
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
