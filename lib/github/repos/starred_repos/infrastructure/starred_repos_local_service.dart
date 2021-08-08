import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:sembast/sembast.dart';
import 'package:collection/collection.dart';

class StarredReposLocalService {
  final SembastDatabase _sembastDatabase;
  final _store = intMapStoreFactory.store('starredRepos');

  StarredReposLocalService(this._sembastDatabase);

  Future<void> upsertPage(List<GithubRepoDto> dtos, int page) async {
    final sembastPage = page - 1;

    await _store
        .records(
          dtos.mapIndexed((index, _) => index + 3 * sembastPage),
        )
        .put(
          _sembastDatabase.instance,
          dtos.map((e) => e.toJson()).toList(),
        );
  }
}
