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

  @override
  void initState() {
    super.initState();
    _loadItems();
    // _loadCategories();
  }

  // pull items data from supabase
  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
    });

    try {
      // select items from the items table ordering from newest to oldests
      items = await supabase
          .from('items')
          .select('*')
          .order('created_at', ascending: false);
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Needed for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        // title: const Text("Home"),
        elevation: 1,
        actions: [
          IconButton(
            icon: Container(
                margin: const EdgeInsets.only(right: 12.0),
                child: const Icon(Icons.chat_bubble_outline)),
            onPressed: () {
              debugPrint('Chat button tapped.');
              // Add your search functionality here.
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            // Landing page title
            const Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to Ram Trade",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "where one man's trash is another's treasure",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Text(
                  "Recent Listings",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildBody(),
          ],
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
    return Expanded(
      // Wrap with Expanded
      child: ListView.builder(
        itemCount: items!.length,
        itemBuilder: (context, index) => _buildItemCard(index),
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = items![index];
    final createdAt = DateTime.parse(item['created_at']?.toString() ?? '');
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    return ItemCard(
      itemName: item['title'] as String,
      listedTime: difference,
      price: item['price'].toString(),
      imageUrl: (item['photos'] as List).isNotEmpty
          ? item['photos'][0] as String
          : '',
    );
  }

  @override
  bool get wantKeepAlive => true;
}
