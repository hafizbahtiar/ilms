import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/shared/lookups/data/datasources/api_general_lookup_data_source.dart';

/// Fakes the transport layer so `page`-by-`page` responses can be scripted
/// without a real backend — mirrors a paginated `search*` lookup endpoint.
class _PagedFakeAdapter implements HttpClientAdapter {
  _PagedFakeAdapter(this.responsesByPage);

  final Map<int, Map<String, dynamic>> responsesByPage;
  final requestedPages = <int>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final page = int.parse(options.queryParameters['page'].toString());
    requestedPages.add(page);
    final body = responsesByPage[page];
    if (body == null) {
      throw StateError('No fake response scripted for page $page');
    }

    final bytes = utf8.encode(jsonEncode(body));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiGeneralLookupDataSource _dataSourceWith(_PagedFakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))..httpClientAdapter = adapter;
  return ApiGeneralLookupDataSource(DioClient(dio));
}

void main() {
  group('ApiGeneralLookupDataSource search* pagination', () {
    test('fetchAreasByParliament follows LastPage and merges every page', () async {
      final adapter = _PagedFakeAdapter({
        1: {
          'status': 'success',
          'message': 'ok',
          'data': [
            {'code': 'A1', 'desc': 'Area 1'},
          ],
          'pagination': {'CurrentPage': 1, 'LastPage': 3},
        },
        2: {
          'status': 'success',
          'message': 'ok',
          'data': [
            {'code': 'A2', 'desc': 'Area 2'},
          ],
          'pagination': {'CurrentPage': 2, 'LastPage': 3},
        },
        3: {
          'status': 'success',
          'message': 'ok',
          'data': [
            {'code': 'A3', 'desc': 'Area 3'},
          ],
          'pagination': {'CurrentPage': 3, 'LastPage': 3},
        },
      });

      final result = await _dataSourceWith(adapter).fetchAreasByParliament('P01');

      expect(result.map((e) => e.code), ['A1', 'A2', 'A3']);
      expect(adapter.requestedPages, [1, 2, 3]);
    });

    test('stops after the first page when the response carries no pagination info', () async {
      final adapter = _PagedFakeAdapter({
        1: {
          'status': 'success',
          'message': 'ok',
          'data': [
            {'code': 'A1', 'desc': 'Area 1'},
          ],
        },
      });

      final result = await _dataSourceWith(adapter).fetchAreasByParliament('P01');

      expect(result.map((e) => e.code), ['A1']);
      expect(adapter.requestedPages, [1]);
    });

    test('stops when a page reports itself as the last one, even with more parliaments to go', () async {
      final adapter = _PagedFakeAdapter({
        1: {
          'status': 'success',
          'message': 'ok',
          'data': [
            {'code': 'S1', 'desc': 'Street 1'},
          ],
          'pagination': {'CurrentPage': 1, 'LastPage': 1},
        },
      });

      final result = await _dataSourceWith(adapter).fetchStreets('AREA01');

      expect(result.map((e) => e.code), ['S1']);
      expect(adapter.requestedPages, [1]);
    });
  });
}
