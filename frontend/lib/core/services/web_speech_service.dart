import 'dart:async';
import 'dart:js_interop';

/// Web Speech API wrapper for Flutter Web.
/// Requires a small JS snippet in web/index.html.
class WebSpeechService {
  static final WebSpeechService _instance = WebSpeechService._();
  factory WebSpeechService() => _instance;
  WebSpeechService._();

  bool _isListening = false;
  bool get isListening => _isListening;

  final _onResultController = StreamController<String>.broadcast();
  final _onListeningChangedController = StreamController<bool>.broadcast();

  /// Emits recognized text (intermediate and final).
  Stream<String> get onResult => _onResultController.stream;

  /// Emits listening state changes.
  Stream<bool> get onListeningChanged => _onListeningChangedController.stream;

  /// Whether the browser supports SpeechRecognition.
  bool get isSupported {
    try {
      return _jsSpeechIsSupported();
    } catch (_) {
      return false;
    }
  }

  /// Start listening for speech input.
  void startListening({String language = 'zh-CN'}) {
    if (_isListening) return;
    try {
      _jsSpeechStart(language.toJS, _onResultCallback, _onEndCallback);
      _isListening = true;
      _onListeningChangedController.add(true);
    } catch (_) {
      _isListening = false;
      _onListeningChangedController.add(false);
    }
  }

  /// Stop listening.
  void stopListening() {
    if (!_isListening) return;
    try {
      _jsSpeechStop();
    } catch (_) {}
    _isListening = false;
    _onListeningChangedController.add(false);
  }

  // Callbacks invoked from JS
  void _handleResult(String text) {
    _onResultController.add(text);
  }

  void _handleEnd() {
    _isListening = false;
    _onListeningChangedController.add(false);
  }

  void dispose() {
    stopListening();
    _onResultController.close();
    _onListeningChangedController.close();
  }
}

// -- Top-level callbacks for JS interop ------------------------------------

void _jsOnResult(String text) => WebSpeechService()._handleResult(text);
void _jsOnEnd() => WebSpeechService()._handleEnd();

// Convert to JSFunction once
JSFunction get _onResultCallback => _jsOnResult.toJS;
JSFunction get _onEndCallback => _jsOnEnd.toJS;

// -- External JS functions (defined in web/index.html) ---------------------

@JS('window.__speechIsSupported')
external bool _jsSpeechIsSupported();

@JS('window.__speechStart')
external void _jsSpeechStart(JSString lang, JSFunction onResult, JSFunction onEnd);

@JS('window.__speechStop')
external void _jsSpeechStop();
