import 'package:freezed_annotation/freezed_annotation.dart';

import 'item_model.dart';

part 'products_response.freezed.dart';
part 'products_response.g.dart';

@freezed
class ProductsResponse with _$ProductsResponse {
  const factory ProductsResponse({
    required List<ItemModel> products,
    required int total,
    required int skip,
    required int limit,
  }) = _ProductsResponse;

  factory ProductsResponse.fromJson(Map<String, dynamic> json) => _$ProductsResponseFromJson(json);
} 