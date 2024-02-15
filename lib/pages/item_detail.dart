import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ram_trade/main.dart';
import 'package:ram_trade/utils/hex_color.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map item;
  final Map user;

  const ItemDetailScreen({Key? key, required this.item, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    final String name = item['title'] ?? 'Name not available';
    final dynamic price = item['price'] ?? 'Price not available';
    final String description =
        item['description'] ?? 'Description not available';
    final String sellerName =
        user['first_name'] + ' ' + user['last_name'] ?? 'Seller not available';
    final List photos = item['photos'] ?? [];
    final DateTime createdAt =
        DateTime.parse(item['created_at']?.toString() ?? '');

    return Scaffold(
      extendBody: true,
      body: SingleChildScrollView(
        child: Column(
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
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black),
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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(description),
                  const SizedBox(height: 16),
                  const Text('Seller',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 12),
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(30),
                            //   border: Border.all(
                            //     color: Colors.grey[300]!,
                            //     width: 1,
                            //   ),
                            // ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                  user['profile_url'] ??
                                      'assets/default-profile-picture.png'),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sellerName,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const Text(
                                'View Profile',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        '# Reviews',
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Similar Items',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),

      // Chat, bid, and buy buttons
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('Chat button tapped.');
                      // Add your chat functionality here.
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor("008b00"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        )),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.0),
                      child: Icon(
                        CupertinoIcons.chat_bubble_2_fill,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('Bid button tapped.');
                      // Add your bid functionality here.
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor("#F1E4E9"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.0),
                      child: Text('Make offer', style: TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('Buy button tapped.');
                      // Add your buy functionality here.
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor("860038"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.0),
                      child: Text('Buy', style: TextStyle(fontSize: 16,color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
