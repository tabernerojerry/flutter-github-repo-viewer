import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/core/application/auth_notifier.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.gr.dart';
import 'package:repo_viewer/core/shared/providers.dart';

final initializationProvider = FutureProvider<Unit>((ref) async {
  await ref.read(sembastProvider).init();

  ref.read(dioProvider)
    ..options = BaseOptions(
      headers: {
        'Accep': 'application/vnd.github.v3.html+json',
      },
      validateStatus: (status) =>
          status != null && status >= 200 && status <= 400,
    )
    ..interceptors.add(ref.read(oauth2Interceptor));

  final authNotifier = ref.read(authNotifierProvider.notifier);
  await authNotifier.checkAndUpdateAuthState();

  return unit;
});

class AppWidget extends ConsumerWidget {
  final _appRouter = AppRouter();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(initializationProvider, (_, __) {});
    ref.listen<AuthState>(authNotifierProvider, (_, state) {
      state.maybeMap(
        orElse: () {},
        authenticated: (_) {
          _appRouter.pushAndPopUntil(
            const StarredReposRoute(),
            predicate: (_) => false,
          );
        },
        unauthenticated: (_) {
          _appRouter.pushAndPopUntil(
            const SignInRoute(),
            predicate: (_) => false,
          );
        },
      );
    });
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Repo Viewer',
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
