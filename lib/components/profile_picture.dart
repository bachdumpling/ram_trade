import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({
    Key? key,
    required this.profileImageUrl,
    required this.onUpload,
    this.showPlusButton = false, // Default is true to show the plus button
  });

  final String? profileImageUrl;
  final void Function(String profileImageUrl) onUpload;
  final bool showPlusButton; // New parameter to control button display

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment:
          Alignment.bottomRight, // Align the plus button to the bottom right
      children: <Widget>[
        SizedBox(
          width: 100,
          height: 100,
          child: ClipOval(
            child: profileImageUrl != null
                ? Image.network(profileImageUrl!, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        if (showPlusButton) // Check if the plus button should be shown
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2), // Add padding around the circle
              decoration: const BoxDecoration(
                color: Colors
                    .white, // Choose a background color that suits your app
                shape: BoxShape.circle,
              ),
              child: InkWell(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();

                  // Pick an image
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image == null) return;
                  
                  // Upload the image to the server.
                  final imageExtension =
                      image.path.split('.').last.toLowerCase();
                  final imageBytes = await image.readAsBytes();
                  final userId = supabase.auth.currentUser!.id;
                  final imagePath = '/$userId/profile-picture';
                  await supabase.storage.from('profile-pictures').uploadBinary(
                      imagePath, imageBytes,
                      fileOptions: FileOptions(
                          upsert: true, contentType: "image/$imageExtension"));
                  String imageUrl = supabase.storage
                      .from('profile-pictures')
                      .getPublicUrl(imagePath);
                  imageUrl = Uri.parse(imageUrl).replace(queryParameters: {
                    "t": DateTime.now().millisecondsSinceEpoch.toString()
                  }).toString();

                  // Update the UI.
                  onUpload(imageUrl);
                },
                child: const Icon(
                  Icons.add,
                  color:
                      Colors.blue, // Choose an icon color that suits your app
                ),
              ),
            ),
          ),
      ],
    );
  }
}
