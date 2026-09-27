import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
const AddScreen({super.key});

@override
State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
final TextEditingController postController = TextEditingController();

bool isLoading = false;

@override
void dispose() {
postController.dispose();
super.dispose();
}

Future<void> sendPost() async {
final post = postController.text.trim();

if (post.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please write something first.'),
backgroundColor: Colors.red,
),
);
return;
}

final user = FirebaseAuth.instance.currentUser;

if (user == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('You must be logged in first.'),
backgroundColor: Colors.red,
),
);
return;
}

setState(() {
isLoading = true;
});

try {
await FirebaseFirestore.instance.collection('posts').add({
'content': post,
'userId': user.uid,
'likes': [],
'createdAt': FieldValue.serverTimestamp(),
});

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Post added successfully!'),
backgroundColor: Colors.green,
),
);

// الرجوع للـ HomeScreen بعد إضافة البوست
Navigator.pop(context);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Failed to add post: $e'),
backgroundColor: Colors.red,
),
);
} finally {
if (mounted) {
setState(() {
isLoading = false;
});
}
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.grey.shade100,

appBar: AppBar(
backgroundColor: Colors.blue,
foregroundColor: Colors.white,
centerTitle: true,
elevation: 0,
title: const Text(
'Create Post',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),

body: SafeArea(
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Create a new post',
style: TextStyle(
fontSize: 25,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(
'Share your thoughts with everyone.',
style: TextStyle(
fontSize: 15,
color: Colors.grey.shade600,
),
),

const SizedBox(height: 20),

Expanded(
child: Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: Colors.grey.shade300,
),
),
child: TextField(
controller: postController,
maxLines: null,
expands: true,
textAlignVertical: TextAlignVertical.top,
decoration: InputDecoration(
hintText: 'What would you like to share?',
hintStyle: TextStyle(
color: Colors.grey.shade400,
),
border: InputBorder.none,
),
),
),
),

const SizedBox(height: 20),

SizedBox(
width: double.infinity,
height: 56,
child: ElevatedButton.icon(
onPressed: isLoading ? null : sendPost,

style: ElevatedButton.styleFrom(
backgroundColor: Colors.blue,
foregroundColor: Colors.white,
disabledBackgroundColor: Colors.blue.shade200,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),

icon: isLoading
? const SizedBox(
width: 22,
height: 22,
child: CircularProgressIndicator(
color: Colors.white,
strokeWidth: 2.5,
),
)
    : const Icon(Icons.send_rounded),

label: Text(
isLoading ? 'Sending...' : 'Send Post',
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
),
),

const SizedBox(height: 8),
],
),
),
),
);
}
}
