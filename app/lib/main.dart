import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marquee_flutter/marquee_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marquee Text',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Marquee Text App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          onPressed: () => {},
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
      text: !_useRtlText
          ? "There once was a boy who told this story about a boy: "
          : "هذا هو النص مع ترجمة عائمة ، وهناك محاولة لنشر الكلمات !",
      style: TextStyle(fontWeight: FontWeight.bold),
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      blankSpace: 15,
      velocity: 35,
      pauseAfterRoundFinish: Duration(milliseconds: 800),
      showFadingEdgeOnlyWhenScrolling: true,
      fadingEdgeStartFraction: 0.2,
      fadingEdgeEndFraction: 0.2,
      roundCounts: 5,
      paddingAfterText: 20,
      acceleratingDuration: Duration(milliseconds: 500),
      acceleratingCurve: Curves.linear,
      deceleratingDuration: Duration(milliseconds: 500),
      deceleratingCurve: Curves.easeOut,
      textScaleFactor: 0.15,
      textDirection: !_useRtlText ? TextDirection.ltr : TextDirection.rtl,
      startAfter: Duration(milliseconds: 300),
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
