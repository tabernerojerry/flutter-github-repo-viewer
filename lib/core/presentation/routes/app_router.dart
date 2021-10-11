import 'package:auto_route/auto_route.dart';
import 'package:repo_viewer/auth/presentation/authorization_page.dart';
import 'package:repo_viewer/auth/presentation/sign_in_page.dart';
import 'package:repo_viewer/github/repos/searched_repos/presentation/searched_repos_page.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/starred_repos_page.dart';
import 'package:repo_viewer/splash/presentation/splash_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    MaterialRoute(page: SplashPage, initial: true),
    MaterialRoute(path: '/sign-in', page: SignInPage),
    MaterialRoute(path: '/auth', page: AuthorizationPage),
    MaterialRoute(path: '/starred', page: StarredReposPage),
    MaterialRoute(path: '/search', page: SearchedReposPage),
  ],
)
class $AppRouter {}
