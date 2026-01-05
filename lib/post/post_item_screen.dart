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

  // ================= RESET FORM =================
  void _resetForm() {
    titleCtrl.clear();
    descCtrl.clear();
    setState(() {
      image = null;
      category = 'Books';
      loading = false;
    });
  }

  Future<void> pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  // ================= CONFIRMATION =================
  Future<void> _confirmPost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Post"),
        content: const Text(
          "Are you sure you want to post this item?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Post"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      postItem();
    }
  }

  // ================= POST ITEM =================
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
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Posted successfully")),
      );

      _resetForm();
      widget.onPostSuccess();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "You're almost there!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            const Text("Add Title"),
            const SizedBox(height: 6),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                hintText: "Ad title here..",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const Text("Description"),
            const SizedBox(height: 6),
            TextField(
              controller: descCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Write something here...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Main Picture (Max 3MB)"),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: pickImage,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text("ADD MAIN PICTURE"),
            ),

            if (image != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  image!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: category,
              items: const [
                DropdownMenuItem(value: 'Books', child: Text('Books')),
                DropdownMenuItem(value: 'Stationery', child: Text('Stationery')),
                DropdownMenuItem(value: 'Gadgets', child: Text('Gadgets')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => category = value!),
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _confirmPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2FF7),
                  foregroundColor: Colors.white, // 👈 text & icon color
                ),

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Post",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
