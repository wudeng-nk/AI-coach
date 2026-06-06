import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_coach/core/network/dio_client.dart';
import 'package:ai_coach/features/knowledge/data/datasources/knowledge_remote_data_source.dart';
import 'package:ai_coach/features/knowledge/data/models/chat_message_model.dart';

// --- Events ---

abstract class KnowledgeChatEvent extends Equatable {
  const KnowledgeChatEvent();

  @override
  List<Object?> get props => [];
}

class KnowledgeChatMessageSent extends KnowledgeChatEvent {
  final String question;

  const KnowledgeChatMessageSent(this.question);

  @override
  List<Object?> get props => [question];
}

class KnowledgeChatHistoryLoaded extends KnowledgeChatEvent {
  const KnowledgeChatHistoryLoaded();
}

class KnowledgeFeedbackSubmitted extends KnowledgeChatEvent {
  final String chatId;
  final String feedback;

  const KnowledgeFeedbackSubmitted({required this.chatId, required this.feedback});

  @override
  List<Object?> get props => [chatId, feedback];
}

// --- States ---

abstract class KnowledgeChatState extends Equatable {
  const KnowledgeChatState();

  @override
  List<Object?> get props => [];
}

class KnowledgeChatInitial extends KnowledgeChatState {
  const KnowledgeChatInitial();
}

class KnowledgeChatLoading extends KnowledgeChatState {
  final List<ChatDisplay> messages;

  const KnowledgeChatLoading(this.messages);

  @override
  List<Object?> get props => [messages];
}

class KnowledgeChatLoaded extends KnowledgeChatState {
  final List<ChatDisplay> messages;
  final String? conversationId;

  const KnowledgeChatLoaded({
    required this.messages,
    this.conversationId,
  });

  @override
  List<Object?> get props => [messages, conversationId];
}

class KnowledgeChatError extends KnowledgeChatState {
  final String message;
  final List<ChatDisplay> previousMessages;

  const KnowledgeChatError(this.message, this.previousMessages);

  @override
  List<Object?> get props => [message, previousMessages];
}

// --- Display model ---

class ChatDisplay extends Equatable {
  final String text;
  final bool isUser;
  final List<String> sources;
  final List<String> suggestions;
  final String? chatId;
  final String? feedback;

  const ChatDisplay({
    required this.text,
    required this.isUser,
    this.sources = const [],
    this.suggestions = const [],
    this.chatId,
    this.feedback,
  });

  ChatDisplay copyWith({String? feedback}) => ChatDisplay(
        text: text,
        isUser: isUser,
        sources: sources,
        suggestions: suggestions,
        chatId: chatId,
        feedback: feedback ?? this.feedback,
      );

  @override
  List<Object?> get props => [text, isUser, sources, suggestions, chatId, feedback];
}

// --- Bloc ---

class KnowledgeChatBloc extends Bloc<KnowledgeChatEvent, KnowledgeChatState> {
  final KnowledgeRemoteDataSource _dataSource;
  String? _conversationId;

  KnowledgeChatBloc()
      : _dataSource = KnowledgeRemoteDataSource(dioClient.dio),
        super(const KnowledgeChatInitial()) {
    on<KnowledgeChatMessageSent>(_onMessageSent);
    on<KnowledgeChatHistoryLoaded>(_onHistoryLoaded);
    on<KnowledgeFeedbackSubmitted>(_onFeedbackSubmitted);
  }

  Future<void> _onMessageSent(
    KnowledgeChatMessageSent event,
    Emitter<KnowledgeChatState> emit,
  ) async {
    final currentMessages = state is KnowledgeChatLoaded
        ? (state as KnowledgeChatLoaded).messages
        : state is KnowledgeChatLoading
            ? (state as KnowledgeChatLoading).messages
            : state is KnowledgeChatError
                ? (state as KnowledgeChatError).previousMessages
                : <ChatDisplay>[];

    final updatedMessages = [
      ...currentMessages,
      ChatDisplay(text: event.question, isUser: true),
    ];

    emit(KnowledgeChatLoading(updatedMessages));

    try {
      final data = await _dataSource.chat(
        question: event.question,
        conversationId: _conversationId,
      );

      final model = ChatMessageModel.fromJson(data);
      _conversationId = model.conversationId;

      final messagesWithResponse = [
        ...updatedMessages,
        ChatDisplay(
          text: model.answer,
          isUser: false,
          sources: model.sources,
          suggestions: model.suggestions,
          chatId: data['id'],
        ),
      ];

      emit(KnowledgeChatLoaded(
        messages: messagesWithResponse,
        conversationId: _conversationId,
      ));
    } catch (e) {
      emit(KnowledgeChatError(
        '请求失败，请重试',
        updatedMessages,
      ));
    }
  }

  Future<void> _onHistoryLoaded(
    KnowledgeChatHistoryLoaded event,
    Emitter<KnowledgeChatState> emit,
  ) async {
    try {
      final data = await _dataSource.getHistory();
      final items = (data['items'] as List)
          .map((json) => HistoryItemModel.fromJson(json))
          .toList();

      final messages = <ChatDisplay>[];
      for (final item in items.reversed) {
        messages.add(ChatDisplay(text: item.question, isUser: true));
        messages.add(ChatDisplay(
          text: item.answer,
          isUser: false,
          sources: item.sources,
          chatId: item.id,
        ));
      }

      if (items.isNotEmpty) {
        _conversationId = items.first.conversationId;
      }

      emit(KnowledgeChatLoaded(
        messages: messages,
        conversationId: _conversationId,
      ));
    } catch (_) {
      emit(const KnowledgeChatLoaded(messages: []));
    }
  }

  Future<void> _onFeedbackSubmitted(
    KnowledgeFeedbackSubmitted event,
    Emitter<KnowledgeChatState> emit,
  ) async {
    if (state is! KnowledgeChatLoaded) return;
    final loaded = state as KnowledgeChatLoaded;

    try {
      await _dataSource.submitFeedback(
        chatId: event.chatId,
        feedback: event.feedback,
      );

      final updated = loaded.messages.map((m) {
        if (m.chatId == event.chatId) return m.copyWith(feedback: event.feedback);
        return m;
      }).toList();

      emit(KnowledgeChatLoaded(
        messages: updated,
        conversationId: loaded.conversationId,
      ));
    } catch (_) {
      // silently ignore feedback errors
    }
  }
}
