import 'package:repo_viewer/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:repo_viewer/github/repos/searched_repos/infrastructure/searched_repos_repository.dart';

class SearchedReposNotifier extends PaginatedReposNotifier {
  final SearchedReposRepository _repsitory;

  SearchedReposNotifier(this._repsitory);

  Future<void> getNextSearchedReposPage(String query) async {
    super.getNextPage((page) => _repsitory.getSearchedReposPage(query, page));
  }
}
