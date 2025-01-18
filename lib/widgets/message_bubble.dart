import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';
import '../utils/formatters.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.5;

    return Column(
      crossAxisAlignment:
          message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: message.isUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: message.content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: message.isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSecondary,
                    ),
                    strong: TextStyle(
                      color: message.isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  MessageFormatter().formatTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: (message.isUser
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSecondary)
                        .withOpacity(0.7),
                  ),
                ),
                if (!message.isUser && message.generationTime != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Generated in ${MessageFormatter().formatGenerationTime(message.generationTime!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSecondary
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
