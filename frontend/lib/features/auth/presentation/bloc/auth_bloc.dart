import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_coach/core/network/dio_client.dart';
import 'package:ai_coach/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ai_coach/features/auth/data/models/auth_response.dart';
import 'package:ai_coach/features/auth/data/models/user_model.dart';
import 'package:ai_coach/features/auth/domain/entities/user.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String phone;
  final String password;

  const AuthLoginRequested({required this.phone, required this.password});

  @override
  List<Object?> get props => [phone, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String phone;
  final String password;
  final String name;

  const AuthRegisterRequested({
    required this.phone,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [phone, password, name];
}

class AuthLogoutRequested extends AuthEvent {}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Bloc
// ---------------------------------------------------------------------------

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource _remoteDataSource;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userPhoneKey = 'user_phone';
  static const _userRoleKey = 'user_role';
  static const _userAvatarKey = 'user_avatar';

  AuthBloc({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ??
            AuthRemoteDataSource(dioClient.dio),
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  // -- Check auth status ---------------------------------------------------

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString(_accessTokenKey);

    if (token == null) {
      emit(AuthUnauthenticated());
      return;
    }

    final user = User(
      id: sp.getString(_userIdKey) ?? '',
      phone: sp.getString(_userPhoneKey) ?? '',
      name: sp.getString(_userNameKey) ?? '',
      avatar: sp.getString(_userAvatarKey),
      role: sp.getString(_userRoleKey) ?? '',
    );

    emit(AuthAuthenticated(user: user));
  }

  // -- Login ---------------------------------------------------------------

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final data = await _remoteDataSource.login(
        phone: event.phone,
        password: event.password,
      );

      final tokenResponse = TokenResponse.fromJson(data);
      await _saveTokens(tokenResponse);

      // Cache user info from login response
      if (tokenResponse.user != null) {
        final sp = await SharedPreferences.getInstance();
        await sp.setString(_userIdKey, tokenResponse.user!.id);
        await sp.setString(_userNameKey, tokenResponse.user!.name);
        await sp.setString(_userPhoneKey, tokenResponse.user!.phone);
        await sp.setString(_userRoleKey, tokenResponse.user!.role);
        if (tokenResponse.user!.avatar != null) {
          await sp.setString(_userAvatarKey, tokenResponse.user!.avatar!);
        }
      }

      final user = User(
        id: tokenResponse.user?.id ?? '',
        phone: tokenResponse.user?.phone ?? event.phone,
        name: tokenResponse.user?.name ?? '',
        avatar: tokenResponse.user?.avatar,
        role: tokenResponse.user?.role ?? '',
      );

      emit(AuthAuthenticated(user: user));
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ?? '登录失败，请检查网络';
      emit(AuthError(message: message));
    } catch (e) {
      emit(AuthError(message: '登录失败，请稍后重试'));
    }
  }

  // -- Register ------------------------------------------------------------

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // 1. Register
      final userData = await _remoteDataSource.register(
        phone: event.phone,
        password: event.password,
        name: event.name,
      );

      final userModel = UserModel.fromJson(userData);

      // 2. Auto-login
      final loginData = await _remoteDataSource.login(
        phone: event.phone,
        password: event.password,
      );

      final tokenResponse = TokenResponse.fromJson(loginData);
      await _saveTokens(tokenResponse);

      // 3. Cache user info
      await _cacheUser(userModel);

      emit(AuthAuthenticated(
        user: User(
          id: userModel.id,
          phone: userModel.phone,
          name: userModel.name,
          avatar: userModel.avatar,
          role: userModel.role,
        ),
      ));
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ?? '注册失败，请检查网络';
      emit(AuthError(message: message));
    } catch (e) {
      emit(AuthError(message: '注册失败，请稍后重试'));
    }
  }

  // -- Logout --------------------------------------------------------------

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
    emit(AuthUnauthenticated());
  }

  // -- Helpers -------------------------------------------------------------

  Future<void> _saveTokens(TokenResponse tokenResponse) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_accessTokenKey, tokenResponse.accessToken);
    await sp.setString(_refreshTokenKey, tokenResponse.refreshToken);
  }

  Future<void> _cacheUser(UserModel user) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_userIdKey, user.id);
    await sp.setString(_userNameKey, user.name);
    await sp.setString(_userPhoneKey, user.phone);
    await sp.setString(_userRoleKey, user.role);
    if (user.avatar != null) {
      await sp.setString(_userAvatarKey, user.avatar!);
    }
  }
}
