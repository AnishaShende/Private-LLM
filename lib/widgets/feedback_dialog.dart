import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isSending,
      child: AlertDialog(
        title: const Text('Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Would you like to leave any feedback or message for Anisha?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Your message',
                border: OutlineInputBorder(),
              ),
            ),
            if (_isSending)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed:
                _isSending ? null : () => Navigator.of(context).pop(false),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: _isSending
                ? null
                : () async {
                    if (_feedbackController.text.trim().isEmpty) {
                      Navigator.of(context).pop(false);
                      return;
                    }

                    setState(() => _isSending = true);
                    final success = await FeedbackService.submitFeedback(
                      _feedbackController.text.trim(),
                    );

                    if (mounted) {
                      Navigator.of(context).pop(success);
                    }
                  },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
