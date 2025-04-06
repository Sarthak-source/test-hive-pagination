import '../entities/item_entity.dart';

abstract class ItemRepository {
  Future<List<ItemEntity>> getPaginatedItems(int skip, int limit);
  Future<void> cacheItems(List<ItemEntity> items, int pageIndex);
  Future<List<ItemEntity>?> getCachedItems(int pageIndex);
  Future<void> clearCache();
  bool hasReachedMax(int currentItemsCount);
} 