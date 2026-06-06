import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/core/widgets/voice_input_button.dart';
import 'package:ai_coach/features/knowledge/presentation/bloc/knowledge_chat_bloc.dart';
import 'package:ai_coach/features/knowledge/presentation/widgets/chat_bubble.dart';

class KnowledgeChatPage extends StatelessWidget {
  const KnowledgeChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KnowledgeChatBloc()..add(const KnowledgeChatHistoryLoaded()),
      child: const _KnowledgeChatView(),
    );
  }
}

class _KnowledgeChatView extends StatefulWidget {
  const _KnowledgeChatView();

  @override
  State<_KnowledgeChatView> createState() => _KnowledgeChatViewState();
}

class _KnowledgeChatViewState extends State<_KnowledgeChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    context.read<KnowledgeChatBloc>().add(KnowledgeChatMessageSent(text.trim()));
    _textController.clear();
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

  List<ChatDisplay> _extractMessages(KnowledgeChatState state) {
    if (state is KnowledgeChatLoaded) return state.messages;
    if (state is KnowledgeChatLoading) return state.messages;
    if (state is KnowledgeChatError) return state.previousMessages;
    return const [];
  }

  bool _isLoading(KnowledgeChatState state) => state is KnowledgeChatLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('知识库问答'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: BlocConsumer<KnowledgeChatBloc, KnowledgeChatState>(
        listener: (context, state) => _scrollToBottom(),
        builder: (context, state) {
          final messages = _extractMessages(state);
          final isLoading = _isLoading(state);

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty && !isLoading
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return ChatBubble(
                            message: msg.text,
                            isUser: msg.isUser,
                            sources: msg.sources,
                            suggestions: msg.suggestions,
                            feedback: msg.feedback,
                            onSuggestionTap: (suggestion) {
                              _sendMessage(suggestion);
                            },
                            onFeedback: msg.chatId != null
                                ? (chatId, feedback) {
                                    context.read<KnowledgeChatBloc>().add(
                                          KnowledgeFeedbackSubmitted(
                                            chatId: msg.chatId!,
                                            feedback: feedback,
                                          ),
                                        );
                                  }
                                : null,
                          );
                        },
                      ),
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.smart_toy_outlined, size: 14, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '正在思考...',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              if (state is KnowledgeChatError)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 14, color: theme.colorScheme.error),
                      const SizedBox(width: 4),
                      Text(
                        state.message,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              _buildInputArea(theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final suggestions = [
      '课程体系是怎么样的？',
      '价格是多少？',
      '适合多大年龄的孩子？',
      '师资力量如何？',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.auto_awesome, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              '你好，我是 AI 助教',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '可以问我任何关于产品知识、销售技巧、\n客户异议处理等问题',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions.map((s) => ActionChip(
                label: Text(s),
                labelStyle: TextStyle(fontSize: 12, color: AppColors.primary),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () => _sendMessage(s),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                decoration: const InputDecoration(
                  hintText: '输入你的问题...',
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: VoiceInputButton(
                onTranscript: (text) {
                  _textController.text = text;
                  _textController.selection = TextSelection.collapsed(
                    offset: text.length,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: IconButton.filled(
                onPressed: () => _sendMessage(_textController.text),
                icon: const Icon(Icons.send_rounded, size: 18),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(10),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
