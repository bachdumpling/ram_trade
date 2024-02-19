import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ram_trade/cubits/favorites/favorites_cubit.dart';
import 'package:ram_trade/main.dart';
import 'package:ram_trade/pages/item_detail.dart';
import 'package:ram_trade/utils/constants.dart';

enum CardOrientation { vertical, horizontal }

class ItemCard extends StatelessWidget {
  final Map item;
  final CardOrientation orientation;

  const ItemCard({
    super.key,
    required this.item,
    this.orientation = CardOrientation.vertical, // default to vertical
  });

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser!.id;
    final itemId = item['id']; // Define itemId from item map

    // Load favorites when the widget is built
    context.read<FavoritesCubit>().loadFavorites(userId);

    return BlocBuilder<FavoritesCubit, FavoriteState>(
      builder: (context, state) {
        bool isFavorite = false;
        if (state is FavoritesLoaded) {
          isFavorite = state.favoriteItemIds.contains(itemId);
        }

        return _buildVerticalCard(context, isFavorite, item, userId);

        // return orientation == CardOrientation.vertical
        //     ? _buildVerticalCard(context, isFavorite, item, userId)
        //     : _buildHorizontalCard(context, isFavorite, item,
        //         userId); // Ensure you define _buildHorizontalCard if you plan to use it
      },
    );
  }

  Widget _buildVerticalCard(
      BuildContext context, bool isFavorite, Map item, userId) {
    // Extract data from item object
    final String name = item['title'];
    final String price = item['price'].toString();
    final List photos = item['photos'];
    final DateTime createdAt = DateTime.parse(item['created_at'].toString());
    final Duration listedTime = DateTime.now().difference(createdAt);
    final Map user = item['user'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailScreen(
                item: item,
                user: user,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, // Align children to the start of the column
          children: <Widget>[
            // Stack to overlay the favorite button on the image
            Stack(
              alignment: Alignment
                  .bottomRight, // Align the favorite button at the bottom right
              children: [
                AspectRatio(
                  aspectRatio:
                      1, // Adjust according to your image's aspect ratio
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    width:
                        double.infinity, // Make container take the full width
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    ),
                    child: photos.isNotEmpty
                        ? Image.network(photos.first, fit: BoxFit.cover)
                        : Image.asset(
                            "assets/images/default-profile-picture.png",
                            fit: BoxFit.cover),
                  ),
                ),
                // Favorite button
                Padding(
                  padding: const EdgeInsets.all(
                      8.0), // Add some padding around the button
                  child: IconButton(
                    icon: Icon(
                      isFavorite
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      // Access the FavoritesCubit instance directly from the context
                      context
                          .read<FavoritesCubit>()
                          .toggleFavorite(userId, item['id']);
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.toCapitalized(),
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          // 'Listed by ${listedTime.formatTimeDifference()}',
                          'Listed by ${user['first_name']}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    // Space between text and price
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context, bool isFavorite, itemId) {
    // Extract data from item object
    final String name = item['title'];
    final String price = item['price'].toString();
    final List photos = item['photos'];
    final DateTime createdAt = DateTime.parse(item['created_at'].toString());
    final Duration listedTime = DateTime.now().difference(createdAt);
    final Map user = item['user'];

    return SizedBox(
      height: 125,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(
                  item: item,
                  user: user,
                ),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment
                .stretch, // To ensure children of Row fill the card vertically
            children: <Widget>[
              // Placeholder for the image
              Container(
                clipBehavior: Clip.antiAlias,
                width: 125,
                height: 125,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(6.0),
                  ),
                ),
                child: photos.isNotEmpty
                    ? Image.network(photos.first,
                        width: 120, height: 120, fit: BoxFit.cover)
                    : Image.asset("assets/images/default-profile-picture.png",
                        width: 120, height: 120, fit: BoxFit.cover),
              ),
              // Item details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // This will space out children vertically
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.toCapitalized(),
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Listed - ${listedTime.formatTimeDifference()}',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          price,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
