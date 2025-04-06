import 'dart:developer' as dev;

import 'package:dio/dio.dart';

import '../models/products_response.dart';

abstract class ItemRemoteDataSource {
  Future<ProductsResponse> getPaginatedItems(int skip, int limit);
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final Dio dio;
  final String baseUrl = 'https://dummyjson.com';

  ItemRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? Dio();

  @override
  Future<ProductsResponse> getPaginatedItems(int skip, int limit) async {
    try {
      dev.log('Fetching items - skip: $skip, limit: $limit');
      final response = await dio.get(
        '$baseUrl/products',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        dev.log('Response received: ${response.data}');
        if (response.data == null) {
          throw Exception('Received null response data');
        }
        
        final responseData = Map<String, dynamic>.from(response.data);
        return ProductsResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      dev.log('Error in remote data source: $e');
      rethrow;
    }
  }
} 