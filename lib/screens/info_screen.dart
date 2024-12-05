import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:word_break_text/word_break_text.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'dart:math';

import '../utils.dart';
import '../globals.dart' as globals;

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);
  @override
  State<InfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<InfoScreen> {
  // Status indicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _refreshIndicatorFlag = false;

  // States
  Map<dynamic, dynamic> _dna = {}; // DNA
  String _stateBar = globals.getCustomTextUsage; // Stacks retrieval status
  List<dynamic> _stacks = []; // Stacks from server
  var _currentTime = DateTime.now(); // Date for current stack
  bool _notificationShowFlag = true; // Alarm notification once in a day

  // ListView scroll controller
  final _scrollController = ScrollController(); // Control ListView position

  // Fault tolerance and server load balancing
  var _serverIndex = 0; // preferred server index
  var _serverBlackList = []; // prohibited server list
  final _serverTimeout = 3; // server access tim out seconds

  @override
  void initState() {
    super.initState();
    _dnaFetchStorage(); // loads dna file and randomly selects _serverIndex
  }

  // build function : main

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      //backgroundColor: createMaterialColor(const Color(0xFFFFFFFF)),
      // backgroundColor: createMaterialColor(const Color(0xFFF5F5F5)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        centerTitle: true, // this is all you need
        leading: _buildAppBarMenu(),
        title: _buildAppBarTitle(),
        actions: <Widget>[
          _buildAppBarWrite(),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          _dateChanger(details);
        },
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: Colors.white,
          backgroundColor: Colors.transparent,
          strokeWidth: 4.0,
          onRefresh: () async {
            // Activated only at { today + dragged }
            if (getDate(_currentTime) == getDate(DateTime.now())) {
              if (_refreshIndicatorFlag == true) {
                // if activated via flating button and date changer,
                // do nothing.
                _refreshIndicatorFlag = false;
              } else {
                // if activated via drag to down,
                // contact server.
                _reloadContent("today");
              }
            }
          },
          // Pull from top to show refresh indicator.
          child: Column(
            children: <Widget>[
              Expanded(
                child: _buildBodyStackListView(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // build function : subs

  Widget _buildAppBarMenu() {
    return GestureDetector(
      onTap: () {
        final action = CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SingleChildScrollView(
                            child: _getAboutNoticeWidget()),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context), // passing false
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                globals.getCustomTextBack,
                                style: TextStyle(
                                    fontFamily: 'NanumSquareB',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 0.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).then((exit) {
                  if (exit == null) {
                    return;
                  } else {
                    // do nothing
                  }
                });
              },
              child: const Text(
                globals.getCustomTextNoticeTitle,
                style: TextStyle(
                    fontFamily: 'NanumSquareB',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.0),
                textAlign: TextAlign.left,
              ),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SingleChildScrollView(
                            child: _getAboutDeveloperWidget()),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context), // passing false
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                globals.getCustomTextBack,
                                style: TextStyle(
                                    fontFamily: 'NanumSquareB',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 0.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).then((exit) {
                  if (exit == null) {
                    return;
                  } else {
                    // do nothing
                  }
                });
              },
              child: const Text(
                globals.getCustomTextDevelopberTitle,
                style: TextStyle(
                    fontFamily: 'NanumSquareB',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.0),
                textAlign: TextAlign.left,
              ),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SingleChildScrollView(
                            child: _getAboutVersionWidget()),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context), // passing false
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                globals.getCustomTextBack,
                                style: TextStyle(
                                    fontFamily: 'NanumSquareB',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 0.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).then((exit) {
                  if (exit == null) {
                    return;
                  } else {
                    // do nothing
                  }
                });
              },
              child: const Text(
                globals.getCustomTextVersionTitle,
                style: TextStyle(
                    fontFamily: 'NanumSquareB',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.0),
                textAlign: TextAlign.left,
              ),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SingleChildScrollView(
                            child: _getAboutLicenseWidget()),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context), // passing false
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                globals.getCustomTextBack,
                                style: TextStyle(
                                    fontFamily: 'NanumSquareB',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 0.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).then((exit) {
                  if (exit == null) {
                    return;
                  } else {
                    // do nothing
                  }
                });
              },
              child: const Text(
                globals.getCustomTextLicenseTitle,
                style: TextStyle(
                    fontFamily: 'NanumSquareB',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.0),
                textAlign: TextAlign.left,
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text(
              globals.getCustomTextCancel,
              style: TextStyle(
                  fontFamily: 'NanumSquareB',
                  color: Colors.black,
                  letterSpacing: 0.0),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
        showCupertinoModalPopup(context: context, builder: (context) => action);
      },
      child: const Icon(
        Icons.menu, // add custom icons also
      ),
    );
  }

  Widget _buildAppBarTitle() {
    String stateAppBarTitle = globals.getCustomTextAppBarTitle;

    return TextButton(
        onPressed: () {
          _scrollToIndex(-1.0);
        },
        child: Text(
          stateAppBarTitle,
          style: const TextStyle(
              fontFamily: 'NanumSquareB',
              color: Colors.black,
              fontSize: 18,
              letterSpacing: 0.0),
          textAlign: TextAlign.center,
        ));
  }

  Widget _buildAppBarWrite() {
    // phase.1 notification
    // phase.2 write
    return Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: GestureDetector(
          onTap: () {
            try {
              _dnaShowNotice();
            } catch (_) {
              _showDialogBox(globals.getCustomTextNothingMessage);
            }
          },
          child: _getNotificationIcon(),
          /*
          const Icon(
            Icons.notification_important_outlined,
            size: 26.0,
          ),
          */
        ));
  }

  Widget _buildBodyStackListView() {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _stacks.length + 1, // +1 for header line
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onHorizontalDragEnd: (details) {
            _dateChanger(details);
          },
          child: _bodyStackFactory(context, index),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        color: Colors.transparent,
        height: 1.0,
      ),
    );
  }

  // Define the function that scroll to an item
  void _scrollToIndex(index) {
    if (index == -1) {
      // move to top or bottom alternatively
      if (_scrollController.offset == 0.0) {
        final position = _scrollController.position.maxScrollExtent;
        _scrollController.animateTo(position,
            duration: const Duration(seconds: 1), curve: Curves.decelerate);
      } else {
        _scrollController.animateTo(0.0,
            duration: const Duration(seconds: 1), curve: Curves.decelerate);
      }
    } else if (index == 0.0) {
      // move to top, used when page is changed,
      // BUT due to performance issue, currently block this
      _scrollController.animateTo(index,
          duration: const Duration(seconds: 1), curve: Curves.ease);
      _scrollController.jumpTo(0.0);
    } else {
      _scrollController.animateTo(index,
          duration: const Duration(seconds: 1), curve: Curves.ease);
    }
  }

  Widget _bodyStackFactory(BuildContext context, int index) {
    if (index == _stacks.length) {
      return _buildBodyTrailerLine();
    } else {
      return _buildBodyStack(context, index);
    }
  }

  Widget _buildBodyTrailerLine() {
    if (getDate(_currentTime) == getDate(DateTime.now())) {
      if (_stateBar == globals.getCustomTextUsage) {
        return _buildBodyTrailerLineTypeSimple();
      } else {
        return _buildBodyTrailerLineTypeSimple();
      }
    } else {
      return _buildBodyTrailerLineTypeSimple();
    }
  }

  Widget _buildBodyTrailerLineTypeSimple() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 10),
        Text(
          _stateBar,
          style: const TextStyle(
              fontFamily: 'NanumSquareR',
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.normal,
              letterSpacing: -0.7),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildBodyStack(BuildContext context, int index) {
    var rng = Random();
    var emoji = [
      '\u{1F98A}',
      '\u{1F981}',
      '\u{1F42F}',
      '\u{1F436}',
      '\u{1F42E}',
      '\u{1F437}',
      '\u{1F42D}',
      '\u{1F439}',
      '\u{1F430}',
      '\u{1F43B}',
      '\u{1F989}',
      '\u{1F63A}'
    ];
    var i = rng.nextInt(emoji.length);
    int stackNumber = _stacks.length - index;
    String stackInfo1 = emoji[i] + stackNumber.toString();
    String stackInfo2 = _stacks[index][1].substring(0, 10) +
        ' ' +
        _stacks[index][1].substring(11, 16);

    return Container(
      margin: const EdgeInsets.all(8.0), // external
      padding: const EdgeInsets.all(20.0), // internal
      decoration: BoxDecoration(
        color:
            _dnaGetStackColor(_stacks[index][0], _dna[(_stacks[index][0])][1]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black38.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            _dnaGetDepartmentName(index),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.only(right: 1.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_dna[(_stacks[index][0])][1] == "ON") {
                        _dnaSetDepartmentPreference(index, "OFF");
                      } else {
                        _dnaSetDepartmentPreference(index, "ON");
                      }
                      _dnaWriteStorage();
                    });
                  },
                  child: getStarIcon(_dna[(_stacks[index][0])][1]),
                )),
          ]),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    if (_stacks[index][3] != "") {
                      final Uri url = Uri.parse(_stacks[index][3]);
                      launchUrl(url);
                    } else {
                      _showDialogBox(globals.getCustomTextNoUri);
                    }
                  },
                  child: WordBreakText(
                    _stacks[index][2],
                    style: const TextStyle(
                      fontFamily: 'NanumSquareB',
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 10),
          Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // use whichever suits your need
              children: <Widget>[
                Text(
                  stackInfo1,
                  style: const TextStyle(
                      fontFamily: 'NanumSquareR',
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.0),
                ),
                Text(
                  stackInfo2,
                  style: const TextStyle(
                      fontFamily: 'NanumSquareR',
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.0),
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 1.0),
                    child: GestureDetector(
                      onTap: () {
                        if (_stacks[index][3] != "") {
                          final Uri url = Uri.parse(_stacks[index][3]);
                          launchUrl(url);
                        } else {
                          _showDialogBox(globals.getCustomTextNoUri);
                        }
                      },
                      child: const Icon(
                        Icons.arrow_circle_right_outlined,
                        size: 26.0,
                      ),
                    )),
              ]),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (kIsWeb) {
      // if platform is web*****************************
      return Stack(
        children: <Widget>[
          Align(
            // left
            alignment: const Alignment(-0.4, 0.93),
            child: FloatingActionButton(
              onPressed: () {
                _dateChanger_for_web(-1);
              },
              tooltip: "Previous",
              backgroundColor: Colors.white.withOpacity(0.7),
              child: const Icon(
                Icons.keyboard_double_arrow_left,
                size: 26.0,
              ),
            ),
          ),
          Align(
            // home
            alignment: const Alignment(0.0, 0.93),
            child: FloatingActionButton(
              onPressed: () {
                _refreshIndicatorFlag = true;
                _currentTime = DateTime.now();
                _reloadContent("today");
              },
              tooltip: "Today",
              backgroundColor: Colors.white.withOpacity(0.8),
              child: const Icon(
                Icons.home_rounded,
                size: 30.0,
              ),
            ),
          ),
          Align(
            // right
            alignment: const Alignment(0.4, 0.93),
            child: FloatingActionButton(
              onPressed: () {
                _dateChanger_for_web(1);
              },
              tooltip: "Next",
              backgroundColor: Colors.white.withOpacity(0.7),
              child: const Icon(
                Icons.keyboard_double_arrow_right,
                size: 26.0,
              ),
            ),
          ),
        ],
      );
    } else {
      // if platform is not web**************************
      return Stack(
        children: <Widget>[
          Align(
            alignment: const Alignment(0.0, 0.93),
            child: FloatingActionButton(
              onPressed: () {
                _refreshIndicatorFlag = true;
                _currentTime = DateTime.now();
                _reloadContent("today");
              },
              tooltip: "Update",
              backgroundColor: Colors.white.withOpacity(0.8),
              child: const Icon(
                Icons.radio_button_unchecked,
                size: 26.0,
                color: Color(0xFF450000), // Change the color to red
              ),
            ),
          ),
        ],
      );
    }
  }

  // about dialogs

  Widget _getAboutNoticeWidget() {
    List<Widget> wlist = [];
    List<String> tmp = [];
    List<List<dynamic>> content = globals.getCustomTextNotice;

    for (var item in content) {
      wlist.add(getTextWidgetBlackBoldLeft(item[0], item[1]));
    }

    for (var newKey in _dna.keys) {
      if ((newKey == "VERSION_DNA") ||
          (newKey == "VERSION_SERVER_LIST") ||
          (newKey == "LENGTH_DEPARTMENT") ||
          (newKey == "SCHEDULED")) {
        // do nothing
      } else {
        if ((newKey[0] == '0') || (newKey[0] == 'A') || (newKey[0] == 'C')) {
          tmp.add(_dna[newKey][0]);
        } else {
          // do nothing
        }
      }
    }

    tmp.sort();

    for (var item in tmp) {
      item = item.replaceAll('.', ' ');
      wlist.add(getTextWidgetBlackBoldLeft(item, 12));
    }

    return ListBody(
      children: wlist,
    );
  }

  Widget _getAboutDeveloperWidget() {
    List<Widget> wlist = [];
    List<List<dynamic>> content = globals.getCustomTextDevelopber;

    for (var item in content) {
      wlist.add(getTextWidgetBlackBoldLeft(item[0], item[1]));
    }

    return ListBody(
      children: wlist,
    );
  }

  Widget _getAboutVersionWidget() {
    List<Widget> wlist = [];
    List<List<dynamic>> content = globals.getCustomTextVersion;

    for (var item in content) {
      wlist.add(getTextWidgetBlackBoldLeft(item[0], item[1]));
    }

    String dnaVerWithServerIndex =
        _dna['VERSION_DNA'] + '.' + _serverIndex.toString();

    wlist.add(getTextWidgetBlackBoldLeft(dnaVerWithServerIndex, 0));

    return ListBody(
      children: wlist,
    );
  }

  Widget _getAboutLicenseWidget() {
    List<Widget> wlist = [];
    List<List<dynamic>> content = globals.getCustomTextLicense;

    for (var item in content) {
      wlist.add(getTextWidgetBlackBoldLeft(item[0], item[1]));
    }

    return ListBody(
      children: wlist,
    );
  }

  // utility functions

  void _showDialogBox(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Text(
            msg,
            style: const TextStyle(
                fontFamily: 'NanumSquareR',
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.0),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.pop(context), // passing false
              child: const Align(
                alignment: Alignment.center,
                child: Text(
                  globals.getCustomTextBack,
                  style: TextStyle(
                      fontFamily: 'NanumSquareB',
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Server access, fault tolerance and load balancing schemes

  Future<http.Response> _fetchGet(String target) async {
    String uri =
        "${"http://" + _dna["VERSION_SERVER_LIST"][_serverIndex]}/today_api/$target";

    final response = await http
        .get(Uri.parse(uri))
        .timeout(Duration(seconds: _serverTimeout), onTimeout: () {
      if (_serverBlackList.contains(_serverIndex) == false) {
        _serverBlackList.add(_serverIndex);
      }
      return http.Response('408', 408);
    });

    return response;
  }

  void _serverInitialization() {
    if (_dna["VERSION_SERVER_LIST"].length == 1) {
      _serverIndex = 0;
    } else {
      var rng = Random();
      _serverIndex = rng.nextInt(_dna["VERSION_SERVER_LIST"].length);
    }

    _serverBlackList = [];
  }

  void _serverReinitialization() {
    if (_dna["VERSION_SERVER_LIST"].length == _serverBlackList.length) {
      _serverBlackList = [];
    }

    if (_dna["VERSION_SERVER_LIST"].length == 1) {
      _serverIndex = 0;
    } else {
      var rng = Random();
      for (var i = 0;;) {
        i = rng.nextInt(_dna["VERSION_SERVER_LIST"].length);
        if ((i != _serverIndex) || (_serverBlackList.contains(i) == false)) {
          _serverIndex = i;
          break;
        } else {
          // do nothing
        }
      }
    }
  }

  // Core Logic

  void _reloadContent(String targetDate) async {
    // status indicator activation
    _refreshIndicatorKey.currentState?.show();

    if (_dna.isEmpty) {
      setState(() {
        _stateBar = globals.getCustomTextUsage;
        _stacks = [];
      });
      return;
    } else {
      // do nothing
    }

    try {
      _dnaCheckNotice();
    } catch (_) {
      // do nothing
    }

    try {
      var getResponse = await _fetchGet(targetDate);
      Map<dynamic, dynamic> rxJson = {};
      if (getResponse.statusCode == 408) {
        // Error at server
        _serverReinitialization();
        setState(() {
          _stateBar = globals.getCustomTextSearchError;
          _stacks = [];
        });
      } else if (getResponse.body.toString().substring(1, 4) == '404') {
        // File not found at server
        setState(() {
          _stateBar = globals.getCustomTextSearchPast;
          _stacks = [];
        });
      } else if (getResponse.statusCode == 200) {
        String getResponseBody = utf8.decode(getResponse.bodyBytes);
        rxJson = jsonDecode(getResponseBody);

        // dna update if needs
        if (targetDate == 'today') {
          if (_dnaCheckNeedUpdate(rxJson['VERSION_DNA'])) {
            await _dnaProtocol();
          } else {
            // do nothing
          }
        } else {
          // do nothing
        }

        setState(() {
          if (getResponse.statusCode == 200) {
            _stateBar = getCustomTextGetResult(_currentTime, rxJson);
            if (rxJson["STACK_NUMBER"] == "0") {
              _stacks = [];
            } else {
              _stacks = rxJson["STACKS"].reversed.toList();
            }
          } else {
            _stateBar = globals.getCustomTextGetResultError;
            _stacks = [];
          }
        });
      } else {
        // server not response.
        // error!
        _showDialogBox("ERROR@_reloadContent#1");
      }
    } catch (_) {
      // Error at server, find another (fault tolerance & load balancing)
      _serverReinitialization();
      setState(() {
        _stateBar = globals.getCustomTextSearchError;
        _stacks = [];
      });
    }
  }

  void _dateChanger(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx < 0) {
      // move right-to-left (to future)
      final targetDay = _currentTime.add(const Duration(days: 1));
      final now = DateTime.now();

      if (getDate(now) == getDate(targetDay)) {
        // if today
        _refreshIndicatorFlag = true;
        _currentTime = _currentTime.add(const Duration(days: 1));
        _reloadContent("today");
      } else if (now.compareTo(targetDay) == 1) {
        // if still past
        _currentTime = _currentTime.add(const Duration(days: 1));
        _reloadContent(getDate(_currentTime));
      } else {
        _showDialogBox(globals.getCustomTextSearchFuture);
      }
    } else {
      // move left-to-right (to past)
      _currentTime = _currentTime.subtract(const Duration(days: 1));
      _reloadContent(getDate(_currentTime));
    }
  }

  void _dateChanger_for_web(int direction) {
    if (direction > 0) {
      // move right-to-left (to future)
      final targetDay = _currentTime.add(const Duration(days: 1));
      final now = DateTime.now();

      if (getDate(now) == getDate(targetDay)) {
        // if today
        _refreshIndicatorFlag = true;
        _currentTime = _currentTime.add(const Duration(days: 1));
        _reloadContent("today");
      } else if (now.compareTo(targetDay) == 1) {
        // if still past
        _currentTime = _currentTime.add(const Duration(days: 1));
        _reloadContent(getDate(_currentTime));
      } else {
        _showDialogBox(globals.getCustomTextSearchFuture);
      }
    } else {
      // move left-to-right (to past)
      _currentTime = _currentTime.subtract(const Duration(days: 1));
      _reloadContent(getDate(_currentTime));
    }
  }

  // DNA protocols

  Future<String> _getDirPath() async {
    // Find the Documents path
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  _dnaFetchStorage() async {
    if (!kIsWeb) {
      // platform is not web

      // previous dna file check
      final dirPath = await _getDirPath();
      final dnaFile = File('$dirPath/dna_storage.json');
      final existFlag = dnaFile.existsSync();

      if (existFlag == false) {
        // file not exist (first execution after install)
        String filePreference =
            await rootBundle.loadString('configuration/dna.json');
        _dna = await json.decode(filePreference);
        await dnaFile.writeAsString(json.encode(_dna));
      } else {
        // file exist (app executed before)
        String filePreference = await dnaFile.readAsString(encoding: utf8);
        _dna = await json.decode(filePreference);
      }
    } else {
      // platform is web
      String filePreference =
          await rootBundle.loadString('configuration/dna.json');
      _dna = await json.decode(filePreference);
    }

    // for load balancing
    _serverInitialization();
  }

  _dnaWriteStorage() async {
    if (!kIsWeb) {
      // platform is not web

      // step.A check dna file existence
      final dirPath = await _getDirPath();
      final dnaFile = File('$dirPath/dna_storage.json');
      final existFlag = dnaFile.existsSync();

      // step.B create or read dna file as preference information
      if (existFlag == false) {
        // file not exist (first execution after install)
        String filePreference =
            await rootBundle.loadString('configuration/dna.json');
        _dna = await json.decode(filePreference);
        await dnaFile.writeAsString(json.encode(_dna));
      } else {
        // file exist (app executed before)
        await dnaFile.writeAsString(json.encode(_dna));
      }
    } else {
      // platform is web
      // do nothing
    }
  }

  bool _dnaCheckNeedUpdate(String date) {
    return _dna['VERSION_DNA'].toString().compareTo(date) < 0;
  }

  Future<bool> _dnaProtocol() async {
    var getResponse = await _fetchGet("dna");
    var statusCode = getResponse.statusCode;
    Map<dynamic, dynamic> newDna = {};

    if (statusCode == 200) {
      String getResponseBody = utf8.decode(getResponse.bodyBytes);
      newDna = jsonDecode(getResponseBody);
      newDna.forEach((k, v) => _dnaUpdatePreference(k, v));
      _dna = newDna;
      _dnaWriteStorage();
      _serverInitialization();
      return true;
    } else {
      // dna file download fail
      // error!
      _showDialogBox("ERROR@_dnaProtocol()");
      return false;
    }
  }

  void _dnaUpdatePreference(String k, var v) {
    if ((k == "VERSION_DNA") ||
        (k == "VERSION_SERVER_LIST") ||
        (k == "LENGTH_DEPARTMENT") ||
        (k == "SCHEDULED")) {
    } else {
      if (_dna.containsKey(k) == true) {
        v[1] = _dna[k][1];
      } else {
        // New department
        // do nothing
      }
    }
  }

  void _dnaSetDepartmentPreference(int index, String value) {
    if (_dna.containsKey(_stacks[index][0]) == true) {
      _dna[(_stacks[index][0])][1] = value;
    } else {
      // do nothing
    }
  }

  Widget _dnaGetDepartmentName(int index) {
    if (_dna.containsKey(_stacks[index][0]) == true) {
      return Text(
        _dna[(_stacks[index][0])][0].replaceAll('.', ' '),
        style: const TextStyle(
            fontFamily: 'NanumSquareR',
            color: Colors.black,
            letterSpacing: 0.0),
      );
    } else {
      // dna file download fail
      // error!
      //_showDialogBox("ERROR@_dnaGetDepartmentName");

      return const Text(
        "[ANGEL]",
        style: TextStyle(
            fontFamily: 'NanumSquareR',
            color: Colors.black,
            letterSpacing: 0.0),
      );
    }
  }

  Color _dnaGetStackColor(String deptCode, String preferStatus) {
    Map colorTable = {
      '0': Colors.white, // white
      '1': Colors.lightGreenAccent,
      '2': const Color.fromARGB(0xFF, 0x8C, 0x9E, 0xFF), // indigoAccent
      '3': const Color.fromARGB(0xFF, 0xEA, 0x80, 0xFC), // purpleAccent
      '4': const Color.fromARGB(0xFF, 0xB3, 0x88, 0xFF), // deepPurpleAccent
      '5': const Color.fromARGB(0xFF, 0x90, 0xA4, 0xAE), // blueGrey[300]
      '6': const Color.fromARGB(0xFF, 0xBC, 0xAA, 0xA4), // brown[200]
      '7': Colors.lightBlueAccent,
      '8': Colors.cyanAccent,
      '9': Colors.tealAccent,
      'A': Colors.greenAccent,
      'B': const Color.fromARGB(0xFF, 0x82, 0xB1, 0xFF), // blueAccent @BLUELETR
      'C': Colors.limeAccent,
      'D': Colors.yellowAccent,
      'E': Colors.amberAccent,
      'F': Colors.orangeAccent,
      'G': const Color.fromARGB(0xFF, 0xFF, 0x80, 0xAB), // pinkAccent
      'H': const Color.fromARGB(0xFF, 0xFF, 0x8A, 0x80), // redAccent
      'I': const Color.fromARGB(0xFF, 0xFF, 0x9E, 0x80), // deepOrangeAccent
      'J': Colors.orange,
      'K': Colors.amber,
      'L': Colors.yellow,
      'M': Colors.lime,
      'N': Colors.lightGreen,
      'O': Colors.cyan,
      'P': Colors.lightBlue,
      'Q': Colors.grey,
      'R': const Color.fromARGB(0xFF, 0xBC, 0xAA, 0xA4), // brown[200]
      'S': const Color.fromARGB(0xFF, 0x90, 0xA4, 0xAE), // blueGrey[200]
      'T': const Color.fromARGB(0xFF, 0xB3, 0x9D, 0xDB), // deepPurple[200]
      'U': const Color.fromARGB(0xFF, 0xD1, 0xC4, 0xE9), // deepPurple[100]
      'V': const Color.fromARGB(0xFF, 0xED, 0xE7, 0xF6), // deepPurple[50]]
      'W': Colors.red,
      'X': Colors.green,
      'Y': Colors.blue,
      'Z': Colors.black,
    };

    if (preferStatus == "ON") {
      // preferred stack
      return createMaterialColor(const Color.fromARGB(255, 243, 219, 246));
    } else {
      if (!colorTable.containsKey(deptCode[0])) {
        return Colors.white;
      } else {
        return colorTable[deptCode[0]];
      }
    }
  }

  Widget _getNotificationIcon() {
    if (_dna.containsKey('SCHEDULED')) {
      for (var item in _dna['SCHEDULED']) {
        final flag = globals.getCustomTextVersion[2][0]
            .toString()
            .compareTo(item['TARGET'].toString());
        if (flag <= 0) {
          // less than or equal
          var begin = DateTime.parse(item['BEGIN']);
          var end = DateTime.parse(item['END']);
          var now = DateTime.now();
          if (now.compareTo(begin) > 0 && now.compareTo(end) < 0) {
            return const Icon(
              Icons.notifications_on_rounded,
              size: 26.0,
              color: Color.fromARGB(0xFF, 0xEA, 0x80, 0xFC),
            );
          }
        }
      }
    }
    return const Icon(
      Icons.notifications_off_outlined,
      size: 26.0,
    );
  }

  _dnaCheckNotice() {
    if (_notificationShowFlag == true) {
      if (_dna.containsKey('SCHEDULED')) {
        for (var item in _dna['SCHEDULED']) {
          final flag = globals.getCustomTextVersion[2][0]
              .toString()
              .compareTo(item['TARGET'].toString());
          if (flag <= 0) {
            // less than or equal
            if (item["ENABLED"] == 'ON') {
              var begin = DateTime.parse(item['BEGIN']);
              var end = DateTime.parse(item['END']);
              var now = DateTime.now();
              if (now.compareTo(begin) > 0 && now.compareTo(end) < 0) {
                _notificationShowFlag = false;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return object of type Dialog
                    //return CupertinoAlertDialog(
                    return CupertinoAlertDialog(
                      title: Text(
                        item['TITLE'],
                        style: const TextStyle(
                            fontFamily: 'NanumSquareR',
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.0),
                        textAlign: TextAlign.center,
                      ),
                      content: Text(
                        '\n' + item["MESSAGE"],
                        style: const TextStyle(
                            fontFamily: 'NanumSquareR',
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.0),
                        textAlign: TextAlign.center,
                      ),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context); //close Dialog
                              item["ENABLED"] = 'OFF';
                              _dnaWriteStorage();
                            },
                            child: const Text(
                              globals.getCustomTextDisable,
                              style: TextStyle(
                                  fontFamily: 'NanumSquareB',
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 0.0),
                              textAlign: TextAlign.center,
                            )),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); //close Dialog
                          },
                          child: const Text(
                            globals.getCustomTextBack,
                            style: TextStyle(
                                fontFamily: 'NanumSquareB',
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 0.0),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    );
                  },
                );

                return; // one notice per a time
              } else {
                // do nothing
              }
            }
          }
        } // for
      } // if
    }
  }

  _dnaShowNotice() {
    if (_dna.containsKey('SCHEDULED')) {
      for (var item in _dna['SCHEDULED']) {
        final flag = globals.getCustomTextVersion[2][0]
            .toString()
            .compareTo(item['TARGET'].toString());
        if (flag <= 0) {
          // less than or equal
          var begin = DateTime.parse(item['BEGIN']);
          var end = DateTime.parse(item['END']);
          var now = DateTime.now();
          if (now.compareTo(begin) > 0 && now.compareTo(end) < 0) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                //return CupertinoAlertDialog(
                return CupertinoAlertDialog(
                  title: Text(
                    item['TITLE'],
                    style: const TextStyle(
                        fontFamily: 'NanumSquareR',
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.0),
                    textAlign: TextAlign.center,
                  ),
                  content: Text(
                    '\n' + item["MESSAGE"],
                    style: const TextStyle(
                        fontFamily: 'NanumSquareR',
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.0),
                    textAlign: TextAlign.center,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); //close Dialog
                      },
                      child: const Text(
                        globals.getCustomTextBack,
                        style: TextStyle(
                            fontFamily: 'NanumSquareB',
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.0),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                );
              },
            );

            return; // one notice per a time
          } else {
            // do nothing
          }
        }
      } // for
    }

    // no notification
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        //return CupertinoAlertDialog(
        return CupertinoAlertDialog(
          title: const Text(
            globals.getCustomTextNothingTitle,
            style: TextStyle(
                fontFamily: 'NanumSquareR',
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.0),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            '\n${globals.getCustomTextNothingMessage}',
            style: TextStyle(
                fontFamily: 'NanumSquareR',
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.0),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); //close Dialog
              },
              child: const Text(
                globals.getCustomTextBack,
                style: TextStyle(
                    fontFamily: 'NanumSquareB',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.0),
                textAlign: TextAlign.center,
              ),
            )
          ],
        );
      },
    );
  }
}
