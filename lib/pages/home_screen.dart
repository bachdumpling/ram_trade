import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ram_trade/components/item_card.dart';
import 'package:ram_trade/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ram_trade/components/my_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  var _loading = true;
  List? items;
  List? categories;

  @override
  void initState() {
    super.initState();
    _loadRecentListings();
  }

  // pull items data from supabase
  Future<void> _loadRecentListings() async {
    setState(() {
      _loading = true;
    });

    try {
      // select items from the items table ordering from newest to oldests
      items = await supabase
          .from('items')
          .select('itemid, title, description, price, photos, created_at, user:userid(*)')
          .order('created_at', ascending: false);

      categories = await supabase.from('categories').select('*');
    } on PostgrestException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      rethrow;
    } catch (error) {
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      rethrow;
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Future<void> _loadCategories() async {
  //   setState(() {
  //     _loading = true;
  //   });

  //   try {
  //     // select items from the items table ordering from newest to oldests
  //     sellerName = await supabase.from('categories').select('*');
  //   } on PostgrestException catch (error) {
  //     SnackBar(
  //       content: Text(error.message),
  //       backgroundColor: Theme.of(context).colorScheme.error,
  //     );
  //     rethrow;
  //   } catch (error) {
  //     SnackBar(
  //       content: Text(error.toString()),
  //       backgroundColor: Theme.of(context).colorScheme.error,
  //     );
  //     rethrow;
  //   } finally {
  //     setState(() {
  //       _loading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Needed for AutomaticKeepAliveClientMixin

    debugPrint(items?[0].toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🐏",
          style: TextStyle(fontSize: 24),
        ),
        elevation: 1,
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
            ),
            icon: Container(
                margin: const EdgeInsets.only(right: 12.0),
                child: const Icon(CupertinoIcons.chat_bubble)),
            onPressed: () {
              debugPrint('Chat button tapped.');
              // Add your search functionality here.
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadRecentListings();
        },
        child: SingleChildScrollView(
          // Use SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Align children to the start of the column
              children: [
                // Landing page title
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
                Row(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap:
                            true, // Use shrinkWrap to make GridView take the minimum space
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable scrolling inside the GridView
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of buttons per row
                          crossAxisSpacing:
                              6.0, // Space between buttons horizontally
                          mainAxisSpacing:
                              6.0, // Space between buttons vertically
                          childAspectRatio:
                              5, // Adjust the ratio according to your button's design
                        ),
                        itemCount: categories?.length ?? 0,
                        itemBuilder: (context, index) {
                          final category = categories![index];
                          return ElevatedButton(
                            onPressed: () {
                              debugPrint('Category button tapped.');
                              // Add your category functionality here.
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(6), // Round corners
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              splashFactory: NoSplash.splashFactory,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary, // Text color
                            ),
                            child: Text(category['name'] as String,
                                style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ),
                  ],
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
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (items == null || items!.isEmpty) {
      return const Center(child: Text("No items found."));
    } else {
      return _buildItemList();
    }
  }

  Widget _buildItemList() {
    return Column(
      children: List.generate(items!.length, (index) => _buildItemCard(index)),
    );
  }

  Widget _buildItemCard(int index) {
    final item = items![index];
    final createdAt = DateTime.parse(item['created_at']?.toString() ?? '');

    return ItemCard(
      user: item['user'] as Map,
      item: item as Map,
      name: item['title'] as String,
      description: item['description'] as String,
      listedTime: createdAt.differenceFromNow(),
      price: item['price'].toString(),
      photos: (item['photos'] as List).isNotEmpty ? item['photos'] : '',
    );
  }

  @override
  bool get wantKeepAlive => true;
}
