import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:ai_coach/core/network/dio_client.dart';
import 'package:ai_coach/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ai_coach/features/profile/data/models/user_profile_model.dart';
import 'package:ai_coach/features/profile/data/models/user_profile_model.dart' show TrainingStatsModel;

// ── Events ──

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileLogoutRequested extends ProfileEvent {}

// ── States ──

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileModel user;
  final TrainingStatsModel stats;

  const ProfileLoaded({required this.user, required this.stats});

  @override
  List<Object?> get props => [user, stats];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRemoteDataSource _dataSource = ProfileRemoteDataSource(dioClient.dio);

  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadRequested(ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final userJson = await _dataSource.getProfile();
      final user = UserProfileModel.fromJson(userJson);

      // Cache user info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', user.name);

      TrainingStatsModel stats;
      try {
        final statsJson = await _dataSource.getStatistics();
        stats = TrainingStatsModel.fromJson(statsJson);
      } catch (_) {
        stats = TrainingStatsModel(totalSessions: 0, completedSessions: 0);
      }

      emit(ProfileLoaded(user: user, stats: stats));
    } on DioException catch (e) {
      emit(ProfileError(e.response?.data?['message'] ?? '加载失败'));
    } catch (e) {
      emit(ProfileError('加载失败'));
    }
  }

  Future<void> _onLogoutRequested(ProfileLogoutRequested event, Emitter<ProfileState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_name');
  }
}
