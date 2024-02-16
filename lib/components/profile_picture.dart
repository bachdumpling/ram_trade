import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture(
      {super.key, required this.profileImageUrl, required this.onUpload});

  final String? profileImageUrl;
  final void Function(String profileImageUrl) onUpload;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            )),
        const SizedBox(
          height: 12,
        ),
        ElevatedButton(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();

            // Pick an image.
            final XFile? image =
                await picker.pickImage(source: ImageSource.gallery);
            if (image == null) {
              return;
            }

            // Upload the image to the server.
            final imageExtension = image.path.split('.').last.toLowerCase();
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
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
