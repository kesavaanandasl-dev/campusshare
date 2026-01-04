import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../post/cloudinary_service.dart';

class PostItemScreen extends StatefulWidget {
  final VoidCallback onPostSuccess;

  const PostItemScreen({
    super.key,
    required this.onPostSuccess,
  });

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  File? image;
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String category = 'Books';
  bool loading = false;

  Future<void> pickImage() async {
        final picked =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (picked != null) {
          setState(() => image = File(picked.path));
        }
      }

      Future<void> postItem() async {
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an image")),
        );
        return;
      }

      if (titleCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Title is required")),
        );
        return;
      }

      setState(() => loading = true);

      try {
        final user = FirebaseAuth.instance.currentUser!;
        final uid = user.uid;

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        final ownerName =
            userDoc.data()?['name'] ?? 'CampusShare User';

        final imageUrl =
            await CloudinaryService.uploadImage(image!);

        if (imageUrl == null) {
          throw Exception("Image upload failed");
        }

        await FirebaseFirestore.instance.collection('items').add({
          'title': titleCtrl.text.trim(),
          'description': descCtrl.text.trim(),
          'category': category,
          'imageUrl': imageUrl,
          'ownerUid': uid,
          'ownerName': ownerName,
          'createdAt': FieldValue.serverTimestamp(), // ✅ FIXED
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Posted successfully")),
        );

        widget.onPostSuccess(); // ✅ returns to Home
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        if (mounted) setState(() => loading = false);
    }
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Item")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: image == null
                    ? const Center(child: Icon(Icons.add_a_photo))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: category,
              items: const [
                DropdownMenuItem(value: 'Books', child: Text('Books')),
                DropdownMenuItem(value: 'Stationery', child: Text('Stationery')),
                DropdownMenuItem(value: 'Gadgets', child: Text('Gadgets')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => category = value!),
              decoration: const InputDecoration(labelText: "Category"),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : postItem,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Post"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
