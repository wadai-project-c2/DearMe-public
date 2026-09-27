import 'package:dearme/services/fastapi_image_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final daily in [true, false]) {
    test('429 distinguishes daily quota from temporary throttling ($daily)',
        () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://backend.test'));
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 429,
            data: daily
                ? Uint8List.fromList(
                    '{"detail":{"code":"daily_quota_exceeded"}}'.codeUnits)
                : Uint8List.fromList('<html>rate limited</html>'.codeUnits),
          ),
        ));
      }));
      final service =
          FastApiImageService(backendDio: dio, apiToken: 'test-token');
      await expectLater(
        service.processImage(
            itemId: 'id',
            imageBytes: Uint8List.fromList([1]),
            fileName: 'image.png',
            title: '写真'),
        throwsA(isA<ImageServiceException>()
            .having((e) => e.statusCode, 'status', 429)
            .having((e) => e.message, 'message',
                daily ? contains('上限50回') : contains('時間をおいて'))),
      );
    });
  }

  test('sends image bytes directly with title-only query metadata', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://backend.test'))
      ..httpClientAdapter = adapter;
    final service = FastApiImageService(
      backendDio: dio,
      apiToken: 'temporary-test-token',
    );

    final result = await service.processImage(
      itemId: 'item-1',
      imageBytes: Uint8List.fromList([1, 2, 3, 4]),
      fileName: 'memory.png',
      title: '  白いTシャツ  ',
    );

    expect(result, [9, 8, 7]);
    expect(adapter.options?.path, '/images/process');
    expect(
      adapter.options?.uri.queryParameters,
      {
        'item_id': 'item-1',
        'title': '白いTシャツ',
        'output_type': 'sticker_png',
      },
    );
    expect(adapter.options?.contentType, 'image/png');
    expect(
      adapter.options?.headers['X-DearMe-Token'],
      'temporary-test-token',
    );
    expect(adapter.options?.headers.containsKey('Authorization'), isFalse);
    expect(adapter.options?.responseType, ResponseType.bytes);
    expect(adapter.options?.followRedirects, isFalse);
    expect(adapter.options?.headers['X-File-Name'], 'memory.png');
    expect(adapter.options?.headers['x-amz-content-sha256'],
        '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a');
    expect(adapter.requestBytes, [1, 2, 3, 4]);
  });

  test('body SHA256 is repeatable and changes when one byte changes', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://backend.test'))
      ..httpClientAdapter = adapter;
    final service = FastApiImageService(backendDio: dio);
    Future<String> send(List<int> bytes) async {
      await service.processImage(
          itemId: 'id',
          imageBytes: Uint8List.fromList(bytes),
          fileName: 'image.png',
          title: '写真');
      expect(adapter.requestBytes, bytes);
      return adapter.options!.headers['x-amz-content-sha256'] as String;
    }

    final first = await send([97, 98, 99]);
    expect(first,
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
    expect(await send([97, 98, 99]), first);
    expect(await send([97, 98, 100]), isNot(first));
  });

  for (final entry in {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp'
  }.entries) {
    test('preserves ${entry.key} bytes, metadata and encoded filename',
        () async {
      final adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://backend.test'))
        ..httpClientAdapter = adapter;
      await FastApiImageService(backendDio: dio).processImage(
          itemId: 'id',
          imageBytes: Uint8List.fromList([0, 255, 128]),
          fileName: '/private/思い出.${entry.key}',
          title: '写真',
          outputType: 'acrylic_stand_png');
      expect(adapter.requestBytes, [0, 255, 128]);
      expect(adapter.options!.contentType, entry.value);
      expect(adapter.options!.headers['content-length'], '3');
      expect(adapter.options!.headers['X-File-Name'],
          Uri.encodeComponent('思い出.${entry.key}'));
      expect(
          adapter.options!.queryParameters['output_type'], 'acrylic_stand_png');
    });
  }

  test('rejects an image larger than the Lambda-safe limit', () async {
    final service = FastApiImageService(
      backendBaseUrl: 'http://backend.test',
      apiToken: 'temporary-test-token',
    );

    expect(
      () => service.processImage(
        itemId: 'item-1',
        imageBytes: Uint8List(4 * 1024 * 1024 + 1),
        fileName: 'large.png',
        title: '大きな画像',
      ),
      throwsA(isA<ImageServiceException>()),
    );
  });

  test('accepts the exact 4 MiB boundary', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://backend.test'))
      ..httpClientAdapter = adapter;
    await FastApiImageService(backendDio: dio).processImage(
      itemId: 'id',
      imageBytes: Uint8List(4 * 1024 * 1024),
      fileName: 'image.png',
      title: '写真',
    );
    expect(adapter.requestBytes.length, 4 * 1024 * 1024);
  });

  test('errors preserve status without logging tokens or upstream bodies',
      () async {
    final logs = <String>[];
    final originalPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };
    addTearDown(() => debugPrint = originalPrint);
    final dio = Dio(BaseOptions(baseUrl: 'https://backend.test'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
            requestOptions: options,
            statusCode: 401,
            data: 'upstream-private-body'),
        message: 'private-exception',
      ));
    }));
    final service =
        FastApiImageService(backendDio: dio, apiToken: 'private-token');
    await expectLater(
        service.processImage(
            itemId: 'id',
            imageBytes: Uint8List.fromList([1]),
            fileName: 'image.png',
            title: 'private-title'),
        throwsA(isA<ImageServiceException>()
            .having((e) => e.statusCode, 'status', 401)
            .having((e) => e.message, 'message', '画像加工に失敗しました。')));
    final output = logs.join('\n');
    for (final secret in [
      'private-token',
      'private-title',
      'private-exception',
      'upstream-private-body'
    ]) {
      expect(output, isNot(contains(secret)));
    }
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? options;
  List<int> requestBytes = const [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    this.options = options;
    final bytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bytes.addAll(chunk);
      }
    }
    requestBytes = bytes;
    return ResponseBody.fromBytes(
      [9, 8, 7],
      200,
      headers: {
        Headers.contentTypeHeader: ['image/png'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
