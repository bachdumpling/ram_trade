import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:ram_trade/utils/constants.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoriteState> {
  FavoritesCubit() : super(FavoritesInitial());

  Future<void> loadFavorites(String profileId) async {
    final data = await supabase
        .from('favorite_items')
        .select('item_id')
        .eq('profile_id', profileId) as List<dynamic>;

    if (data.isNotEmpty) {
      final itemIds = data.map((e) => e['item_id'] as String).toSet();
      // Emitting FavoritesLoaded state with the item IDs
      emit(FavoritesLoaded(favoriteItemIds: itemIds));
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  Future<void> toggleFavorite(String profileId, String itemId) async {
    if (state is FavoritesLoaded) {
      final loadedState = state as FavoritesLoaded;
      if (loadedState.favoriteItemIds.contains(itemId)) {
        await supabase
            .from('favorite_items')
            .delete()
            .match({'profile_id': profileId, 'item_id': itemId});
        // Emitting updated state without the removed item
        emit(FavoritesLoaded(
            favoriteItemIds: Set.from(loadedState.favoriteItemIds)
              ..remove(itemId)));
      } else {
        await supabase
            .from('favorite_items')
            .insert({'profile_id': profileId, 'item_id': itemId});
        // Emitting updated state with the added item
        emit(FavoritesLoaded(
            favoriteItemIds: Set.from(loadedState.favoriteItemIds)
              ..add(itemId)));
      }
    } else {
      throw Exception('Failed to toggle favorite');
    }
  }
}