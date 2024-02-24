// items_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit() : super(ItemsInitial());

  Future<void> loadItems() async {
    emit(ItemsLoading());
    try {
      // Fetch items and categories from Supabase
      final itemsResponse = await supabase
          .from('items')
          .select(
              'id, title, description, price, photos, created_at, user:profile_id(*)')
          .order('created_at', ascending: false);

      final categoriesResponse = await supabase.from('categories').select('*');

      // Emit loaded state with items and categories
      emit(ItemsLoaded(itemsResponse, categoriesResponse));
    } on PostgrestException catch (error) {
      emit(ItemsError('Failed to load items and categories: $error.'));
      rethrow;
    } catch (error) {
      emit(ItemsError(error.toString()));
    }
  }

  Future<void> loadItemsByCategory(int categoryId) async {
    emit(ItemsLoading());
    try {
      // Fetch items and categories from Supabase
      final itemsInCategory = await supabase
          .from('items')
          .select(
              'id, title, description, price, photos, created_at, user:profile_id(*)')
          .eq('categoryid', categoryId) // Filter by categoryId
          .order('created_at', ascending: false);

      // Emit loaded state with items and categories
      emit(ItemsLoaded(itemsInCategory, const []));
    } on PostgrestException catch (error) {
      emit(ItemsError('Failed to load items in category: $error.'));
      rethrow;
    } catch (error) {
      emit(ItemsError(error.toString()));
    }
  }
}
