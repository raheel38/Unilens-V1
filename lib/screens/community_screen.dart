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
  State<AddComPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddComPost> {
  late String userId;
  final TextEditingController _postTitle = TextEditingController();
  final TextEditingController _postContent = TextEditingController();
  List? items;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    getPostList(userId);
  }

  void postToCommunity() async {
    if (_postTitle.text.isNotEmpty && _postContent.text.isNotEmpty) {
      var requestBody = {
        "userId": userId,
        "title": _postTitle.text,
        "desc": _postContent.text
      };

      try {
        var response = await http.post(
          Uri.parse(addComPost),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        );

        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status']) {
          _postTitle.clear();
          _postContent.clear();
          getPostList(userId);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add post')),
          );
        }
      } catch (e) {
        print('Error adding post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while adding the post')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and description cannot be empty')),
      );
    }
  }

  void getPostList(String userId) async {
    try {
      var requestBody = {
        "userId": userId,
      };

      var response = await http.post(
        Uri.parse(comPostList),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      var jsonResponse = jsonDecode(response.body);
      setState(() {
        items = jsonResponse['success'];
      });
    } catch (e) {
      print('Error fetching post list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load posts')),
      );
    }
  }

  void deleteItem(String id) async {
    try {
      var requestBody = {
        "id": id,
      };

      var response = await http.post(
        Uri.parse(deleteComPosts),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print('Delete Response Status Code: ${response.statusCode}');
      print('Delete Response Body: ${response.body}');

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse != null && jsonResponse['status'] == true) {
        getPostList(userId);
      } else {
        print('Delete failed: ${jsonResponse}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post')),
        );
      }
    } catch (e) {
      print('Error deleting item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while deleting the post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Posts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF450000),
                  ),
                ),
              ],
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () => _displayTextInputDialog(context),
              backgroundColor: const Color(0xFF450000),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              tooltip: 'Add a post',
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
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
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
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: postToCommunity,
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
