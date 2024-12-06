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
  final TextEditingController _postTitle = TextEditingController();
  final TextEditingController _postContent = TextEditingController();
  List<dynamic> items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    fetchPosts();
  }

  void createPost() async {
    if (_postTitle.text.isEmpty || _postContent.text.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    try {
      var response = await http.post(
        Uri.parse(addPost),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "title": _postTitle.text,
          "desc": _postContent.text
        }),
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        _postTitle.clear();
        _postContent.clear();
        fetchPosts();
        Navigator.pop(context);
        _showSnackBar('Post created successfully');
      } else {
        _showSnackBar(jsonResponse['message'] ?? 'Failed to create post');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void fetchPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await http.post(
        Uri.parse(postList),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        setState(() {
          items = jsonResponse['posts'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar(jsonResponse['message'] ?? 'Failed to fetch posts');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error: $e');
    }
  }

  void deletePost(String postId) async {
    try {
      // Additional debug logging
      debugPrint('Attempting to delete post with ID: $postId');
      debugPrint('Using endpoint: $deletePost');
      debugPrint('User ID: $userId');

      var response = await http.post(
        Uri.parse(deletePosts),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": postId,
          "userId": userId // Include userId for additional verification
        }),
      );

      // More detailed logging
      debugPrint('Delete response status code: ${response.statusCode}');
      debugPrint('Delete response body: ${response.body}');

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        // Successful deletion
        fetchPosts(); // Refresh the list
        _showSnackBar('Post deleted successfully');
      } else {
        // Server returned false status
        _showSnackBar(jsonResponse['message'] ?? 'Failed to delete post');
      }
    } catch (e) {
      // Catch and log any network or parsing errors
      debugPrint('Error deleting post: $e');
      _showSnackBar('Error deleting post: $e');
    }
  }

  // Centralized method for showing SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
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
                  onPressed: fetchPosts,
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
              onPressed: createPost,
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
