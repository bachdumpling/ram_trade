import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String itemName;
  final Duration listedTime;
  final String price;
  final String imageUrl;

  const ItemCard({
    Key? key,
    required this.itemName,
    required this.listedTime,
    required this.price,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: IntrinsicHeight(
        // This ensures that the Row has a finite height
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            debugPrint('Card tapped.');
            // Add your onTap functionality here. For example, navigate to a detail page.
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment
                .stretch, // To ensure children of Row fill the card vertically
            children: <Widget>[
              // Placeholder for the image
              Container(
                clipBehavior: Clip.antiAlias,
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  // color: Colors.grey[300],
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(6.0),
                  ),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
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
                            itemName,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Listed - ${_formatTimeDifference(listedTime)}',
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

  String _formatTimeDifference(Duration difference) {
    if (difference.inHours >= 1) {
      return '${difference.inHours} hrs';
    } else {
      return '${difference.inMinutes} mins';
    }
  }
}
