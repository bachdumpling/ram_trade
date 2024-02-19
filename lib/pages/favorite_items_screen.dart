import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ram_trade/components/item_card.dart';
import 'package:ram_trade/components/item_filter.dart';
import 'package:ram_trade/cubits/favorites/favorites_cubit.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteItemsScreen extends StatefulWidget {
  const FavoriteItemsScreen({super.key});

  @override
  State<FavoriteItemsScreen> createState() => _MFavoriteItemsScreenState();
}

class _MFavoriteItemsScreenState extends State<FavoriteItemsScreen> {
  var _loading = true;
  List<dynamic>? favoriteItems;
  String? userId = supabase.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _applySort(SortOption selectedSort) {
    if (favoriteItems == null) {
      return;
    }

    setState(() {
      favoriteItems!.sort((a, b) {
        switch (selectedSort) {
          case SortOption.priceLowToHigh:
            return a['items']['price'].compareTo(b['items']['price']);
          case SortOption.priceHighToLow:
            return b['items']['price'].compareTo(a['items']['price']);
          case SortOption.newest:
            return DateTime.parse(b['items']['created_at'])
                .compareTo(DateTime.parse(a['items']['created_at']));
          case SortOption.oldest:
            return DateTime.parse(a['items']['created_at'])
                .compareTo(DateTime.parse(b['items']['created_at']));
        }
      });
    });
  }

  // pull items data from supabase
  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
    });

    try {
      favoriteItems = await supabase
          .from('favorite_items')
          .select(
              '*, items(id, title, description, price, photos, created_at, user:profile_id(*))')
          .eq("profile_id", userId as String)
          .order('created_at', ascending: false);
    } on PostgrestException catch (error) {
      // Ensure to show SnackBar properly
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } catch (error) {
      // Ensure to show SnackBar properly
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Favorite Items")),
        body: RefreshIndicator(
          onRefresh: _loadItems,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Items: ${favoriteItems?.length}"),
                    FilterComponent(
                      onSortChanged: (SortOption selectedSort) {
                        _applySort(selectedSort);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildItemList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemList() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [Center(child: CircularProgressIndicator())],
      );
    } else if (favoriteItems == null || favoriteItems!.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [Center(child: Text("No favorite items."))],
      );
    } else {
      return GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 6.0,
          childAspectRatio: 0.67,
        ),
        itemCount: favoriteItems!.length,
        itemBuilder: (context, index) {
          final item = favoriteItems![index]['items'];
          return ItemCard(item: item);
        },
      );
    }
  }
}
