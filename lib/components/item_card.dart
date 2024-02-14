import 'package:flutter/material.dart';
import 'package:ram_trade/main.dart';
import 'package:ram_trade/pages/item_detail.dart';

class ItemCard extends StatelessWidget {
  final String name;
  final String description;
  final Duration listedTime;
  final String price;
  final List photos;
  final Map item;
  final Map user;

  const ItemCard({
    Key? key,
    required this.name,
    required this.description,
    required this.listedTime,
    required this.price,
    required this.photos,
    required this.item, 
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    ? Image.network(
                        photos[0],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
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
                      // Spacer has been removed as it's no longer necessary
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
