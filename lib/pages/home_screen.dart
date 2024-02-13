import 'package:flutter/material.dart';
import 'package:ram_trade/components/item_card.dart';
import 'package:ram_trade/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    super.build(context);

    if (_loading) {
      // If still loading, show a loading indicator
      return Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (items == null || items!.isEmpty) {
      // If items are null or empty, show a message
      return Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: const Center(child: Text("No items found.")),
      );
    } else {
      // If items are loaded and not null, build the ListView
      return Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: ListView.builder(
          itemCount: items!.length,
          itemBuilder: (context, index) {
            final item = items![index];
            final createdAt =
                DateTime.parse(item['created_at']?.toString() ?? '');
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
          },
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
