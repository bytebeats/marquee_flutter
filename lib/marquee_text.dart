library marquee;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {

  MarqueeText({Key? key,
    required this.text,
    this.style,
    this.textScaleFactor,
    this.textDirection = TextDirection.ltr,
    this.scrollAxis = Axis.horizontal,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.blankSpace = 0.0,
    this.velocity = 50.0,
    this.startAfter = Duration.zero,
    this.pauseAfterRoundFinish = Duration.zero,
    this.showFadingEdgeOnlyWhenScrolling = true,
    this.fadingEdgeStartFraction = 0.0,
    this.fadingEdgeEndFraction = 0.0,
    this.roundCounts,
    this.paddingAfterText = 0,
    this.acceleratingDuration = Duration.zero,
    Curve acceleratingCurve = Curves.decelerate,
    this.deceleratingDuration = Duration.zero,
    Curve deceleratingCurve = Curves.decelerate,
    this.onDone
  })
      : assert(!blankSpace.isNaN),
        assert(blankSpace >= 0, "The blankSpace needs to be positive or zero."),
        assert(blankSpace.isFinite),
        assert(!velocity.isNaN),
        assert(velocity != 0, "The velocity can not be zero."),
        assert(velocity.isFinite),
        assert(pauseAfterRoundFinish >= Duration.zero,
        "The pauseAfterRoundFinish can not be negative as time travel is not invented yet."),
        assert(fadingEdgeStartFraction >= 0 && fadingEdgeStartFraction < 1,
        "The fadingEdgeStartFraction value should be [0, 1)"),
        assert(fadingEdgeEndFraction >= 0 && fadingEdgeEndFraction < 1,
        "The fadingEdgeEndFraction value should be [0, 1)"),
        assert(roundCounts == null || roundCounts > 0),
        assert(acceleratingDuration >= Duration.zero,
        "The acceleratingDuration can not be negative as time travel is not invented yet."),
        assert(deceleratingDuration >= Duration.zero,
        "The deceleratingDuration can not be negative as time travel is not invented yet."),
        this.acceleratingCurve = _IntegralCurve(acceleratingCurve),
        this.deceleratingCurve = _IntegralCurve(deceleratingCurve),
        super(key: key)

  final String text;
  final TextStyle? style;
  final double? textScaleFactor;
  final TextDirection textDirection;
  final Axis scrollAxis;
  final CrossAxisAlignment crossAxisAlignment;
  final double blankSpace;
  final double velocity;
  final Duration startAfter;
  final Duration pauseAfterRoundFinish;
  final int? roundCounts;
  final bool showFadingEdgeOnlyWhenScrolling;
  final double fadingEdgeStartFraction;
  final double fadingEdgeEndFraction;
  final double paddingAfterText;
  final Duration acceleratingDuration;
  final _IntegralCurve acceleratingCurve;
  final Duration deceleratingDuration;
  final _IntegralCurve deceleratingCurve;
  final VoidCallback? onDone;

  @override
  State<StatefulWidget> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

class _IntegralCurve extends Curve {
  static double delta = 0.01;

  _IntegralCurve._(this.original, this.integral, this._values);

  final Curve original;
  final double integral;
  final Map<double, double> _values;

  double transform(double t) {
    if (t < 0) return 0.0;
    for (final key in _values.keys) {
      if (key > t) return _values[key];
    }
    return 1.0;
  }

  factory _IntegralCurve(Curve original) {
    double integral = 0.0;
    final values = Map<double, double>();
    for (double t = 0.0; t <= 1.0; t += delta) {
      integral += original.transform(t);
      values[t] = integral;
    }
    values[1.0] = integral;
    for (final double t in values.keys)
      values[t] = values[t] / integral;
    return _IntegralCurve._(original, integral, values);
  }
}
