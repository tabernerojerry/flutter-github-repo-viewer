import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:repo_viewer/github/detail/infrastructure/github_repo_detail_dto.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

class RepoDetailLocalService {
  static const cacheSize = 50;

  final SembastDatabase _sembastDatabase;
  final _store = stringMapStoreFactory.store('repoDetails');

  RepoDetailLocalService(this._sembastDatabase);

  Future<void> upsertRepoDetail(GithubRepoDetailDto dto) async {
    await _store.record(dto.fullName).put(
          _sembastDatabase.instance,
          dto.toSembast(),
        );
  }

  Future<GithubRepoDetailDto?> getRepoDetail(String fullRepoName) async {
    final record = _store.record(fullRepoName);

    await record.update(
      _sembastDatabase.instance,
      {GithubRepoDetailDto.lastUsedFieldName: Timestamp.now()},
    );

    final snapshot = await record.getSnapshot(_sembastDatabase.instance);

    if (snapshot == null) {
      return null;
    }

    return GithubRepoDetailDto.fromSembast(snapshot);
  }
}
