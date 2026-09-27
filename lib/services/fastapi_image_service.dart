import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

enum ImageProcessingStage { processing }

abstract class ImageProcessingService {
  Future<Uint8List> processImage({
    required String itemId,
    required Uint8List imageBytes,
    required String fileName,
    required String title,
    String outputType = 'sticker_png',
  });
}

class FastApiImageService implements ImageProcessingService {
  // バックエンド接続先はビルド時の --dart-define(-from-file) で指定する。
  // 設定例は dart_define.example.json を参照。
  static const String _configuredBackendBaseUrl = String.fromEnvironment(
    'DEARME_BACKEND_URL',
    defaultValue: '',
  );
  static const String _configuredApiToken = String.fromEnvironment(
    'DEARME_API_TOKEN',
    defaultValue: '',
  );
  static const int _maxLambdaImageBytes = 4 * 1024 * 1024;

  FastApiImageService({
    String? backendBaseUrl,
    String? apiToken,
    Dio? backendDio,
  }) : _backendDio = backendDio ?? _createBackendDio(backendBaseUrl, apiToken) {
    if (backendDio != null) {
      _configureAuthorization(backendDio, apiToken);
    }
  }

  final Dio _backendDio;

  static Dio _createBackendDio(String? backendBaseUrl, String? apiToken) {
    final resolvedBaseUrl = _resolveBackendBaseUrl(backendBaseUrl);
    debugPrint(
      '[FastApiImageService][config] '
      'backend=${_safeEndpoint(Uri.parse(resolvedBaseUrl))}',
    );
    final dio = Dio(
      BaseOptions(
        baseUrl: resolvedBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 180),
      ),
    );
    _configureAuthorization(dio, apiToken);
    return dio;
  }

  static void _configureAuthorization(Dio dio, String? apiToken) {
    final explicitToken = apiToken?.trim();
    final resolvedToken = explicitToken?.isNotEmpty == true
        ? explicitToken!
        : _configuredApiToken;
    if (resolvedToken.isNotEmpty) {
      // Authorization belongs to CloudFront OAC's SigV4 signature.
      dio.options.headers['X-DearMe-Token'] = resolvedToken;
    }
  }

  static String _resolveBackendBaseUrl(String? backendBaseUrl) {
    final explicitBaseUrl = backendBaseUrl?.trim();
    if (explicitBaseUrl != null && explicitBaseUrl.isNotEmpty) {
      return explicitBaseUrl;
    }
    if (_configuredBackendBaseUrl.isNotEmpty) {
      return _configuredBackendBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Androidエミュレーターから開発PCのlocalhostへ接続するための専用アドレス。
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  @override
  Future<Uint8List> processImage({
    required String itemId,
    required Uint8List imageBytes,
    required String fileName,
    required String title,
    String outputType = 'sticker_png',
  }) async {
    if (imageBytes.isEmpty) {
      throw const ImageServiceException('画像データが空です。');
    }
    if (imageBytes.length > _maxLambdaImageBytes) {
      throw const ImageServiceException('画像サイズが大きすぎます。4MB以内の画像を選んでください。');
    }
    final normalizedTitle = _validatedTitle(title);
    final format = ImageUploadFormat.fromFileName(fileName);
    debugPrint(
      '[FastApiImageService][image_process] '
      'format=${format.fileExtension} bytes=${imageBytes.length}',
    );

    try {
      // Hash exactly the binary body sent on the wire, not metadata/base64.
      final requestBytes = Uint8List.fromList(imageBytes);
      // 画像本体をバイナリで送り、加工済みPNGもそのまま受け取る。
      final response = await _backendDio.post<List<int>>(
        '/images/process',
        queryParameters: {
          'item_id': itemId,
          'title': normalizedTitle,
          'output_type': outputType,
        },
        data: requestBytes,
        options: Options(
          contentType: format.contentType,
          responseType: ResponseType.bytes,
          // A redirect must not forward the app token to another origin.
          followRedirects: false,
          headers: {
            Headers.contentLengthHeader: imageBytes.length,
            'X-File-Name': Uri.encodeComponent(p.basename(fileName)),
            'x-amz-content-sha256': sha256.convert(requestBytes).toString(),
          },
        ),
      );
      _logHttpStatus('image_process', response.statusCode);
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const ImageServiceException('加工済み画像が空でした。');
      }
      return Uint8List.fromList(data);
    } on ImageServiceException {
      rethrow;
    } on DioException catch (error) {
      _logDioFailure('image_process', error);
      if (error.response?.statusCode == 429) {
        var dailyLimit = false;
        try {
          final data = error.response?.data;
          final body = data is List<int> ? jsonDecode(utf8.decode(data)) : data;
          dailyLimit = body is Map &&
              body['detail'] is Map &&
              body['detail']['code'] == 'daily_quota_exceeded';
        } catch (_) {
          // WAF may return a non-JSON response; never show raw server content.
        }
        throw ImageServiceException(
          dailyLimit
              ? '本日の画像加工はDEARME全体の上限50回に達しました。日本時間0時以降にお試しください。'
              : '画像加工が混み合っています。時間をおいてお試しください。',
          statusCode: 429,
        );
      }
      throw ImageServiceException(
        error.response == null ? '画像加工サーバーへ接続できませんでした。' : '画像加工に失敗しました。',
        statusCode: error.response?.statusCode,
      );
    }
  }

  void _logHttpStatus(String stage, int? statusCode) {
    debugPrint(
      '[FastApiImageService][$stage] HTTP ${statusCode ?? 'unknown'}',
    );
  }

  void _logDioFailure(String stage, DioException error) {
    debugPrint(
      '[FastApiImageService][$stage] failed '
      'type=${error.type.name} '
      'status=${error.response?.statusCode ?? 'none'} '
      'endpoint=${_safeEndpoint(error.requestOptions.uri)}',
    );
  }

  static String _safeEndpoint(Uri uri) {
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port${uri.path}';
  }

  String _validatedTitle(String title) {
    final normalized = title.trim();
    final hasControlCharacters =
        RegExp(r'[\u0000-\u001F\u007F]').hasMatch(normalized);
    if (normalized.isEmpty ||
        normalized.runes.length > 50 ||
        hasControlCharacters) {
      throw const ImageServiceException(
        'タイトルは1文字以上50文字以内で入力してください。',
      );
    }
    return normalized;
  }
}

class MockImageProcessingService implements ImageProcessingService {
  MockImageProcessingService({
    this.stageDelay = const Duration(seconds: 2),
    this.failFirstAt,
  });

  final Duration stageDelay;
  final ImageProcessingStage? failFirstAt;
  final Set<String> _failedItems = {};

  @override
  Future<Uint8List> processImage({
    required String itemId,
    required Uint8List imageBytes,
    required String fileName,
    required String title,
    String outputType = 'sticker_png',
  }) async {
    await Future<void>.delayed(stageDelay);
    if (failFirstAt == ImageProcessingStage.processing &&
        _failedItems.add(itemId)) {
      throw const ImageServiceException('モックの画像加工に失敗しました。');
    }
    return Uint8List.fromList(imageBytes);
  }
}

class ImageUploadFormat {
  final String fileExtension;
  final String contentType;

  const ImageUploadFormat({
    required this.fileExtension,
    required this.contentType,
  });

  factory ImageUploadFormat.fromFileName(String fileName) {
    final extension = p.extension(fileName).replaceFirst('.', '').toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return ImageUploadFormat(
          fileExtension: extension,
          contentType: 'image/jpeg',
        );
      case 'png':
        return const ImageUploadFormat(
          fileExtension: 'png',
          contentType: 'image/png',
        );
      case 'webp':
        return const ImageUploadFormat(
          fileExtension: 'webp',
          contentType: 'image/webp',
        );
      default:
        throw const ImageServiceException(
          'JPG、PNG、WEBP形式の画像を選択してください。',
        );
    }
  }
}

class ImageServiceException implements Exception {
  final String message;
  final int? statusCode;

  const ImageServiceException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }
    return '$message (HTTP $statusCode)';
  }
}
