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
        appBar: AppBar(
          title: const Text('Favorite',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Implement search functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Implement more options
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadItems,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Column(
                  children: [
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          favoriteItems?.length != null
                              ? Text(
                                  "Items (${favoriteItems?.length})",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                )
                              : const Text("Items #",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  )),
                          FilterComponent(
                            onSortChanged: (SortOption selectedSort) {
                              _applySort(selectedSort);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildItemList(),
                ), // Expanded is no longer needed
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
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Adjust physics here
        children: const [Center(child: CircularProgressIndicator())],
      );
    } else if (favoriteItems == null || favoriteItems!.isEmpty) {
      return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Adjust physics here
        children: const [Center(child: Text("No favorite items."))],
      );
    } else {
      return GridView.builder(
        physics:
            const NeverScrollableScrollPhysics(), // Make GridView non-scrollable
        shrinkWrap:
            true, // Allow GridView to size itself according to its content
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 0.69,
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
