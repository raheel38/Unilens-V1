import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:today/config.dart';

class AddComPost extends StatefulWidget {
  final String token;

  const AddComPost({required this.token, Key? key}) : super(key: key);

  @override
  State<AddComPost> createState() => _AddComPostState();
}

class _AddComPostState extends State<AddComPost> {
  late String userId;
  final TextEditingController _postTitle = TextEditingController();
  final TextEditingController _postContent = TextEditingController();

  List<dynamic> items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    getPostList(userId);
  }

//createPost to PostToCommunity
  void PostToCommunity() async {
    if (_postTitle.text.isNotEmpty && _postContent.text.isNotEmpty) {
      // Creating the request body to send to the backend
      var signupBody = {
        "userId": userId,
        "title": _postTitle.text,
        "desc": _postContent.text
      };

      // Making a POST request to the backend
      var response = await http.post(
        Uri.parse(addPost),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signupBody),
      );

      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        // Clear the input fields and close the dialog
        _postTitle.clear();
        _postContent.clear();
        getPostList(userId);
        Navigator.pop(context);
      } else {
        print("Something Went Wrong!");
      }
    } else {
      print("Fields cannot be empty");
    }
  }

  void getPostList(userId) async {
    var signupBody = {
      "userId": userId,
    };
    // Making a POST request to the backend
    var response = await http.post(
      Uri.parse(postList),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(signupBody),
    );

    var jsonResponse = jsonDecode(response.body);
    items = jsonResponse['success'];

    setState(() {});
  }

  void deletePost(id) async {
    var signupBody = {
      "id": id,
    };

    // Making a POST request to the backend
    var response = await http.post(
      Uri.parse(deletePosts),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(signupBody),
    );

    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      getPostList(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Posts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF450000),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF450000)),
                  onPressed: () => getPostList(userId),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const Center(child: Text('No posts yet'))
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, int index) {
                            return Slidable(
                              key: ValueKey(items[index]['_id']),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                dismissible:
                                    DismissiblePane(onDismissed: () {}),
                                children: [
                                  SlidableAction(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                    onPressed: (BuildContext context) {
                                      deletePost(items[index]['_id']);
                                    },
                                  ),
                                ],
                              ),
                              child: Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                child: ListTile(
                                  title: Text(
                                    items[index]['title'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(items[index]['desc']),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          'Likes: ${items[index]['likes'] ?? 0}'),
                                      const Icon(Icons.arrow_back,
                                          color: Color(0xFF450000)),
                                    ],
                                  ),
                                  onTap: () {
                                    // Optional: Navigate to post details
                                    // Navigator.push(...);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: () => _displayTextInputDialog(context),
                backgroundColor: const Color(0xFF450000),
                tooltip: 'Add Post',
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _postTitle,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Title",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _postContent,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Description",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: PostToCommunity,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF450000),
              ),
              child: const Text(
                "Add",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
