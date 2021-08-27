# marquee_flutter

A Flutter widget that scrolls text infinitely. Customizations are supported, namely scroll durations, directions and velocities, delay after each round and curves for accelerating or decelerating.

### How to use

<br>There is the easiest way:
```
    MarqueeText(
      key: Key("MarqueeText"),
      text: "This is a Flutter Marquee Text, have a try and spread the word!",
      velocity: 50,
    );
```
<br>And here below is a piece of code that use more customizations:
```
    MarqueeText(
      key: Key("ComplicatedMarqueeText"),
      text: "There once was a boy who told this story about a boy: ",
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
```