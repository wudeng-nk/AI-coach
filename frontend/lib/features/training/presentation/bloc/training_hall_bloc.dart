import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:ai_coach/core/network/dio_client.dart';
import 'package:ai_coach/features/training/data/datasources/training_remote_data_source.dart';
import 'package:ai_coach/features/training/data/models/customer_model.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class TrainingHallEvent extends Equatable {
  const TrainingHallEvent();

  @override
  List<Object?> get props => [];
}

class TrainingCustomersLoadRequested extends TrainingHallEvent {
  const TrainingCustomersLoadRequested();
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

abstract class TrainingHallState extends Equatable {
  const TrainingHallState();

  @override
  List<Object?> get props => [];
}

class TrainingHallInitial extends TrainingHallState {
  const TrainingHallInitial();
}

class TrainingHallLoading extends TrainingHallState {
  const TrainingHallLoading();
}

class TrainingHallLoaded extends TrainingHallState {
  final List<CustomerModel> customers;

  const TrainingHallLoaded({required this.customers});

  @override
  List<Object?> get props => [customers];
}

class TrainingHallError extends TrainingHallState {
  final String message;

  const TrainingHallError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Bloc
// ---------------------------------------------------------------------------

class TrainingHallBloc extends Bloc<TrainingHallEvent, TrainingHallState> {
  final TrainingRemoteDataSource _remoteDataSource;

  TrainingHallBloc({TrainingRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ??
            TrainingRemoteDataSource(dioClient.dio),
        super(const TrainingHallInitial()) {
    on<TrainingCustomersLoadRequested>(_onCustomersLoadRequested);
  }

  Future<void> _onCustomersLoadRequested(
    TrainingCustomersLoadRequested event,
    Emitter<TrainingHallState> emit,
  ) async {
    emit(const TrainingHallLoading());
    try {
      final customers = await _remoteDataSource.getCustomers();
      emit(TrainingHallLoaded(customers: customers));
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ?? '加载客户列表失败，请检查网络';
      emit(TrainingHallError(message: message));
    } catch (e) {
      emit(const TrainingHallError(message: '加载失败，请稍后重试'));
    }
  }
}
