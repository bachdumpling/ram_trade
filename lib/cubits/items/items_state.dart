part of 'items_cubit.dart';

@immutable
abstract class ItemsState {}

class ItemsInitial extends ItemsState {}

class ItemsLoading extends ItemsState {}

class ItemsLoaded extends ItemsState {
  final List items;
  final List categories;

  ItemsLoaded(this.items, this.categories);
}

class ItemsError extends ItemsState {
  final String message;

  ItemsError(this.message);
}
