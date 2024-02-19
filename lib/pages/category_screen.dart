import 'package:flutter/material.dart';
import 'package:ram_trade/components/item_card.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _loading = true;
  List? itemsInCategory;

  @override
  void initState() {
    super.initState();
    _loadItemsInCategory();
  }

  Future<void> _loadItemsInCategory() async {
    setState(() {
      _loading = true;
    });

    try {
      // Adjust the query to match your database schema
      // Here we're assuming there's a categoryId field in the items table
      itemsInCategory = await supabase
          .from('items')
          .select(
              'id, title, description, price, photos, created_at, user:profile_id(*)')
          .eq('categoryid', widget.categoryId) // Filter by categoryId
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
    debugPrint(itemsInCategory?.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Padding(padding: const EdgeInsets.all(16), child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (itemsInCategory == null || itemsInCategory!.isEmpty) {
      return const Center(child: Text("No items found in this category."));
    } else {
      return _buildItemList();
    }
  }

  Widget _buildItemList() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 6.0,
        mainAxisSpacing: 6.0,
        childAspectRatio: 0.67,
      ),
      itemCount: itemsInCategory!.length,
      itemBuilder: (context, index) {
        final item = itemsInCategory![index];
        return ItemCard(item: item);
      },
    );
  }
}
