import 'package:flutter/material.dart';
import '../models/store_item_model.dart';
import '../core/repositories/store_repository.dart';
import '../core/utils/performance_utils.dart';
import 'wallet_provider.dart';

class StoreProvider extends ChangeNotifier {
  final StoreRepository _storeRepository = StoreRepository.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<StoreItemModel> _items = [];
  List<StoreItemModel> get items => List.unmodifiable(_items);

  final Set<String> _pendingPurchaseKeys = {};

  List<String> get categories => [
    'Entry',
    'Frame',
    'Special ID',
    'Chat Bubble',
    'Theme',
    'Entry Strip',
    'Profile Card',
    'Room Frame',
    'CP Theme',
    'CP Profile',
    'CP Token',
    'CP Entry',
  ];

  StoreProvider() {
    fetchStoreItems();
  }

  List<StoreItemModel> getItemsByCategory(String categoryId) {
    final nonRestricted = _items.where((item) => !StoreRepository.isRestrictedSpecialRoleAsset(item)).toList();
    if (categoryId.isEmpty) {
      return nonRestricted;
    }

    final target = categoryId.trim().toLowerCase();

    final filtered = nonRestricted.where((item) {
      final cat = item.categoryId.trim().toLowerCase();
      final type = item.assetType.trim().toLowerCase();

      if (target == 'entry' || target == 'cars' || target == 'car') {
        return cat.contains('entry') || cat.contains('car') || type.contains('entry') || type.contains('car') || type.contains('mount');
      }
      if (target == 'frame' || target == 'frames') {
        return (cat.contains('frame') || type.contains('frame')) && !cat.contains('room');
      }
      if (target == 'special id' || target == 'special card' || target == 'id') {
        return cat.contains('id') || cat.contains('special') || cat.contains('card') || type.contains('id');
      }
      if (target == 'chat bubble' || target == 'bubble' || target == 'bubbles') {
        return cat.contains('bubble') || type.contains('bubble');
      }
      if (target == 'theme') {
        return (cat.contains('theme') || type.contains('theme') || cat.contains('background')) && !cat.contains('cp');
      }
      if (target == 'entry strip' || target == 'strip') {
        return cat.contains('strip') || type.contains('strip');
      }
      if (target == 'profile card' || target == 'profile') {
        return (cat.contains('profile') || type.contains('profile')) && !cat.contains('cp');
      }
      if (target == 'room frame') {
        return cat.contains('room frame') || type.contains('room_frame');
      }
      if (target == 'cp theme') {
        return cat.contains('cp theme') || type.contains('cp_theme');
      }
      if (target == 'cp profile') {
        return cat.contains('cp profile') || type.contains('cp_profile');
      }
      if (target == 'cp token') {
        return cat.contains('cp token') || type.contains('cp_token');
      }
      if (target == 'cp entry') {
        return cat.contains('cp entry') || type.contains('cp_entry');
      }

      return cat == target || type == target;
    }).toList();

    return filtered;
  }

  /// Fetch active store items from backend
  Future<void> fetchStoreItems({String? assetType, bool? isVipExclusive}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedItems = await _storeRepository.fetchStoreCatalog(
        assetType: assetType,
        isVipExclusive: isVipExclusive,
      );
      // Strictly enforce that public store items NEVER contain special status or role assets
      _items = fetchedItems.where((i) => !StoreRepository.isRestrictedSpecialRoleAsset(i)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load store catalog';
      debugPrint('[StoreProvider] Error fetching catalog: $e');
      notifyListeners();
    }
  }

  /// Purchase an item using the wallet provider and backend API
  Future<bool> purchaseItem(StoreItemModel item, WalletProvider wallet) async {
    if (StoreRepository.isRestrictedSpecialRoleAsset(item)) {
      _isLoading = false;
      _errorMessage = 'Special status and role assets cannot be purchased from the store.';
      notifyListeners();
      return false;
    }

    final idempotencyKey = PerformanceUtils.generateIdempotencyKey('buy_${item.id}');
    if (_pendingPurchaseKeys.contains(idempotencyKey)) {
      return false;
    }
    _pendingPurchaseKeys.add(idempotencyKey);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final spent = wallet.spendCoins(item.priceCoins, 'Store Purchase: ${item.name}');
      if (!spent) {
        _pendingPurchaseKeys.remove(idempotencyKey);
        _isLoading = false;
        _errorMessage = 'Insufficient coins balance';
        notifyListeners();
        return false;
      }

      await _storeRepository.purchaseAsset(
        assetId: item.id,
        idempotencyKey: idempotencyKey,
      );
      _pendingPurchaseKeys.remove(idempotencyKey);
      _isLoading = false;

      // Authoritative balance reconciliation
      await wallet.fetchWallet();
      await wallet.fetchLedger(refresh: true);

      notifyListeners();
      return true;
    } catch (e) {
      _pendingPurchaseKeys.remove(idempotencyKey);
      _isLoading = false;
      _errorMessage = e.toString();
      debugPrint('[StoreProvider] Purchase error: $e');

      await wallet.fetchWallet();
      notifyListeners();
      return false;
    }
  }

  /// Send an item as a gift - requires recipient and backend gift endpoint
  Future<bool> sendItem(StoreItemModel item, String recipientId, WalletProvider wallet) async {
    // Currently backend store purchases are user-bound. If sending as gift, route through gift send or mark BLOCKED.
    return purchaseItem(item, wallet);
  }
}
