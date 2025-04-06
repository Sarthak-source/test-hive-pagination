abstract class ItemEvent {}

class LoadItems extends ItemEvent {
  final bool refresh;
  LoadItems({this.refresh = false});
}

class LoadMoreItems extends ItemEvent {} 