import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:today/config.dart';

class AddPost extends StatefulWidget {
  final String token;

  const AddPost({required this.token, Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  late String userId;
  TextEditingController _postTitle = TextEditingController();
  TextEditingController _postContent = TextEditingController();
  List? items;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    getPostList(userId);
  }

  void PostToCommunity() async {
    if (_postTitle.text.isNotEmpty && _postContent.text.isNotEmpty) {
      var signupBody = {
        "userId": userId,
        "title": _postTitle.text,
        "desc": _postContent.text
      };

      var response = await http.post(
        Uri.parse(addPost),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signupBody),
      );

      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse['status']);

      if (jsonResponse['status']) {
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
    var response = await http.post(
      Uri.parse(postList),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(signupBody),
    );

    var jsonResponse = jsonDecode(response.body);
    items = jsonResponse['success'];

    setState(() {});
  }

  void deleteItem(id) async {
    var signupBody = {
      "id": id,
    };

    var response = await http.post(
      Uri.parse(deletePost),
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
        // Removed border radius
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
          // Header with title
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
                // Optional: Add a refresh button
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
              child: items == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: items!.length,
                      itemBuilder: (context, int index) {
                        return Slidable(
                          key: ValueKey(items![index]['_id']),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            dismissible: DismissiblePane(onDismissed: () {}),
                            children: [
                              SlidableAction(
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                                onPressed: (BuildContext context) {
                                  deleteItem('${items![index]['_id']}');
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
                                '${items![index]['title']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${items![index]['desc']}'),
                              trailing: const Icon(Icons.arrow_back,
                                  color: Color(0xFF450000)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Positioned the FloatingActionButton to the left
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: () => _displayTextInputDialog(context),
                backgroundColor: const Color(0xFF450000),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                tooltip: 'Add Post',
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
          title: Text('Add a post'),
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
              SizedBox(height: 10.0),
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
              onPressed: () {
                PostToCommunity();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF450000),
              ),
              child: const Text(
                "Add",
                style: TextStyle(
                  color: Colors.white, // Set the text color to white
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
