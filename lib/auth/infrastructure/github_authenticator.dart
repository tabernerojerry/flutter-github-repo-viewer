import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:oauth2/oauth2.dart';
import 'package:dartz/dartz.dart';
import 'package:repo_viewer/auth/domain/auth_failure.dart';
import 'package:repo_viewer/auth/infrastructure/credentials_storage/credentials_storage.dart';
import 'package:http/http.dart' as _http;
import 'package:repo_viewer/core/shared/encoders.dart';
import 'package:repo_viewer/core/infrastructure/dio_extensions.dart';

class GithubOAuthHttpClient extends _http.BaseClient {
  final httpClient = _http.Client();

  @override
  Future<_http.StreamedResponse> send(_http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return httpClient.send(request);
  }
}

class GithubAuthenticator {
  final CredentialsStorage _credentialsStorage;
  final Dio _dio;

  GithubAuthenticator(this._credentialsStorage, this._dio);

  static const clientId = 'ff26dc08f812b56d1d92';

  static const clientSecret = 'cdc412f4911132f2747465b53298b85d72f5b0bf';

  static const scopes = ['read:user', 'repo'];

  static final authorizationEndpoint =
      Uri.parse('https://api.github.com/login/oauth/authorize');

  static final tokenEndpoint =
      Uri.parse('https://github.com/login/oauth/access_token');

  static final revocationEndpoint =
      Uri.parse('https://api.github.com/applications/$clientId/token');

  static final redirectUrl = Uri.parse('http://localhost:3000/callback');

  Future<Credentials?> getSignedInCredentials() async {
    try {
      final storedCredentials = await _credentialsStorage.read();

      if (storedCredentials != null) {
        if (storedCredentials.canRefresh && storedCredentials.isExpired) {
          // TODO: refresh method
        }
      }

      return storedCredentials;
    } on PlatformException {
      return null;
    }
  }

  Future<bool> isSignedIn() =>
      getSignedInCredentials().then((credentials) => credentials != null);

  AuthorizationCodeGrant crateGrant() {
    return AuthorizationCodeGrant(
      clientId,
      authorizationEndpoint,
      tokenEndpoint,
      secret: clientSecret,
      httpClient: GithubOAuthHttpClient(),
    );
  }

  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
  }

  Future<Either<AuthFailure, Unit>> handleAuthorizationResponse(
    AuthorizationCodeGrant grant,
    Map<String, String> queryParams,
  ) async {
    try {
      final httpClient = await grant.handleAuthorizationResponse(queryParams);
      await _credentialsStorage.save(httpClient.credentials);
      return right(unit);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('${e.error}: ${e.description}'));
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Unit>> signOut() async {
    final accessToken = await _credentialsStorage
        .read()
        .then((crendentials) => crendentials?.accessToken);

    final usernameAndPassword =
        stringToBase64.encode('$clientId:$clientSecret');

    try {
      try {
        _dio.deleteUri(
          revocationEndpoint,
          data: {
            'access_token': accessToken,
          },
          options: Options(
            headers: {
              'Authorization': 'basic $usernameAndPassword',
            },
          ),
        );
      } on DioError catch (e) {
        if (e.isNoConnectionError) {
          // Ignoring
        } else {
          rethrow;
        }
      }
      await _credentialsStorage.clear();
      return right(unit);
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }
}
