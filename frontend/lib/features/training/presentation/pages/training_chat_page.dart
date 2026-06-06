import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/core/network/dio_client.dart';
import 'package:ai_coach/core/widgets/voice_input_button.dart';
import 'package:ai_coach/features/training/data/datasources/training_remote_data_source.dart';
import 'package:ai_coach/features/training/presentation/bloc/training_chat_bloc.dart';

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

  String _customerName = '';
  String _customerDifficulty = '';

  @override
  void initState() {
    super.initState();
    _loadCustomerInfo();
  }

  Future<void> _loadCustomerInfo() async {
    try {
      final ds = TrainingRemoteDataSource(dioClient.dio);
      final detail = await ds.getCustomerDetail(widget.customerId);
      if (mounted) {
        setState(() {
          _customerName = detail.name;
          _customerDifficulty = detail.difficulty;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
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

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case '简单':
        return AppColors.difficultyEasy;
      case '中等':
        return AppColors.difficultyMedium;
      case '困难':
        return AppColors.difficultyHard;
      default:
        return AppColors.textSecondary;
    }
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
              context.read<TrainingChatBloc>().add(const TrainingSessionEnded());
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

    setState(() => _isSending = true);
    _textController.clear();
    context.read<TrainingChatBloc>().add(TrainingMessageSent(content: text));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isSending = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TrainingChatBloc, TrainingChatState>(
          builder: (context, state) {
            String title = _customerName.isNotEmpty ? _customerName : '训练对话';
            int turns = 0;
            String difficulty = _customerDifficulty;

            if (state is TrainingChatActive) {
              turns = state.turnCount;
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title),
                if (difficulty.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _difficultyColor(difficulty).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      difficulty,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _difficultyColor(difficulty),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Text(
                  '第$turns轮',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
          if (state is TrainingChatStarting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '正在创建训练会话...',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          if (state is TrainingChatEnding) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '正在结束训练...',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final messages = state is TrainingChatActive
              ? state.messages
              : <ChatDisplayMessage>[];
          final isActive = state is TrainingChatActive;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.role == 'user';
                    return _ChatBubble(message: msg, isUser: isUser);
                  },
                ),
              ),
              if (isActive) _buildInputArea(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // End session button (circular)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withValues(alpha: 0.1),
            ),
            child: IconButton(
              onPressed: _handleEndSession,
              icon: Icon(Icons.stop_rounded, size: 20, color: AppColors.error),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                enabled: !_isSending,
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Voice input button
          VoiceInputButton(
            onTranscript: (text) {
              _textController.text = text;
              _textController.selection = TextSelection.collapsed(
                offset: text.length,
              );
            },
          ),
          const SizedBox(width: 8),
          // Send button (circular)
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat bubble widget
// ---------------------------------------------------------------------------

class _ChatBubble extends StatelessWidget {
  final ChatDisplayMessage message;
  final bool isUser;

  const _ChatBubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 18, color: Colors.grey),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                if (message.emotion != null && message.emotion!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sentiment_satisfied, size: 12, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            message.emotion!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
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
          if (isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.headset_mic, size: 16, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
