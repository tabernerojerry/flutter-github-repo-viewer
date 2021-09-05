import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_repsitory.dart';

part 'starred_repos_notifier.freezed.dart';

@freezed
class StarredReposState with _$StarredReposState {
  const StarredReposState._();
  const factory StarredReposState.initial(
    Fresh<List<GithubRepo>> repos,
  ) = _Initial;
  const factory StarredReposState.loadInProgress(
    Fresh<List<GithubRepo>> repos,
    int itemsPerPage,
  ) = _LoadInProgress;
  const factory StarredReposState.loadSuccess(
    Fresh<List<GithubRepo>> repos, {
    required bool isNextPageAvailable,
  }) = _LoadSuccess;
  const factory StarredReposState.loadFailuer(
      Fresh<List<GithubRepo>> repos, GithubFailure failure) = _LoadFailure;
}

class StarredReposNotifier extends StateNotifier<StarredReposState> {
  final StarredReposRepsitory _repsitory;

  int _page = 1;

  StarredReposNotifier(this._repsitory)
      : super(StarredReposState.initial(Fresh.yes([])));

  Future<void> getNextStarredReposPage() async {
    state = StarredReposState.loadInProgress(
      Fresh.no(state.repos.entity),
      PaginationConfig.itemsPerPage,
    );

    final failureOrRepos = await _repsitory.getStarredReposPage(_page);

    state = failureOrRepos.fold(
      (failure) => StarredReposState.loadFailuer(
        state.repos,
        failure,
      ),
      (data) {
        _page += 1;
        return StarredReposState.loadSuccess(
          data.copyWith(
            entity: [
              ...state.repos.entity,
              ...data.entity,
            ],
          ),
          isNextPageAvailable: data.isNextPageAvailable ?? false,
        );
      },
    );
  }
}
