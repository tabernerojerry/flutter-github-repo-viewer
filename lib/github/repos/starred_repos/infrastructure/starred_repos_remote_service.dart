import 'package:dio/dio.dart';
import 'package:repo_viewer/core/infrastructure/remote_response.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers_cache.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';
import 'package:repo_viewer/github/repos/core/infrastructure/repos_remote_service.dart';

class StarredReposRemoteService extends ReposRemoteService {
  StarredReposRemoteService(
    Dio dio,
    GithubHeadersCache headersCache,
  ) : super(dio, headersCache);

  Future<RemoteResponse<List<GithubRepoDto>>> getStarredReposPage(
    int page,
  ) async =>
      super.getPage(
        requestUri: Uri.https(
          'api.github.com',
          '/user/starred',
          {
            'page': '$page',
            'per_page': PaginationConfig.itemsPerPage.toString(),
          },
        ),
        jsonDataSelector: (json) => json as List<dynamic>,
      );
}
