import '../../domain/entities/item_entity.dart';

abstract class ItemState {}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemLoaded extends ItemState {
  final List<ItemEntity> items;
  final bool hasReachedMax;

  ItemLoaded({
    required this.items,
    this.hasReachedMax = false,
  });

  ItemLoaded copyWith({
    List<ItemEntity>? items,
    bool? hasReachedMax,
  }) {
    return ItemLoaded(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ItemError extends ItemState {
  final String message;
  ItemError(this.message);
} 