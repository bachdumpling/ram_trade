part of 'favorites_cubit.dart';

@immutable
abstract class FavoriteState {}

class FavoritesInitial extends FavoriteState {}

class FavoritesLoaded extends FavoriteState {
  final Set<String> favoriteItemIds;

  FavoritesLoaded({required this.favoriteItemIds});
}

class FavoritesError extends FavoriteState {
  final String message;

  FavoritesError(this.message);
}

