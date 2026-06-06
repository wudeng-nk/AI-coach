import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final List<String>? sources;
  final List<String>? suggestions;
  final String? feedback;
  final ValueChanged<String>? onSuggestionTap;
  final void Function(String chatId, String feedback)? onFeedback;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.sources,
    this.suggestions,
    this.feedback,
    this.onSuggestionTap,
    this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),

            // Sources
            if (sources != null && sources!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: sources!.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.source_outlined, size: 10, color: Colors.blue[400]),
                        const SizedBox(width: 2),
                        Text(s, style: TextStyle(fontSize: 10, color: Colors.blue[700])),
                      ],
                    ),
                  )).toList(),
                ),
              ),

            // Feedback buttons (only for AI messages)
            if (!isUser && onFeedback != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FeedbackButton(
                      icon: Icons.thumb_up_outlined,
                      activeIcon: Icons.thumb_up,
                      isActive: feedback == 'helpful',
                      onTap: () => onFeedback?.call('', 'helpful'),
                    ),
                    const SizedBox(width: 4),
                    _FeedbackButton(
                      icon: Icons.thumb_down_outlined,
                      activeIcon: Icons.thumb_down,
                      isActive: feedback == 'unhelpful',
                      onTap: () => onFeedback?.call('', 'unhelpful'),
                    ),
                  ],
                ),
              ),

            // Suggestions
            if (suggestions != null && suggestions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: suggestions!.map((s) => ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 11)),
                    avatar: const Icon(Icons.lightbulb_outline, size: 14),
                    side: BorderSide(color: Colors.grey[300]!),
                    onPressed: () => onSuggestionTap?.call(s),
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          isActive ? activeIcon : icon,
          size: 14,
          color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey[400],
        ),
      ),
    );
  }
}
