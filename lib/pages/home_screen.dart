import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ram_trade/components/item_card.dart';
import 'package:ram_trade/cubits/favorites/favorites_cubit.dart';
import 'package:ram_trade/cubits/items/items_cubit.dart';
import 'package:ram_trade/pages/category_screen.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:ram_trade/components/my_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemsCubit()..loadItems(),
      child: HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FavoritesCubit()..loadFavorites(supabase.auth.currentUser!.id),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "🐏 Ram Trade",
            style: TextStyle(fontSize: 24),
          ),
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.chat_bubble),
              onPressed: () {
                // Implement chat button functionality
              },
            ),
          ],
        ),
        drawer: const MyDrawer(),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<ItemsCubit>().loadItems();
          },
          child: BlocBuilder<ItemsCubit, ItemsState>(
            builder: (context, state) {
              if (state is ItemsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemsLoaded) {
                // debugPrint(state.categories.toString());

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome to Ram Trade",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "where one man's trash is another's treasure",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 5,
                          ),
                          itemCount: state.categories.length,
                          itemBuilder: (context, index) {
                            final category = state.categories[index];
                            return ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (_) => ItemsCubit()
                                        ..loadItemsByCategory(
                                            category['categoryid']),
                                      child: CategoryScreen(
                                        categoryId: category['categoryid'],
                                        categoryName: category['name'],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Text(category['name'].toString().trim()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Recent Listings",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 0.69,
                          ),
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return ItemCard(item: item);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is ItemsError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('Start by loading items.'));
            },
          ),
        ),
      ),
    );
  }
}
