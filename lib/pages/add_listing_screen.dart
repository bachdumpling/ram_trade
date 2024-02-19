import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({Key? key}) : super(key: key);

  @override
  _AddListingScreenState createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String _itemName = '';
  String _description = '';
  String _price = '';
  List? _categories;
  int? _selectedCategory;
  final List _conditions = ['New', 'Used', 'Like New'];
  String? _selectedCondition;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _loadRecentListings();
  }

  Future<void> _selectImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  // pull items data from supabase
  Future<void> _loadRecentListings() async {
    setState(() {
      _loading = true;
    });

    try {
      // select items from the items table ordering from newest to oldests
      _categories = await supabase.from('categories').select('*');
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Process data and submit your listing
      print('Item Name: $_itemName');
      print('Description: $_description');
      print('Price: ${double.tryParse(_price)}');
      print('Images: $_selectedImages');
      print('Category ID: $_selectedCategory');
      print('Condition: $_selectedCondition');
    }
  }

  Future<void> _uploadListing(BuildContext context) async {
    setState(() {
      _loading = true;
    });

    final userid = supabase.auth.currentUser?.id;
    final itemid = const Uuid().v4();

    if (userid == null) {
      print("User not logged in");
      return;
    }

    final createItem = {
      "itemid": itemid,
      'userid': userid,
      'categoryid': _selectedCategory,
      'title': _itemName,
      'description': _description,
      'price': double.tryParse(_price),
      'condition': _selectedCondition,
    };

    try {
      // Step 1: Create the listing in the database
      await supabase.from('items').insert(createItem);

      // Step 2: Upload images to Storage
      List uploadedImageUrls = [];
      for (var imageFile in _selectedImages) {
        final fileExtension = imageFile.path.split('.').last.toLowerCase();
        final imageBytes = await imageFile.readAsBytes();
        final storagePath =
            '$userid/$itemid/${const Uuid().v4()}.$fileExtension';

        await supabase.storage.from('items').uploadBinary(
              storagePath,
              imageBytes,
              fileOptions: FileOptions(
                  upsert: true, contentType: 'image/$fileExtension'),
            );
        String imageUrl =
            supabase.storage.from('items').getPublicUrl(storagePath);
        imageUrl = Uri.parse(imageUrl).replace(queryParameters: {
          "t": DateTime.now().millisecondsSinceEpoch.toString()
        }).toString();

        uploadedImageUrls.add(imageUrl);
      }

      // Step 3: Update the listing with image URLs
      await supabase.from('items').update({
        'photos': uploadedImageUrls,
      }).match({'itemid': itemid});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing created successfully'),
          ),
        );
      }
    } on PostgrestException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while creating the listing'),
        ),
      );
      rethrow;
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unexpected error occurred'),
        ),
      );
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a Listing"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8.0,
                  children: _selectedImages
                      .map((file) =>
                          Image.file(File(file.path), width: 100, height: 100))
                      .toList(),
                ),
                ElevatedButton(
                  onPressed: _selectImages,
                  child: const Text('Add Photos'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an item name' : null,
                  onSaved: (value) => _itemName = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                  onSaved: (value) => _description = value!,
                ),
                DropdownButtonFormField(
                  items: _categories?.map((category) {
                        return DropdownMenuItem(
                          value: category['categoryid'],
                          child: Text(category['name']),
                        );
                      }).toList() ??
                      [],
                  onChanged: (value) {
                    _selectedCategory = int.tryParse(value.toString()) as int;
                  },
                  hint: const Text('Select Condition'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a price' : null,
                  onSaved: (value) => _price = value!,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField(
                  items: _conditions
                      .map((condition) => DropdownMenuItem(
                            value: condition,
                            child: Text(condition),
                          ))
                      .toList(),
                  onChanged: (value) {
                    _selectedCondition = value.toString();
                  },
                  hint: const Text('Select Condition'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : () => _uploadListing(context),
                  // onPressed: _loading ? null : () => _submitForm(),s
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50), // fixed height
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
