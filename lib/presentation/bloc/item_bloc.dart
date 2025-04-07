import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_paginated_items.dart';
import 'item_event.dart';
import 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetPaginatedItems getPaginatedItems;
  static const int _itemsPerPage = 5;
  bool _isLoading = false;

  ItemBloc({required this.getPaginatedItems}) : super(ItemInitial()) {
    on<LoadItems>(_onLoadItems);
    on<LoadMoreItems>(_onLoadMoreItems);
  }

  void _resetLoading() {
    _isLoading = false;
  }

  Future<void> _onLoadItems(LoadItems event, Emitter<ItemState> emit) async {
    try {
      if (!_isLoading) {
        dev.log('Loading items - refresh: ${event.refresh}');
        _isLoading = true;
        
        if (event.refresh) {
          emit(ItemLoading());
          dev.log('Clearing cache');
          await getPaginatedItems.clearCache();
        }
        
        final items = await getPaginatedItems.execute(0);
        dev.log('Items loaded - count: ${items.length}');
        
        emit(ItemLoaded(
          items: items,
          hasReachedMax: getPaginatedItems.hasReachedMax(items.length),
        ));
      } else {
        dev.log('Skipping load - already loading');
      }
    } catch (e) {
      dev.log('Error loading items: $e');
      emit(ItemError(e.toString()));
    } finally {
      _resetLoading();
    }
  }

  Future<void> _onLoadMoreItems(LoadMoreItems event, Emitter<ItemState> emit) async {
    if (state is! ItemLoaded || _isLoading) {
      dev.log('Cannot load more - wrong state or already loading');
      return;
    }

    try {
      _isLoading = true;
      final currentState = state as ItemLoaded;
      
      if (!currentState.hasReachedMax) {
        dev.log('Loading more items - current count: ${currentState.items.length}');
        final moreItems = await getPaginatedItems.execute(currentState.items.length);
        
        if (moreItems.isEmpty) {
          dev.log('No more items received');
          emit(currentState.copyWith(hasReachedMax: true));
          return;
        }

        final hasReached = getPaginatedItems.hasReachedMax(
          currentState.items.length + moreItems.length,
        );
        dev.log('More items loaded - count: ${moreItems.length}, hasReachedMax: $hasReached');
        
        emit(
          currentState.copyWith(
            items: List.of(currentState.items)..addAll(moreItems),
            hasReachedMax: hasReached,
          ),
        );
      } else {
        dev.log('Already reached max items');
      }
    } catch (e) {
      dev.log('Error loading more items: $e');
      if (state is ItemLoaded) {
        final currentState = state as ItemLoaded;
        emit(currentState.copyWith(hasReachedMax: true)); // Prevent further loading attempts
      } else {
        emit(ItemError(e.toString()));
      }
    } finally {
      _resetLoading();
    }
  }
} 