import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfileScreen extends StatefulWidget {
  final String token;
  const ProfileScreen({required this.token, Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
      email = decodedToken['email'] ?? 'Email not found';
    } catch (e) {
      email = 'Error decoding token';
      print('Error decoding token: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Icon(
                    Icons.person,
                    size: 100,
                    color: Color(0xFF2C2C54),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C54),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Email : ${email ?? "Not available"}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
