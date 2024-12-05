import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Generate customized material color
// Ref: https://points.tistory.com/65
// Ref: https://api.flutter.dev/flutter/material/Colors-class.html
//

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

// Generate YYYY-MM-DD string from dart DateTime object
//

String getDate(var dateTimeObj) {
  String target = "";
  target = dateTimeObj.year.toString();
  target += "-";
  if (dateTimeObj.month >= 10) {
    target += dateTimeObj.month.toString();
  } else {
    target += "0";
    target += dateTimeObj.month.toString();
  }
  target += "-";
  if (dateTimeObj.day < 10) {
    target += "0";
    target += dateTimeObj.day.toString();
  } else {
    target += dateTimeObj.day.toString();
  }
  return target;
}

// Generate Text widget with black color and bold type
//

Widget getTextWidgetBlackBoldLeft(String msg, double size) {
  if (kIsWeb) {
    // platform is  web
    if (size != 0.0) {
      return Text(
        msg,
        style: TextStyle(
            fontFamily: 'NanumSquareR',
            color: Colors.black,
            fontSize: size,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.0),
        textAlign: TextAlign.left,
      );
    } else {
      return Text(
        msg,
        style: const TextStyle(
            fontFamily: 'NanumSquareR',
            color: Colors.black,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.0),
        textAlign: TextAlign.left,
      );
    }
  } else {
    // platform is not web
    if (size != 0.0) {
      return Text(
        msg,
        style: TextStyle(
            fontFamily: 'NanumSquareB',
            color: Colors.black,
            fontSize: size,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.0),
        textAlign: TextAlign.left,
      );
    } else {
      return Text(
        msg,
        style: const TextStyle(
            fontFamily: 'NanumSquareB',
            color: Colors.black,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.0),
        textAlign: TextAlign.left,
      );
    }
  }
}

// Generate Star icon using staue (ON/OFF) info
//
Widget getStarIcon(String status) {
  if (status == "ON") {
    return const Icon(
      Icons.star,
      size: 26.0,
    );
  } else {
    return const Icon(
      Icons.star_border,
      size: 26.0,
    );
  }
}

// 서버 다운로드 상태 표시 줄 메시지 (정상 상태)
//
String getCustomTextGetResult(var curTime, Map<dynamic, dynamic> rxJson) {
  String msg = '';

  // Date
  if (getDate(curTime) == getDate(DateTime.now())) {
    msg = "오늘 ";
  } else {
    msg =
        '${int.parse(rxJson["GENERATED_TIME"].substring(5, 7))}월 ${int.parse(rxJson["GENERATED_TIME"].substring(8, 10))}일 ';
  }

  // Time
  if (int.parse(rxJson["GENERATED_TIME"].substring(11, 13)) <= 12) {
    msg += int.parse(rxJson["GENERATED_TIME"].substring(11, 13)).toString();
  } else {
    msg += "오후 ";
    msg +=
        (int.parse(rxJson["GENERATED_TIME"].substring(11, 13)) - 12).toString();
  }
  msg += '시 ';

  // Minute
  if (int.parse(rxJson["GENERATED_TIME"].substring(14, 16)) == 0) {
    msg += ' 기준 ';
  } else {
    msg += int.parse(rxJson["GENERATED_TIME"].substring(14, 16)).toString();
    msg += '분 기준 ';
  }

  // State
  if (rxJson["STACK_NUMBER"] == "0") {
    msg += "게시물이 없습니다";
  } else {
    msg += rxJson["STACK_NUMBER"] + "개 게시물";
  }

  return msg;
}

String getCustomTextTodayMsgNumber(String tmp) {
  String msg = '오늘 $tmp개의 게시물이 있습니다';
  return msg;
}

//


