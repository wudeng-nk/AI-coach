import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/core/services/web_speech_service.dart';
import 'package:ai_coach/features/training/presentation/bloc/training_chat_bloc.dart';
import 'package:ai_coach/shared/widgets/squirrel_avatar.dart';

class TrainingChatPage extends StatelessWidget {
  final String customerId;

  const TrainingChatPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrainingChatBloc()
        ..add(TrainingSessionStarted(customerId: customerId)),
      child: _TrainingChatView(customerId: customerId),
    );
  }
}

class _TrainingChatView extends StatefulWidget {
  final String customerId;

  const _TrainingChatView({required this.customerId});

  @override
  State<_TrainingChatView> createState() => _TrainingChatViewState();
}

class _TrainingChatViewState extends State<_TrainingChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  bool _isPaused = false;
  bool _showTipPanel = true;
  bool _useMock = false;
  bool _listening = false;
  final _speech = WebSpeechService();
  StreamSubscription? _resultSub;
  StreamSubscription? _stateSub;

  // Scene info
  String _sceneName = '电话邀约';
  String _parentType = '焦虑型';
  String _currentStage = '需求挖掘';
  String _suggestedSkill = '痛点具象化';

  // Mock messages for demo
  final List<ChatDisplayMessage> _mockMessages = const [
    ChatDisplayMessage(role: 'customer', content: '你好，我看到你们朋友圈发的课程，想了解一下。'),
    ChatDisplayMessage(role: 'user', content: '您好！感谢关注我们。请问您的孩子多大？目前在上几年级呢？'),
    ChatDisplayMessage(
      role: 'customer',
      content: '孩子今年8岁，上二年级。成绩一直不太好，我比较着急，怕他跟不上。',
      emotion: '焦虑',
    ),
    ChatDisplayMessage(role: 'system', content: '已使用：共情三连问'),
    ChatDisplayMessage(role: 'user', content: '我非常理解您的心情，二年级确实是打基础的关键时期。很多家长在这个阶段都会有类似的担心。'),
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    // Start in mock mode immediately for fast loading
    _useMock = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _initSpeech() {
    _resultSub = _speech.onResult.listen((text) {
      _textController.text = text;
      _textController.selection = TextSelection.collapsed(offset: text.length);
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
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleVoice() {
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

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lightbulb, color: Color(0xFFFFC107), size: 24),
            const SizedBox(width: 8),
            const Text('训练提示'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前阶段：$_currentStage',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text('建议使用技能：$_suggestedSkill'),
            const SizedBox(height: 12),
            const Text(
              '小贴士：在需求挖掘阶段，通过连续追问帮助客户意识到问题的严重性，从而建立更强的购买动机。',
              style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.5),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showExampleDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFFFC107), size: 24),
            const SizedBox(width: 8),
            const Text('优秀示范'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '"我理解您的担心，很多家长刚开始也有类似的顾虑。不过我想了解一下，您觉得孩子目前在数学方面最大的困难是什么呢？"',
                style: TextStyle(height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '示范解析：先共情 + 然后用开放式问题引导',
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _textController.text =
                  '我理解您的担心，很多家长刚开始也有类似的顾虑。不过我想了解一下，您觉得孩子目前在数学方面最大的困难是什么呢？';
            },
            child: const Text('使用此回复'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _handleEndSession() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('结束对话'),
        content: const Text('确定要结束本次训练对话吗？结束后将生成训练报告。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (_useMock) {
                // Mock: navigate directly to report with dummy session id
                context.push('/training/report/mock-session-001');
              } else {
                context
                    .read<TrainingChatBloc>()
                    .add(const TrainingSessionEnded());
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('结束'),
          ),
        ],
      ),
    );
  }

  void _showEndDialogAndNavigate(String sessionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 8),
            const Text('对话已结束'),
          ],
        ),
        content: const Text('训练对话已结束，正在生成训练报告...'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/training/report/$sessionId');
            },
            child: const Text('查看报告'),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    _textController.clear();

    if (_useMock) {
      setState(() {
        _mockMessages.add(ChatDisplayMessage(role: 'user', content: text));
        _isSending = true;
      });
      _scrollToBottom();
      // Simulate AI response
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _mockMessages.add(const ChatDisplayMessage(
              role: 'customer',
              content: '嗯...听起来有道理，但是我还是有点担心效果。你们有没有什么实际的案例可以给我看看？',
              emotion: '犹豫',
            ));
            _isSending = false;
          });
          _scrollToBottom();
        }
      });
      return;
    }

    setState(() => _isSending = true);
    context.read<TrainingChatBloc>().add(TrainingMessageSent(content: text));
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isSending = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<TrainingChatBloc, TrainingChatState>(
        listener: (context, state) {
          if (state is TrainingChatActive) {
            _scrollToBottom();
          }
          if (state is TrainingChatEnded) {
            _showEndDialogAndNavigate(state.sessionId);
          }
        },
        builder: (context, state) {
          final isLoading =
              (state is TrainingChatStarting || state is TrainingChatEnding) &&
                  !_useMock;

          List<ChatDisplayMessage> messages;
          bool isActive;

          if (_useMock) {
            messages = _mockMessages;
            isActive = true;
          } else if (state is TrainingChatActive) {
            messages = state.messages;
            isActive = true;
          } else {
            messages = [];
            isActive = false;
          }

          return Column(
            children: [
              _buildHeader(),
              if (isLoading)
                Expanded(child: _buildLoading(state is TrainingChatStarting
                    ? '正在创建训练会话...'
                    : '正在结束训练...'))
              else ...[
                Expanded(child: _buildChatList(messages)),
                if (isActive) ...[
                  if (_showTipPanel) _buildTipPanel(),
                  _buildInputArea(),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  // ---- Header ----
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              // Back + 暂停
              TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF333333)),
                label: const Text('暂停',
                    style: TextStyle(color: Color(0xFF333333), fontSize: 14)),
                style:
                    TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
              // Title
              Expanded(
                child: Text(
                  '$_sceneName | $_parentType',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              // Pause button
              IconButton(
                onPressed: () => setState(() => _isPaused = !_isPaused),
                icon: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause,
                  size: 26,
                  color: const Color(0xFF333333),
                ),
              ),
              // End button
              IconButton(
                onPressed: _handleEndSession,
                icon: const Icon(Icons.stop_circle_outlined,
                    size: 24, color: Color(0xFFE53935)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Loading ----
  Widget _buildLoading(String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
                strokeWidth: 3, color: Color(0xFF2196F3)),
          ),
          const SizedBox(height: 16),
          Text(text,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  // ---- Chat list ----
  Widget _buildChatList(List<ChatDisplayMessage> messages) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          if (msg.role == 'system') {
            return _SystemMessage(content: msg.content);
          }
          return _ChatBubble(message: msg, isUser: msg.role == 'user');
        },
      ),
    );
  }

  // ---- Tip panel ----
  Widget _buildTipPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          const SquirrelAvatar(size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        size: 14, color: Color(0xFF2196F3)),
                    const SizedBox(width: 4),
                    Text(
                      '当前阶段：$_currentStage',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '建议使用：【$_suggestedSkill】',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1976D2)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showTipPanel = false),
            child: const Icon(Icons.keyboard_arrow_down,
                size: 20, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  // ---- Input area ----
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isSending,
                    decoration: const InputDecoration(
                      hintText: '输入你的回复...',
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                IconButton(
                  onPressed: _isSending ? null : _sendMessage,
                  icon: Icon(Icons.send_rounded,
                      size: 20,
                      color: _isSending
                          ? const Color(0xFFBDBDBD)
                          : const Color(0xFF2196F3)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Action buttons
          Row(
            children: [
              Expanded(child: _ActionButton(
                icon: _listening ? Icons.mic : Icons.mic_none_outlined,
                label: '语音',
                onPressed: _toggleVoice,
                active: _listening,
              )),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(
                icon: Icons.lightbulb_outline,
                label: '提示',
                onPressed: _showHintDialog,
              )),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(
                icon: Icons.emoji_events_outlined,
                label: '示范',
                onPressed: _showExampleDialog,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action button
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? const Color(0xFF1565C0) : const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// System message (green tag)
// ---------------------------------------------------------------------------

class _SystemMessage extends StatelessWidget {
  final String content;
  const _SystemMessage({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
              const SizedBox(width: 6),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat bubble
// ---------------------------------------------------------------------------

class _ChatBubble extends StatelessWidget {
  final ChatDisplayMessage message;
  final bool isUser;

  const _ChatBubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(false),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFFE3F2FD)
                        : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.5,
                    ),
                  ),
                ),
                if (message.emotion != null && message.emotion!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sentiment_satisfied,
                              size: 12, color: Color(0xFFFF9800)),
                          const SizedBox(width: 2),
                          Text(
                            message.emotion!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isUser) _buildAvatar(true),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 36,
      height: 36,
      margin: EdgeInsets.only(
        left: isUser ? 8 : 0,
        right: isUser ? 0 : 8,
      ),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFFE3F2FD) : const Color(0xFFFFE0B2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.headset_mic : Icons.person,
        size: isUser ? 18 : 20,
        color: isUser ? const Color(0xFF1976D2) : const Color(0xFFE65100),
      ),
    );
  }
}
