import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nil/nil.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/repo_tile.dart';

import 'failure_repo_tile.dart';
import 'loading_repo_tile.dart';

class PaginatedReposListView extends StatelessWidget {
  const PaginatedReposListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(starredReposNotifierProvider);
        return ListView.builder(
          itemCount: state.map(
            initial: (_) => 0,
            loadInProgress: (_) => _.repos.entity.length + _.itemsPerPage,
            loadSuccess: (_) => _.repos.entity.length,
            loadFailuer: (_) => _.repos.entity.length + 1,
          ),
          itemBuilder: (context, index) {
            return state.map(
              initial: (_) => const Nil(),
              loadInProgress: (_) {
                if (index < _.repos.entity.length) {
                  return RepoTile(repo: _.repos.entity[index]);
                } else {
                  return const LoadingRepoTile();
                }
              },
              loadSuccess: (_) => RepoTile(
                repo: _.repos.entity[index],
              ),
              loadFailuer: (_) {
                if (index < _.repos.entity.length) {
                  return RepoTile(repo: _.repos.entity[index]);
                } else {
                  return FailureRepoTile(
                    failure: _.failure,
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
