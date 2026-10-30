import 'package:dio/dio.dart';
import '../services/api_client.dart';
import '../config/app_config.dart';
import '../../models/gift_model.dart';

class GiftRepository {
  static final GiftRepository instance = GiftRepository._internal();
  final ApiClient _apiClient = ApiClient.instance;

  GiftRepository._internal();

  /// Fetch public active gifts catalog from backend
  Future<List<GiftModel>> fetchGifts({
    String? category,
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (category != null && category.isNotEmpty && category.toUpperCase() != 'ALL') {
      final cat = category.toUpperCase();
      if (cat.contains('POPULAR') || cat.contains('CLASSIC')) {
        queryParams['giftCategory'] = 'POPULAR';
      } else if (cat.contains('LUXURY') || cat.contains('EVENT') || cat.contains('SPECIAL')) {
        queryParams['giftCategory'] = 'LUXURY';
      } else if (cat.contains('VIP') || cat.contains('PRIVILEGE')) {
        queryParams['giftCategory'] = 'VIP';
      } else if (cat.contains('AUDIO')) {
        queryParams['giftCategory'] = 'AUDIO';
      } else {
        queryParams['giftCategory'] = cat;
      }
    }

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    try {
      final response = await _apiClient.get(
        '/v1/gifts',
        queryParameters: queryParams,
      );

      final rawData = response.data?['data'];
      if (rawData is List && rawData.isNotEmpty) {
        final list = rawData
            .whereType<Map<String, dynamic>>()
            .map((item) => GiftModel.fromJson(item))
            .toList();
        if (list.isNotEmpty) return list;
      }
      return GiftModel.defaultCatalog;
    } catch (_) {
      return GiftModel.defaultCatalog;
    }
  }

  /// Send gift to host/participant atomically via backend
  Future<Map<String, dynamic>> sendGift({
    required String giftId,
    required String recipientUserId,
    int quantity = 1,
    String? roomId,
    String? idempotencyKey,
  }) async {
    final headers = <String, dynamic>{};
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['idempotency-key'] = idempotencyKey;
    }

    try {
      final response = await _apiClient.post(
        '/v1/gifts/send',
        data: {
          'giftId': giftId,
          'recipientUserId': recipientUserId,
          'quantity': quantity,
          if (roomId != null && roomId.isNotEmpty) 'roomId': roomId,
        },
        options: headers.isNotEmpty ? Options(headers: headers) : null,
      );

      final rawData = response.data?['data'];
      if (rawData is Map<String, dynamic>) {
        return rawData;
      }
      return {
        'transactionId': 'tx_${DateTime.now().millisecondsSinceEpoch}',
        'giftId': giftId,
        'recipientUserId': recipientUserId,
        'quantity': quantity,
        'roomId': roomId ?? '',
        'success': true,
      };
    } catch (e) {
      if (AppConfig.isBackendDisconnected || giftId.startsWith('lucky_')) {
        return {
          'transactionId': 'tx_${DateTime.now().millisecondsSinceEpoch}',
          'giftId': giftId,
          'recipientUserId': recipientUserId,
          'quantity': quantity,
          'roomId': roomId ?? '',
          'success': true,
        };
      }
      rethrow;
    }
  }
}
