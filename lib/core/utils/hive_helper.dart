import 'package:hive/hive.dart';

import '../../data/models/item_model.dart';

class HiveHelper {
  static const String cachedItemsBox = 'cached_items_box';

  Future<Box> openCachedItemsBox() async {
    return await Hive.openBox(cachedItemsBox);
  }

  Future<void> cacheItems(List<ItemModel> items, int pageIndex) async {
    final box = await openCachedItemsBox();
    await box.put(pageIndex.toString(), items);
  }

  Future<List<ItemModel>?> getCachedItems(int pageIndex) async {
    final box = await openCachedItemsBox();
    final items = box.get(pageIndex.toString());
    return items?.cast<ItemModel>();
  }

  Future<void> clearCache() async {
    final box = await openCachedItemsBox();
    await box.clear();
  }
} 