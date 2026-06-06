import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:ai_coach/core/network/dio_client.dart';
import 'package:ai_coach/features/training/data/datasources/training_remote_data_source.dart';

// ---------------------------------------------------------------------------
// Chat display message
// ---------------------------------------------------------------------------

class ChatDisplayMessage {
  final String role; // 'user' | 'customer'
  final String content;
  final String? emotion;

  const ChatDisplayMessage({
    required this.role,
    required this.content,
    this.emotion,
  });

  ChatDisplayMessage copyWith({String? emotion}) => ChatDisplayMessage(
        role: role,
        content: content,
        emotion: emotion ?? this.emotion,
      );
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class TrainingChatEvent extends Equatable {
  const TrainingChatEvent();

  @override
  List<Object?> get props => [];
}

class TrainingSessionStarted extends TrainingChatEvent {
  final String customerId;

  const TrainingSessionStarted({required this.customerId});

  @override
  List<Object?> get props => [customerId];
}

class TrainingMessageSent extends TrainingChatEvent {
  final String content;

  const TrainingMessageSent({required this.content});

  @override
  List<Object?> get props => [content];
}

class TrainingSessionEnded extends TrainingChatEvent {
  const TrainingSessionEnded();
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

abstract class TrainingChatState extends Equatable {
  const TrainingChatState();

  @override
  List<Object?> get props => [];
}

class TrainingChatInitial extends TrainingChatState {
  const TrainingChatInitial();
}

class TrainingChatStarting extends TrainingChatState {
  const TrainingChatStarting();
}

class TrainingChatActive extends TrainingChatState {
  final String sessionId;
  final List<ChatDisplayMessage> messages;
  final int turnCount;

  const TrainingChatActive({
    required this.sessionId,
    required this.messages,
    required this.turnCount,
  });

  TrainingChatActive copyWith({
    List<ChatDisplayMessage>? messages,
    int? turnCount,
  }) =>
      TrainingChatActive(
        sessionId: sessionId,
        messages: messages ?? this.messages,
        turnCount: turnCount ?? this.turnCount,
      );

  @override
  List<Object?> get props => [sessionId, messages, turnCount];
}

class TrainingChatEnding extends TrainingChatState {
  final String sessionId;

  const TrainingChatEnding({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class TrainingChatEnded extends TrainingChatState {
  final String sessionId;

  const TrainingChatEnded({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

// ---------------------------------------------------------------------------
// Bloc
// ---------------------------------------------------------------------------

class TrainingChatBloc extends Bloc<TrainingChatEvent, TrainingChatState> {
  final TrainingRemoteDataSource _remoteDataSource;

  TrainingChatBloc({TrainingRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ??
            TrainingRemoteDataSource(dioClient.dio),
        super(const TrainingChatInitial()) {
    on<TrainingSessionStarted>(_onSessionStarted);
    on<TrainingMessageSent>(_onMessageSent);
    on<TrainingSessionEnded>(_onSessionEnded);
  }

  // -- Start session --------------------------------------------------------

  Future<void> _onSessionStarted(
    TrainingSessionStarted event,
    Emitter<TrainingChatState> emit,
  ) async {
    emit(const TrainingChatStarting());
    try {
      final result =
          await _remoteDataSource.createSession(event.customerId);
      final messages = <ChatDisplayMessage>[
        ChatDisplayMessage(
          role: result.openingMessage.role,
          content: result.openingMessage.content,
          emotion: result.openingMessage.emotion,
        ),
      ];
      emit(TrainingChatActive(
        sessionId: result.session.id,
        messages: messages,
        turnCount: 0,
      ));
    } on DioException {
      // On error, go back to initial so UI can show feedback
      emit(const TrainingChatInitial());
    } catch (_) {
      emit(const TrainingChatInitial());
    }
  }

  // -- Send message ---------------------------------------------------------

  Future<void> _onMessageSent(
    TrainingMessageSent event,
    Emitter<TrainingChatState> emit,
  ) async {
    final current = state;
    if (current is! TrainingChatActive) return;

    // Optimistically add user message
    final updatedMessages = [
      ...current.messages,
      ChatDisplayMessage(role: 'user', content: event.content),
    ];
    emit(current.copyWith(messages: updatedMessages));

    try {
      final result = await _remoteDataSource.sendMessage(
        current.sessionId,
        event.content,
      );

      // Replace user message with server version and add customer response
      final messagesWithResponse = [
        ...updatedMessages,
        ChatDisplayMessage(
          role: result.customerMessage.role,
          content: result.customerMessage.content,
          emotion: result.customerMessage.emotion,
        ),
      ];

      final newTurnCount = current.turnCount + 1;

      if (result.sessionEnded || result.isPurchased) {
        // Add final messages then end
        emit(TrainingChatActive(
          sessionId: current.sessionId,
          messages: messagesWithResponse,
          turnCount: newTurnCount,
        ));
        // Trigger session end
        add(TrainingSessionEnded());
      } else {
        emit(TrainingChatActive(
          sessionId: current.sessionId,
          messages: messagesWithResponse,
          turnCount: newTurnCount,
        ));
      }
    } on DioException {
      // Remove optimistically added user message on failure
      emit(current);
    } catch (e) {
      emit(current);
    }
  }

  // -- End session ----------------------------------------------------------

  Future<void> _onSessionEnded(
    TrainingSessionEnded event,
    Emitter<TrainingChatState> emit,
  ) async {
    final current = state;
    if (current is TrainingChatActive) {
      emit(TrainingChatEnding(sessionId: current.sessionId));
      try {
        await _remoteDataSource.endSession(current.sessionId);
        emit(TrainingChatEnded(sessionId: current.sessionId));
      } on DioException {
        // Still consider ended even if API call fails
        emit(TrainingChatEnded(sessionId: current.sessionId));
      } catch (e) {
        emit(TrainingChatEnded(sessionId: current.sessionId));
      }
    } else if (current is TrainingChatEnding) {
      emit(TrainingChatEnded(sessionId: current.sessionId));
    }
  }
}
