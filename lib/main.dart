import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(
    token: prefs.getString('token'),
  ));
}

class MyApp extends StatelessWidget {
  var token;
  MyApp({
    @required this.token,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: (token != null && !JwtDecoder.isExpired(token!))
          ? Dashboard(token: token!)
          : LoginScreen(),

      // theme: ThemeData(
      //     primarySwatch: createMaterialColor(const Color(0xFFFFFFFF))),
      // home: const MyHomePage(title: globals.getCustomTextMyHomePage),
    );
  }
}
