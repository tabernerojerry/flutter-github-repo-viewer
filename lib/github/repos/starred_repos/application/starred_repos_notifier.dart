import 'package:repo_viewer/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';

class StarredReposNotifier extends PaginatedReposNotifier {
  final StarredReposRepository _repsitory;

  StarredReposNotifier(this._repsitory);

  Future<void> getNextStarredReposPage() async {
    super.getNextPage((page) => _repsitory.getStarredReposPage(page));
  }
}
