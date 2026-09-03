import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Response;
import '../config/api_config.dart';
import '../routes/app_routes.dart';
import 'cache_manager.dart';

/// Client Dio centralisé avec intercepteurs JWT.
/// - Injecte automatiquement le token Bearer dans chaque requête
/// - Gère les 401 : déconnexion automatique + redirection login
/// - Gère les timeouts et erreurs réseau
class DioClient {
 static Dio? _instance;
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConfig.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: ApiConfig.receiveTimeoutMs),
        sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeoutMs),
        headers: {
          'Content-Type': ApiConfig.contentType,
          'ngrok-skip-browser-warning': 'true',
        },
       responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      _PutToPatchInterceptor(),
      _AuthInterceptor(_storage),
      _ErrorInterceptor(),
      if (const bool.fromEnvironment('dart.vm.product') == false)
       LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
    ]);

    return dio;
  }

  /// Réinitialise l'instance (après logout)
  static void reset() {
    _instance = null;
  }
}

/// Intercepteur qui convertit toutes les requêtes PUT en PATCH.
/// Nécessaire pour contourner les proxys/tunnels (Cloudflare) qui bloquent PUT.
class _PutToPatchInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'PUT') {
     options.method = 'PATCH';
   }
    handler.next(options);
  }
}

/// Intercepteur d'authentification JWT.
/// Lit le token depuis flutter_secure_storage et l'ajoute à chaque requête.
class _AuthInterceptor extends Interceptor {
 final FlutterSecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: ApiConfig.secureKeyToken);
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConfig.headerAuthorization] =
          '${ApiConfig.tokenPrefix}$token';
   }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expiré ou invalide : déconnexion automatique
      _handleUnauthorized();
    }
    handler.next(err);
  }

  Future<void> _handleUnauthorized() async {
    await _storage.delete(key: ApiConfig.secureKeyToken);
    await _storage.delete(key: ApiConfig.secureKeyUser);
    AppCacheManager.clearAll();
    DioClient.reset();
    // Redirige vers login en effaçant toute la pile de navigation
    Get.offAllNamed(AppRoutes.login);
  }
}

/// Intercepteur d'erreurs pour normalisation des messages d'erreur.
class _ErrorInterceptor extends Interceptor {
 @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Normalise le message d'erreur
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'Délai d\'attente dépassé. Vérifiez votre connexion.';
       break;
      case DioExceptionType.connectionError:
        message = 'Impossible de se connecter au serveur.';
       break;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;
        if (status == 403) {
          message = 'Accès refusé pour cette action.';
       } else if (status == 404) {
          message = 'Ressource introuvable.';
       } else if (status != null && status >= 500) {
          message = 'Erreur serveur. Veuillez réessayer.';
       } else {
          final detail = err.response?.data?['detail'];
         if (detail is String) {
            message = detail;
          } else if (detail is List) {
            message = detail
                .map((e) => e is Map ? (e['msg']?.toString() ?? e.toString()) : e.toString())
               .join(', ');
         } else if (detail != null) {
            message = detail.toString();
          } else {
            message = 'Une erreur est survenue.';
         }
        }
        break;
      default:
        message = 'Erreur réseau. Vérifiez votre connexion.';
   }

    // Recrée l'exception avec le message normalisé
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: message,
        message: message,
      ),
    );
  }
}

/// Extension utilitaire pour extraire un message d'erreur d'une DioException
extension DioErrorMessage on DioException {
 String get errorMessage =>
      message ?? 'Une erreur inattendue est survenue.';
}
