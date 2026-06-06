import 'dart:async';
import 'package:flutter/material.dart';

import 'package:ai_coach/core/services/web_speech_service.dart';
import 'package:ai_coach/core/theme/app_colors.dart';

/// A microphone button that uses Web Speech API for voice input.
/// Tapping toggles listening; recognized text is emitted via [onTranscript].
class VoiceInputButton extends StatefulWidget {
  /// Called with the latest recognized transcript (intermediate + final).
  final ValueChanged<String> onTranscript;

  const VoiceInputButton({super.key, required this.onTranscript});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final _speech = WebSpeechService();
  bool _listening = false;
  StreamSubscription? _resultSub;
  StreamSubscription? _stateSub;

  @override
  void initState() {
    super.initState();
    _resultSub = _speech.onResult.listen((text) {
      widget.onTranscript(text);
    });
    _stateSub = _speech.onListeningChanged.listen((isListening) {
      if (mounted && isListening != _listening) {
        setState(() => _listening = isListening);
      }
    });
  }

  @override
  void dispose() {
    _resultSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (!_speech.isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('当前浏览器不支持语音输入'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_listening) {
      _speech.stopListening();
    } else {
      _speech.startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _listening
            ? AppColors.error.withValues(alpha: 0.1)
            : Colors.grey[200],
      ),
      child: IconButton(
        onPressed: _toggle,
        icon: Icon(
          _listening ? Icons.mic : Icons.mic_none_outlined,
          size: 20,
          color: _listening ? AppColors.error : AppColors.textSecondary,
        ),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(10),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
