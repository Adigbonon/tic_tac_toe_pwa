import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tic_tac_toe/views/splash_screen_view.dart';
import 'app.dart';
import 'views/home_view.dart';
import 'views/game_view.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ScaffoldWrapper(child: HomeView()),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const ScaffoldWrapper(child: SplashScreenView()),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const ScaffoldWrapper(child: GameView()),
    ),
  ],
);
