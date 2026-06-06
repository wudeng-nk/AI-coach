import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_coach/core/theme/app_theme.dart';
import 'package:ai_coach/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ai_coach/app/router.dart';

class AiCoachApp extends StatelessWidget {
  const AiCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc()..add(AuthCheckRequested()),
      child: MaterialApp.router(
        title: 'AI Coach',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}
