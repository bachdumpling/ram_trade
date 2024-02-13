import 'package:flutter/material.dart';
import 'package:ram_trade/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  var _loading = true;
  List? categories; // Store category names here
  List? items;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadItems();
  }

  // pull catagories data from supabase
  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
    });

    try {
      categories = await supabase.from('categories').select('name');
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

  // pull items data from supabase
  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
    });

    try {
      items = await supabase.from('items').select('*');
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
    print(items);
    print("categories: $categories");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Market"),
      ),
      body: const Column(
        children: [
          Text("Categories"),
        ],
      ),
    );
  }
}
