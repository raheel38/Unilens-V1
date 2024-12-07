import 'package:flutter/material.dart';
import 'Todo_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({required this.token, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isTodoVisible = false;

  void _toggleTodoVisibility() {
    setState(() {
      isTodoVisible = !isTodoVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2C2C54),
                  Color(0xFF450000),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'UniLens',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 42.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOpacityText('Stay'),
                        _buildOpacityText('Connected'),
                        _buildOpacityText('Stay'),
                        _buildOpacityText('Informed'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        ElevatedButton(
                          onPressed: _toggleTodoVisibility,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF450000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 8, // Add elevation for the shadow effect
                            shadowColor:
                                const Color(0xFF2C2C54), // Dark Blue shadow
                          ),
                          child: Text(
                            isTodoVisible ? 'Hide ToDo' : 'Show ToDo',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 150, // Adjust width to match the button
                            height: 1, // Thin line
                            color: Colors.white, // Line color
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ToDo List (AddPost widget)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: isTodoVisible ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.7,
            child: AddPost(
              token: widget.token,
              onClose: _toggleTodoVisibility,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create opacity text
  Widget _buildOpacityText(String text) {
    return Opacity(
      opacity: 0.7,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 48,
        ),
      ),
    );
  }
}
