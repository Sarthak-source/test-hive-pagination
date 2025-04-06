import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/item_entity.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';

@freezed
@HiveType(typeId: 0)
class ItemModel with _$ItemModel {
  const factory ItemModel({
    @HiveField(0) required int id,
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required double price,
    @HiveField(4) required double rating,
    @HiveField(5) required String brand,
    @HiveField(6) required String category,
    @HiveField(7) required String thumbnail,
  }) = _ItemModel;

  factory ItemModel.fromJson(Map<String, dynamic> json) => _$ItemModelFromJson(json);

  factory ItemModel.fromEntity(ItemEntity entity) => ItemModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        price: entity.price,
        rating: entity.rating,
        brand: entity.brand,
        category: entity.category,
        thumbnail: entity.thumbnail,
      );
} 