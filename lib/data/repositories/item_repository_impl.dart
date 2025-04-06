import '../../core/utils/hive_helper.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/item_remote_data_source.dart';
import '../models/item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remoteDataSource;
  final HiveHelper hiveHelper;
  int? _totalItems;

  ItemRepositoryImpl({
    required this.remoteDataSource,
    required this.hiveHelper,
  });

  @override
  Future<List<ItemEntity>> getPaginatedItems(int skip, int limit) async {
    final response = await remoteDataSource.getPaginatedItems(skip, limit);
    _totalItems = response.total;
    return response.products.map((model) => ItemEntity(
          id: model.id,
          title: model.title,
          description: model.description,
          price: model.price,
          rating: model.rating,
          brand: model.brand,
          category: model.category,
          thumbnail: model.thumbnail,
        )).toList();
  }

  @override
  bool hasReachedMax(int currentItemsCount) {
    return _totalItems != null && currentItemsCount >= _totalItems!;
  }

  @override
  Future<void> cacheItems(List<ItemEntity> items, int pageIndex) async {
    final itemModels = items.map((entity) => ItemModel.fromEntity(entity)).toList();
    await hiveHelper.cacheItems(itemModels, pageIndex);
  }

  @override
  Future<List<ItemEntity>?> getCachedItems(int pageIndex) async {
    final cachedItems = await hiveHelper.getCachedItems(pageIndex);
    if (cachedItems == null) return null;

    return cachedItems.map((model) => ItemEntity(
          id: model.id,
          title: model.title,
          description: model.description,
          price: model.price,
          rating: model.rating,
          brand: model.brand,
          category: model.category,
          thumbnail: model.thumbnail,
        )).toList();
  }

  @override
  Future<void> clearCache() async {
    await hiveHelper.clearCache();
  }
} 