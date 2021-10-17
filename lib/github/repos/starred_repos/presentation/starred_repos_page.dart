import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.gr.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/core/presentation/paginated_repos_listview.dart';
import 'package:repo_viewer/search/presentation/search_bar.dart';

class StarredReposPage extends ConsumerStatefulWidget {
  const StarredReposPage({Key? key}) : super(key: key);

  @override
  _StarredReposPageState createState() => _StarredReposPageState();
}

class _StarredReposPageState extends ConsumerState<StarredReposPage> {
  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) { }); // Use this to safely access the build context
    Future.microtask(() {
      ref.read(starredReposNotifierProvider.notifier).getNextStarredReposPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchBar(
        title: 'Starred repositories',
        hint: 'Search all repositories',
        onShouldNavigateToResultPage: (searchTerm) {
          AutoRouter.of(context)
              .push(SearchedReposRoute(searchTerm: searchTerm));
        },
        onSignOutButtonPressed: () {
          ref.read(authNotifierProvider.notifier).signOut();
        },
        body: SafeArea(
          child: PaginatedReposListView(
            paginatedReposNotifierProvider: starredReposNotifierProvider,
            getNextPage: (ref) => ref
                .read(starredReposNotifierProvider.notifier)
                .getNextStarredReposPage(),
            noResultsMessage:
                "That's about everything we could find in your starred repos right now.",
          ),
        ),
      ),
    );
  }
}
