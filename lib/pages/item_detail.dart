import 'package:flutter/material.dart';
import 'package:ram_trade/main.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map item;

  const ItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    final String name = item['title'] ?? 'Name not available';
    final double price = item['price'] ?? 'Price not available';
    final String description =
        item['description'] ?? 'Description not available';
    final String sellerName = item['sellerName'] ?? 'Seller not available';
    final List photos = item['photos'] ?? [];
    final DateTime createdAt =
        DateTime.parse(item['created_at']?.toString() ?? '');

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 400,
                child: photos.isNotEmpty
                    ? PageView(
                        controller: controller,
                        scrollDirection: Axis.horizontal,
                        children: photos
                            .map((photoUrl) => Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                ))
                            .toList(),
                      )
                    : Image.network(
                        'assets/default-profile-picture.png',
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: photos.length,
                      effect: const ExpandingDotsEffect(
                        dotColor: Colors.grey,
                        activeDotColor: Colors.red,
                        dotHeight: 6,
                        dotWidth: 6,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    Text(
                      "Listed - ${createdAt.differenceFromNow().formatTimeDifference()} ago",
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text("\$${price.toString()}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
              
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                const Text('Details',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(description),
                const SizedBox(height: 16),
                const Text('Seller',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(sellerName),
                const SizedBox(height: 16),
                const Text('Similar Items',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
