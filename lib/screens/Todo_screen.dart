import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:today/config.dart';

class AddPost extends StatefulWidget {
  final String token;
  final VoidCallback onClose; // Add onClose callback

  const AddPost(
      {required this.token,
      required this.onClose, // Make onClose required
      Key? key})
      : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  late String userId;
  TextEditingController _postTitle = TextEditingController();
  TextEditingController _postContent = TextEditingController();
  //list of items
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

  void deleteItem(id) async {
    var signupBody = {
      "id": id,
    };

    // Making a POST request to the backend
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
          // Close button at the top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Posts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // List of posts
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: items == null
                  ? Center(child: CircularProgressIndicator())
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
                            child: ListTile(
                              title: Text('${items![index]['title']}'),
                              subtitle: Text('${items![index]['desc']}'),
                              trailing: Icon(Icons.arrow_back),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Floating Action Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () => _displayTextInputDialog(context),
              backgroundColor: const Color(0xFF450000),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              tooltip: 'Add-ToDo',
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
            ElevatedButton(
              onPressed: () {
                PostToCommunity();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
