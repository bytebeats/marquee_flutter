import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marquee_flutter/marquee_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp> {
  bool _useRtlText = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Marquee Text",
      home: Scaffold(
        backgroundColor: Colors.deepPurple,
        body: ListView(
          padding: EdgeInsets.only(top: 50),
          children: [
            _buildMarqueeText(),
            _buildComplicateMarqueeText(),
          ].map((e) => _wrapWithStuff(e)).toList(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => setState(() => _useRtlText = !_useRtlText),
          label: !_useRtlText ? const Text(("Switch to Hebrew")) : const Text("العبرية"),
          backgroundColor: Colors.brown,
        ),
      ),
    );
  }

  Widget _buildMarqueeText() {
    return MarqueeText(
      key: Key("$_useRtlText"),
      text: !_useRtlText
          ? "This is a Flutter Marquee Text, have a try and spread the word!"
          : "هذا هو النص مع ترجمة عائمة ، وهناك محاولة لنشر الكلمات !",
      velocity: 50,
    );
  }

  Widget _buildComplicateMarqueeText() {
    return MarqueeText(
      key: Key("$_useRtlText"),
      text: !_useRtlText
          ? "There once was a boy who told this story about a boy: "
          : "هذا هو النص مع ترجمة عائمة ، وهناك محاولة لنشر الكلمات !",
      style: TextStyle(fontWeight: FontWeight.bold),
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      blankSpace: 20,
      velocity: 100,
      pauseBetweenRounds: Duration(seconds: 1),
      showFadingOnlyWhenScrolling: true,
      fadingStartFraction: 0.1,
      fadingEndFraction: 0.1,
      roundCounts: 30,
      paddingBeforeText: 10,
      acceleratingDuration: Duration(microseconds: 20),
      acceleratingCurve: Curves.linear,
      deceleratingDuration: Duration(milliseconds: 20),
      deceleratingCurve: Curves.easeOut,
      textScaleFactor: 2,
      textDirection: !_useRtlText ? TextDirection.ltr : TextDirection.rtl,
      startAfter: Duration(milliseconds: 100),
      onDone: () => {debugPrint("round done!")},
    );
  }

  Widget _wrapWithStuff(Widget child) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Container(
        height: 40,
        color: Colors.deepOrange,
        child: child,
      ),
    );
  }
}
