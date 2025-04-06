import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';

class GetPaginatedItems {
  final ItemRepository repository;

  GetPaginatedItems(this.repository);

  Future<List<ItemEntity>> execute(int skip, {int limit = 5}) async {
    try {
      // Try to get cached items first
      final cachedItems = await repository.getCachedItems(skip ~/ limit);
      if (cachedItems != null) {
        return cachedItems;
      }

      // If no cached items, fetch from remote
      final items = await repository.getPaginatedItems(skip, limit);
      
      // Cache the fetched items
      await repository.cacheItems(items, skip ~/ limit);
      
      return items;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCache() async {
    await repository.clearCache();
  }

  bool hasReachedMax(int currentItemsCount) {
    return repository.hasReachedMax(currentItemsCount);
  }
} 