// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:today/config.dart';

// class PostDetailScreen extends StatefulWidget {
//   final String postId;
//   final String title;
//   final String description;
//   final int likes;
//   final List comments;

//   const PostDetailScreen({
//     required this.postId,
//     required this.title,
//     required this.description,
//     required this.likes,
//     required this.comments,
//     Key? key,
//   }) : super(key: key);

//   @override
//   _PostDetailScreenState createState() => _PostDetailScreenState();
// }

// class _PostDetailScreenState extends State<PostDetailScreen> {
//   TextEditingController _commentController = TextEditingController();
//   late int _likes;
//   late List _comments;

//   @override
//   void initState() {
//     super.initState();
//     _likes = widget.likes;
//     _comments = widget.comments;
//   }

//   void _addComment() async {
//     if (_commentController.text.isNotEmpty) {
//       setState(() {
//         _comments.add(_commentController.text);
//         _commentController.clear();
//       });

//       var response = await http.post(
//         Uri.parse(addCommentUrl), // Replace with your actual URL
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "postId": widget.postId,
//           "comment": _commentController.text,
//         }),
//       );

//       var jsonResponse = jsonDecode(response.body);
//       if (jsonResponse['status']) {
//         // Handle success
//       } else {
//         // Handle error
//       }
//     }
//   }

//   void _likePost() async {
//     var response = await http.post(
//       Uri.parse(likePostUrl), // Replace with your like post URL
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"postId": widget.postId}),
//     );

//     var jsonResponse = jsonDecode(response.body);
//     if (jsonResponse['status']) {
//       setState(() {
//         _likes += 1;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Post Details'),
//         backgroundColor: const Color(0xFF450000),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Post Title
//             Text(
//               widget.title,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF450000),
//               ),
//             ),
//             const SizedBox(height: 8),
//             // Post Description
//             Text(
//               widget.description,
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 16),
//             // Like Button
//             Row(
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     Icons.thumb_up,
//                     color: _likes > 0 ? Colors.blue : Colors.grey,
//                   ),
//                   onPressed: _likePost,
//                 ),
//                 Text('$_likes likes'),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // Comments Section
//             const Text('Comments',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _comments.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_comments[index]),
//                   );
//                 },
//               ),
//             ),
//             // Comment input
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _commentController,
//                       decoration: const InputDecoration(
//                         hintText: 'Add a comment...',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: _addComment,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
