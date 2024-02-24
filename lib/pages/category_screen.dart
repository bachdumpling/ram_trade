import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ram_trade/components/item_card.dart';
import 'package:ram_trade/cubits/favorites/favorites_cubit.dart';
import 'package:ram_trade/cubits/items/items_cubit.dart';
import 'package:ram_trade/utils/constants.dart';

class CategoryScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    // Immediately load items for the category when the screen is built
    context.read<ItemsCubit>().loadItemsByCategory(categoryId);

    return BlocProvider(
      create: (context) =>
          FavoritesCubit()..loadFavorites(supabase.auth.currentUser!.id),
      child: Scaffold(
        appBar: AppBar(
          title: Text(categoryName),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<ItemsCubit>().loadItemsByCategory(categoryId);
          },
          child: BlocBuilder<ItemsCubit, ItemsState>(
            builder: (context, state) {
              if (state is ItemsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemsLoaded) {
                // Filter items by category if your state contains all items
                final itemsInCategory = state.items.toList();
                // debugPrint('Items in category: $itemsInCategory');

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 6.0,
                        mainAxisSpacing: 6.0,
                        childAspectRatio: 0.69,
                      ),
                      itemCount: itemsInCategory.length,
                      itemBuilder: (context, index) {
                        final item = itemsInCategory[index];
                        return ItemCard(
                            item:
                                item); // Ensure ItemCard can accept the item as a parameter
                      },
                    ),
                  ),
                );
              } else if (state is ItemsError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('No items found.'));
            },
          ),
        ),
      ),
    );
  }
}
