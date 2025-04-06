import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/item_bloc.dart';
import '../bloc/item_event.dart';
import '../bloc/item_state.dart';
import '../widgets/item_tile.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final _scrollController = ScrollController();
  bool _hasShownEndMessage = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
    dev.log('ItemListPage initialized');
  }

  void _loadInitialData() {
    dev.log('Loading initial data');
    context.read<ItemBloc>().add(LoadItems());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    dev.log('Scrolling - offset: ${_scrollController.offset}, maxExtent: ${_scrollController.position.maxScrollExtent}');
    if (_isBottom) {
      dev.log('Reached bottom, loading more items');
      context.read<ItemBloc>().add(LoadMoreItems());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) {
      dev.log('ScrollController has no clients');
      return false;
    }
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final isBottom = currentScroll >= (maxScroll * 0.9);
    dev.log('isBottom check: currentScroll=$currentScroll, maxScroll=$maxScroll, isBottom=$isBottom');
    return isBottom;
  }

  void _showEndOfListMessage() {
    if (!_hasShownEndMessage) {
      _hasShownEndMessage = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have reached the end of the list'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paginated Items'),
      ),
      body: BlocConsumer<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemLoaded) {
            dev.log('Items loaded - count: ${state.items.length}, hasReachedMax: ${state.hasReachedMax}');
            if (state.hasReachedMax) {
              _showEndOfListMessage();
            }
          }
          if (state is ItemError) {
            dev.log('Error loading items: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ItemInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ItemError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ItemLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('No items found'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                dev.log('Refreshing items');
                _hasShownEndMessage = false; // Reset the flag on refresh
                context.read<ItemBloc>().add(LoadItems(refresh: true));
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.items.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    dev.log('Building loading indicator at index $index');
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return ItemTile(item: state.items[index]);
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
} 