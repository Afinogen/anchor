import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../l10n/app_localizations.dart';
import '../app_initializer.dart' as app_init;
import '../logging/app_logger.dart';
import '../logging/dio_logging_interceptor.dart';
import 'server_config_provider.dart';
import 'anchor_protocol.dart';

part 'dio_provider.g.dart';

// Global flag to prevent multiple simultaneous refresh attempts
bool _isRefreshing = false;

/// Creates an [IOHttpClientAdapter] that accepts self-signed/invalid
/// certificates only for the host derived from [serverUrl].
/// Requests to any other host will still reject bad certificates.
IOHttpClientAdapter createSelfSignedCertAdapter(String serverUrl) {
  final uri = Uri.tryParse(serverUrl);
  final allowedHost = uri?.host;

  return IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
            return host == allowedHost;
          };
      return client;
    },
  );
}

@riverpod
Dio dio(Ref ref) {
  final serverUrl = ref.watch(serverUrlProvider);
  final dio = Dio();

  // Set base URL from server config
  if (serverUrl != null && serverUrl.isNotEmpty) {
    dio.options.baseUrl = serverUrl;
  }

  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 10);
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': app_init.currentAppLocale.languageCode,
    anchorProtocolHeader: '$anchorProtocol',
  };

  // Allow self-signed certificates when the user has enabled the setting
  final allowSelfSigned = ref.watch(allowSelfSignedCertProvider).value ?? false;
  if (allowSelfSigned && serverUrl != null && serverUrl.isNotEmpty) {
    dio.httpClientAdapter = createSelfSignedCertAdapter(serverUrl);
  }

  // Add Authorization Interceptor with token refresh
  const storage = FlutterSecureStorage();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Handle 401 errors with token refresh
        if (e.response?.statusCode == 401) {
          // Don't try to refresh if we're already on the refresh endpoint
          if (e.requestOptions.path.contains('/api/auth/refresh')) {
            return handler.reject(e);
          }

          // Attempt token refresh
          if (!_isRefreshing) {
            _isRefreshing = true;

            try {
              final refreshToken = await storage.read(key: 'refresh_token');

              if (refreshToken == null) {
                _isRefreshing = false;
                return handler.reject(e);
              }

              // Create a separate Dio instance to avoid interceptor recursion
              final refreshDio = Dio();
              if (serverUrl != null && serverUrl.isNotEmpty) {
                refreshDio.options.baseUrl = serverUrl;
              }
              refreshDio.options.connectTimeout = const Duration(seconds: 10);
              refreshDio.options.receiveTimeout = const Duration(seconds: 10);
              refreshDio.options.headers = {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Accept-Language': app_init.currentAppLocale.languageCode,
              };
              if (allowSelfSigned &&
                  serverUrl != null &&
                  serverUrl.isNotEmpty) {
                refreshDio.httpClientAdapter = createSelfSignedCertAdapter(
                  serverUrl,
                );
              }

              // Call refresh endpoint
              final response = await refreshDio.post(
                '/api/auth/refresh',
                data: {'refresh_token': refreshToken},
              );

              final newAccessToken = response.data['access_token'] as String;
              final newRefreshToken = response.data['refresh_token'] as String;

              // Store new tokens
              await storage.write(key: 'access_token', value: newAccessToken);
              await storage.write(key: 'refresh_token', value: newRefreshToken);

              _isRefreshing = false;

              // Retry the original request with new token
              final opts = Options(
                method: e.requestOptions.method,
                headers: {
                  ...e.requestOptions.headers,
                  'Authorization': 'Bearer $newAccessToken',
                },
              );

              final retryResponse = await dio.request(
                e.requestOptions.path,
                options: opts,
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );

              return handler.resolve(retryResponse);
            } catch (refreshError, stack) {
              _isRefreshing = false;
              AppLogger.instance.error(
                'Auth',
                'Token refresh failed',
                error: refreshError,
                stackTrace: stack,
              );
              return handler.reject(e);
            }
          } else {
            // Already refreshing, wait a bit and retry
            await Future.delayed(const Duration(milliseconds: 100));

            // Check if tokens were updated
            final newToken = await storage.read(key: 'access_token');
            if (newToken != null) {
              // Retry with new token
              final opts = Options(
                method: e.requestOptions.method,
                headers: {
                  ...e.requestOptions.headers,
                  'Authorization': 'Bearer $newToken',
                },
              );

              try {
                final retryResponse = await dio.request(
                  e.requestOptions.path,
                  options: opts,
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                );
                return handler.resolve(retryResponse);
              } catch (_) {
                // Retry failed, reject with original error
                return handler.reject(e);
              }
            }
          }
        }

        // Transform DioException into user-friendly error
        final transformedError = _transformError(e);
        return handler.next(transformedError);
      },
    ),
  );

  // Always log requests/responses (with redaction) so users can collect
  // diagnostics without a hidden toggle.
  dio.interceptors.add(AppLoggingInterceptor());

  return dio;
}

/// Transform DioException into a more user-friendly error with better messages
DioException _transformError(DioException e) {
  // If there's already a response with a message, preserve it
  if (e.response?.data != null && e.response!.data is Map) {
    final data = e.response!.data as Map<String, dynamic>;
    if (data.containsKey('message')) {
      // Server already provided a message, use it
      return e;
    }
  }

  // Localize using the active locale; this runs outside the widget tree so we
  // resolve AppLocalizations from the locale mirror kept by the controller.
  final l10n = lookupAppLocalizations(app_init.currentAppLocale);

  // Transform based on error type
  String message;
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      message = l10n.errorConnectionTimeout;
      break;
    case DioExceptionType.sendTimeout:
      message = l10n.errorSendTimeout;
      break;
    case DioExceptionType.receiveTimeout:
      message = l10n.errorReceiveTimeout;
      break;
    case DioExceptionType.connectionError:
      message = l10n.errorConnection;
      break;
    case DioExceptionType.badCertificate:
      message = l10n.errorCertificate;
      break;
    case DioExceptionType.badResponse:
      // Handle specific status codes
      final statusCode = e.response?.statusCode;
      switch (statusCode) {
        case 400:
          message = l10n.errorBadRequest;
          break;
        case 401:
          message = l10n.errorUnauthorized;
          break;
        case 403:
          message = l10n.errorForbidden;
          break;
        case 404:
          message = l10n.errorNotFound;
          break;
        case upgradeRequiredStatus:
          message = 'App and server versions are incompatible.';
          break;
        case 500:
          message = l10n.errorServer;
          break;
        case 502:
        case 503:
        case 504:
          message = l10n.errorServerUnavailable;
          break;
        default:
          message = l10n.errorRequestFailed;
      }
      break;
    case DioExceptionType.cancel:
      message = l10n.errorCancelled;
      break;
    case DioExceptionType.unknown:
      // Check if it's a network-related error
      if (e.error?.toString().contains('SocketException') == true ||
          e.error?.toString().contains('Network is unreachable') == true) {
        message = l10n.errorConnection;
      } else {
        message = l10n.errorUnexpected;
      }
      break;
  }

  // Create a new DioException with the transformed message
  // Preserve the original error but add the message to response data
  if (e.response != null) {
    final response = e.response!;
    final data = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    data['message'] = message;
    return DioException(
      requestOptions: e.requestOptions,
      response: Response(
        data: data,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        headers: response.headers,
        requestOptions: response.requestOptions,
      ),
      type: e.type,
      error: e.error,
      stackTrace: e.stackTrace,
    );
  }

  // For errors without response, create a synthetic response with the message
  return DioException(
    requestOptions: e.requestOptions,
    response: Response(
      data: {'message': message},
      statusCode: e.response?.statusCode ?? 0,
      requestOptions: e.requestOptions,
    ),
    type: e.type,
    error: e.error,
    stackTrace: e.stackTrace,
  );
}
