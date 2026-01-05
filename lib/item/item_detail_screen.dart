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
  bool openingChat = false;

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final ownerUid = widget.item['ownerUid'];
    final itemId = widget.item.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // 🖼 IMAGE — ORIGINAL ASPECT RATIO
            Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: Colors.grey.shade100,
                  child: AspectRatio(
                    aspectRatio: 1, // fallback ratio
                    child: Image.network(
                      widget.item['imageUrl'],
                      width: double.infinity,
                      fit: BoxFit.contain, // ✅ NO CROPPING
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 OVERVIEW TITLE
                    const Text(
                      "Overview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🏷 TITLE
                    Text(
                      widget.item['title'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 📂 CATEGORY
                    Text(
                      widget.item['category'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7B2FF7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 📝 DESCRIPTION
                    Text(
                      widget.item['description'],
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),

                    const Spacer(),

                    // 💬 CHAT BUTTON
                    if (myUid != ownerUid)
                      SizedBox(
  width: double.infinity,
  height: 54,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF7B2FF7), // 💜 CampusShare purple
      foregroundColor: Colors.white,             // text color
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    onPressed: openingChat
        ? null
        : () async {
            setState(() => openingChat = true);

            final ids = [itemId, myUid, ownerUid]..sort();
            final chatId = ids.join('_');

            final chatRef = FirebaseFirestore.instance
                .collection('chats')
                .doc(chatId);

            final chatDoc = await chatRef.get();

            if (!chatDoc.exists) {
              final myUserSnap = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(myUid)
                  .get();

              final myName = myUserSnap.data()?['name'] ?? 'Unknown';

              await chatRef.set({
                'itemId': itemId,
                'itemTitle': widget.item['title'],
                'ownerUid': ownerUid,
                'participants': [myUid, ownerUid],
                'participantNames': {
                  myUid: myName,
                  ownerUid: widget.item['ownerName'],
                },
                'lastMessage': 'Chat started',
                'lastMessageAt': FieldValue.serverTimestamp(),
                'lastSenderId': myUid,
              });
            }

            if (!mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatId: chatId,
                  peerName: widget.item['ownerName'],
                ),
              ),
            );

            setState(() => openingChat = false);
          },
    child: const Text(
      "Chat with Lender",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)

                    else
                      const Center(child: Text("This is your item")),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
