import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:post/screens/add_screen.dart';
import 'package:post/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
const HomeScreen({super.key});

CollectionReference get posts =>
FirebaseFirestore.instance.collection('posts');

User? get currentUser => FirebaseAuth.instance.currentUser;

Future<void> likeSwitch(
String docId,
String userId,
List<String> likes,
) async {
final bool isLiked = likes.contains(userId);

await posts.doc(docId).update({
'likes': isLiked
? FieldValue.arrayRemove([userId])
    : FieldValue.arrayUnion([userId]),
});
}

Future<void> deletePost(String docId) async {
await posts.doc(docId).delete();
}

Future<void> confirmDelete(
BuildContext context,
String docId,
) async {
final bool? shouldDelete = await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title: const Text(
'Delete Post',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
content: const Text(
'Are you sure you want to delete this post?',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context, false);
},
child: const Text('Cancel'),
),
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
foregroundColor: Colors.white,
),
onPressed: () {
Navigator.pop(context, true);
},
child: const Text('Delete'),
),
],
);
},
);

if (shouldDelete == true) {
try {
await deletePost(docId);

if (!context.mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Post deleted successfully'),
backgroundColor: Colors.green,
),
);
} catch (e) {
if (!context.mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Could not delete post'),
backgroundColor: Colors.red,
),
);
}
}
}

String formatDate(Timestamp? timestamp) {
if (timestamp == null) return '';

final date = timestamp.toDate();
final now = DateTime.now();
final difference = now.difference(date);

if (difference.inSeconds < 60) {
return 'Just now';
}

if (difference.inMinutes < 60) {
return '${difference.inMinutes}m ago';
}

if (difference.inHours < 24) {
return '${difference.inHours}h ago';
}

if (difference.inDays < 7) {
return '${difference.inDays}d ago';
}

return '${date.day}/${date.month}/${date.year}';
}

@override
Widget build(BuildContext context) {
final String? userId = currentUser?.uid;

return Scaffold(
backgroundColor: Colors.grey.shade100,

appBar: AppBar(
backgroundColor: Colors.blue,
foregroundColor: Colors.white,
elevation: 0,

title: const Text(
'Home',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),

actions: [
IconButton(
tooltip: 'Profile',
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const ProfileScreen(),
),
);
},
icon: const Icon(
Icons.person,
size: 32,
),
),

const SizedBox(width: 8),
],
),

body: StreamBuilder<QuerySnapshot>(
stream: posts
    .orderBy(
'createdAt',
descending: true,
)
    .snapshots(),

builder: (context, snapshot) {
// Loading
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(
color: Colors.blue,
),
);
}

// Error
if (snapshot.hasError) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.error_outline,
size: 70,
color: Colors.red.shade300,
),

const SizedBox(height: 15),

const Text(
'Something went wrong',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

Text(
'Unable to load posts.',
style: TextStyle(
color: Colors.grey.shade600,
),
),
],
),
),
);
}

final postList = snapshot.data?.docs ?? [];

// Empty state
if (postList.isEmpty) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.post_add_rounded,
size: 80,
color: Colors.blue.shade200,
),

const SizedBox(height: 20),

const Text(
'No posts yet',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

Text(
'Be the first person to create a post!',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 15,
color: Colors.grey.shade600,
),
),

const SizedBox(height: 25),

ElevatedButton.icon(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const AddScreen(),
),
);
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.blue,
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(
horizontal: 22,
vertical: 13,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
icon: const Icon(Icons.add),
label: const Text(
'Create Post',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
],
),
),
);
}

// Posts
return RefreshIndicator(
color: Colors.blue,
onRefresh: () async {
// StreamBuilder already updates automatically.
await Future.delayed(
const Duration(milliseconds: 500),
);
},

child: ListView.builder(
padding: const EdgeInsets.fromLTRB(
16,
16,
16,
100,
),
itemCount: postList.length,

itemBuilder: (context, index) {
final doc = postList[index];
final data = doc.data() as Map<String, dynamic>;

final String content =
data['content']?.toString() ?? '';

final String postUserId =
data['userId']?.toString() ?? '';

final List<String> likes =
List<String>.from(data['likes'] ?? []);

final Timestamp? createdAt =
data['createdAt'] as Timestamp?;

final bool isLiked =
userId != null && likes.contains(userId);

final bool isMyPost =
userId != null && postUserId == userId;

return _PostCard(
content: content,
likes: likes,
isLiked: isLiked,
isMyPost: isMyPost,
time: formatDate(createdAt),

onLike: userId == null
? null
    : () {
likeSwitch(
doc.id,
userId,
likes,
);
},

onDelete: isMyPost
? () {
confirmDelete(
context,
doc.id,
);
}
    : null,
);
},
),
);
},
),

floatingActionButton: FloatingActionButton.extended(
backgroundColor: Colors.blue,
foregroundColor: Colors.white,

elevation: 4,

onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const AddScreen(),
),
);
},

icon: const Icon(
Icons.add,
),

label: const Text(
'Post',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
);
}
}

class _PostCard extends StatelessWidget {
final String content;
final List<String> likes;
final bool isLiked;
final bool isMyPost;
final String time;
final VoidCallback? onLike;
final VoidCallback? onDelete;

const _PostCard({
required this.content,
required this.likes,
required this.isLiked,
required this.isMyPost,
required this.time,
required this.onLike,
required this.onDelete,
});

@override
Widget build(BuildContext context) {
return Card(
margin: const EdgeInsets.only(
bottom: 16,
),

elevation: 1,

color: Colors.white,

shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),

child: Padding(
padding: const EdgeInsets.all(18),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,

children: [
// Header
Row(
children: [
Container(
width: 45,
height: 45,

decoration: BoxDecoration(
color: Colors.blue.shade100,
shape: BoxShape.circle,
),

child: const Icon(
Icons.person,
color: Colors.blue,
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [
Text(
isMyPost
? 'You'
    : 'User',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 3),

Text(
time,
style: TextStyle(
fontSize: 12,
color: Colors.grey.shade600,
),
),
],
),
),

if (isMyPost)
PopupMenuButton<String>(
onSelected: (value) {
if (value == 'delete') {
onDelete?.call();
}
},
itemBuilder: (context) => [
const PopupMenuItem(
value: 'delete',
child: Row(
children: [
Icon(
Icons.delete_outline,
color: Colors.red,
),
SizedBox(width: 10),
Text('Delete'),
],
),
),
],
),
],
),

const SizedBox(height: 18),

// Post content
Text(
content,
style: const TextStyle(
fontSize: 16,
height: 1.5,
),
),

const SizedBox(height: 18),

const Divider(
height: 1,
),

const SizedBox(height: 8),

// Actions
Row(
children: [
IconButton(
onPressed: onLike,
icon: Icon(
isLiked
? Icons.favorite
    : Icons.favorite_border,
color: isLiked
? Colors.red
    : Colors.grey.shade700,
),
),

Text(
'${likes.length}',
style: const TextStyle(
fontWeight: FontWeight.w600,
),
),

const SizedBox(width: 5),

Text(
likes.length == 1
? 'Like'
    : 'Likes',
style: TextStyle(
color: Colors.grey.shade600,
),
),
],
),
],
),
),
);
}
}
