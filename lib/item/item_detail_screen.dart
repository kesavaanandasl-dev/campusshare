import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat/chat_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final QueryDocumentSnapshot item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool showOverview = true;
  bool openingChat = false;

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final ownerUid = widget.item['ownerUid'];
    final itemId = widget.item.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 Image section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      widget.item['imageUrl'],
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _circleIcon(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            // 📄 Content
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs
                    Row(
                      children: [
                        _TabItem(
                          title: "Overview",
                          active: showOverview,
                          onTap: () => setState(() => showOverview = true),
                        ),
                        const SizedBox(width: 24),
                        _TabItem(
                          title: "Details",
                          active: !showOverview,
                          onTap: () => setState(() => showOverview = false),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (showOverview) ...[
                      Text(
                        'Title: "${widget.item['title']}"',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Category: "${widget.item['category']}"',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      Text(
                        widget.item['description'],
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],

                    const Spacer(),

                    // 💬 Chat Button
                    if (currentUid != ownerUid)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: openingChat
                              ? null
                              : () async {
                                  setState(() => openingChat = true);

                                  try {
                                    final chatRef = FirebaseFirestore.instance
                                        .collection('chats')
                                        .doc(itemId);

                                    final doc = await chatRef.get();

                                    if (!doc.exists) {
                                      await chatRef.set({
                                        'itemId': itemId,
                                        'ownerUid': ownerUid,
                                        'ownerName':
                                            widget.item['ownerName'],
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                    }

                                    if (!mounted) return;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          ownerName:
                                              widget.item['ownerName'],
                                          itemId: itemId,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Error opening chat")),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => openingChat = false);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B2FF7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: openingChat
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Chat with Lender",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      )
                    else
                      const Center(
                        child: Text(
                          "This is your item",
                          style: TextStyle(color: Colors.grey),
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

  Widget _circleIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 6),
              height: 3,
              width: 26,
              color: const Color(0xFF7B2FF7),
            ),
        ],
      ),
    );
  }
}
