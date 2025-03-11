import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:private_llm/utils/url_launch.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';
import '../utils/formatters.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String? highlight;
  final String? link;
  const MessageBubble(
      {super.key, required this.message, this.highlight, this.link});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final maxWidth = screenWidth * 0.5;
    final isSmallScreen = screenWidth < 600;
    // Adjust max width based on screen size
    final maxWidth = isSmallScreen ? screenWidth * 0.75 : screenWidth * 0.5;

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
                  data: formatContentForEmbeddedLinks(),
                  selectable: true,
                  onTapLink: (text, href, title) async {
                    if (href != null) {
                      final uri = Uri.parse(href);
                      if (await canLaunchUrl(uri)) {
                        await UrlLaunch(uri.toString()).launchUrl();
                      }
                    }
                  },
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
                    a: TextStyle(
                      // color: Colors.lightBlue[200],
                      decoration: TextDecoration.underline,
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

  String formatContentForEmbeddedLinks() {
    if (message.highlightedText == null ||
        message.links == null ||
        message.highlightedText!.isEmpty ||
        message.links!.isEmpty) {
      return message.content;
    }

    var formattedContent = message.content;
    for (var i = 0; i < message.highlightedText!.length; i++) {
      // debugPrint('highlighted text detected!!!!!!!!!!!!!!1');
      final highlight = message.highlightedText![i];
      final link = message.links![i];
      formattedContent =
          formattedContent.replaceAll(highlight, '*[$highlight]($link)*');
      // debugPrint('formattedContent: $formattedContent');
    }
    return formattedContent;
  }
}
