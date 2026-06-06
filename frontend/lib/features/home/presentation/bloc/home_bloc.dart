import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_coach/features/home/data/home_data.dart';
import 'package:ai_coach/features/home/data/models/home_models.dart';

// Events
sealed class HomeEvent {}
class HomeLoadRequested extends HomeEvent {}

// States
sealed class HomeState {}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final HomeData data;
  HomeLoaded(this.data);
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(HomeLoadRequested event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // TODO: 替换为真实 API 调用
      await Future.delayed(const Duration(milliseconds: 500));
      emit(HomeLoaded(HomeMockData.data));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
