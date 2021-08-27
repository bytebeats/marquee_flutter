library marquee;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  MarqueeText({
    Key? key,
    required this.text,
    this.style,
    this.textScaleFactor,
    this.textDirection = TextDirection.ltr,
    this.scrollAxis = Axis.horizontal,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.blankSpace = 0.0,
    this.velocity = 50.0,
    this.startAfter = Duration.zero,
    this.pauseBetweenRounds = Duration.zero,
    this.showFadingOnlyWhenScrolling = true,
    this.fadingStartFraction = 0.0,
    this.fadingEndFraction = 0.0,
    this.roundCounts,
    this.paddingBeforeText = 0,
    this.acceleratingDuration = Duration.zero,
    Curve acceleratingCurve = Curves.decelerate,
    this.deceleratingDuration = Duration.zero,
    Curve deceleratingCurve = Curves.decelerate,
    this.onDone,
  })  : assert(!blankSpace.isNaN),
        assert(blankSpace >= 0, "The blankSpace needs to be positive or zero."),
        assert(blankSpace.isFinite),
        assert(!velocity.isNaN),
        assert(velocity != 0, "The velocity can not be zero."),
        assert(velocity.isFinite),
        assert(pauseBetweenRounds >= Duration.zero,
            "The pauseAfterRoundFinish can not be negative as time travel is not invented yet."),
        assert(fadingStartFraction >= 0 && fadingStartFraction < 1,
            "The fadingEdgeStartFraction value should be [0, 1)"),
        assert(fadingEndFraction >= 0 && fadingEndFraction < 1,
            "The fadingEdgeEndFraction value should be [0, 1)"),
        assert(roundCounts == null || roundCounts > 0),
        assert(acceleratingDuration >= Duration.zero,
            "The acceleratingDuration can not be negative as time travel is not invented yet."),
        assert(deceleratingDuration >= Duration.zero,
            "The deceleratingDuration can not be negative as time travel is not invented yet."),
        this.acceleratingCurve = _IntegralCurve(acceleratingCurve),
        this.deceleratingCurve = _IntegralCurve(deceleratingCurve),
        super(key: key);
  final String text;
  final TextStyle? style;
  final double? textScaleFactor;
  final TextDirection textDirection;
  final Axis scrollAxis;
  final CrossAxisAlignment crossAxisAlignment;
  final double blankSpace;
  final double velocity;
  final Duration startAfter;
  final Duration pauseBetweenRounds;
  final int? roundCounts;
  final bool showFadingOnlyWhenScrolling;
  final double fadingStartFraction;
  final double fadingEndFraction;
  final double paddingBeforeText;
  final Duration acceleratingDuration;
  final _IntegralCurve acceleratingCurve;
  final Duration deceleratingDuration;
  final _IntegralCurve deceleratingCurve;
  final VoidCallback? onDone;

  @override
  State<StatefulWidget> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  late double _startPosition;
  late double _acceleratingTarget;
  late double _linearTarget;
  late double _deceleratingTarget;
  late Duration _totalDuration;

  Duration get _acceleratingDuration => widget.acceleratingDuration;
  Duration? _linearDuration;

  Duration get _deceleratingDuration => widget.deceleratingDuration;

  bool _isRunning = false;
  bool _isOnPause = false;
  int _roundCounter = 0;

  bool get _isDone => widget.roundCounts == null ? false : widget.roundCounts == _roundCounter;

  bool get _showFading => !widget.showFadingOnlyWhenScrolling ? true : !_isOnPause;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      if (!_isRunning) {
        _isRunning = true;
        _controller.jumpTo(_startPosition);
        await Future<void>.delayed(widget.startAfter);
        Future.doWhile(() => _scroll());
      }
    });
  }

  Future<bool> _scroll() async {
    await _makeRoundTrip();
    if (_isDone && widget.onDone != null) {
      widget.onDone!();
    }
    return _isRunning && !_isDone && _controller.hasClients;
  }

  Future<void> _makeRoundTrip() async {
    if (!_controller.hasClients) return;
    _controller.jumpTo(_startPosition);
    if (!_isRunning) return;
    await _accelerate();
    if (!_isRunning) return;
    await _marqueeLinearly();
    if (!_isRunning) return;
    await _decelerate();
    _roundCounter++;
    if (!_isRunning || !mounted) return;
    if (widget.pauseBetweenRounds > Duration.zero) {
      setState(() {
        _isOnPause = true;
      });
      await Future.delayed(widget.pauseBetweenRounds);
      if (!mounted || _isDone) return;
      setState(() {
        _isOnPause = false;
      });
    }
  }

  Future<void> _accelerate() async {
    await _animateTo(_acceleratingTarget, _acceleratingDuration, widget.acceleratingCurve);
  }

  Future<void> _marqueeLinearly() async {
    await _animateTo(_linearTarget, _linearDuration, Curves.linear);
  }

  Future<void> _decelerate() async {
    await _animateTo(_deceleratingTarget, _deceleratingDuration, widget.deceleratingCurve.flipped);
  }

  Future<void> _animateTo(
    double? target,
    Duration? duration,
    Curve curve,
  ) async {
    if (!_controller.hasClients) return;
    if (duration! > Duration.zero) {
      await _controller.animateTo(target!, duration: duration, curve: curve);
    } else {
      _controller.jumpTo(target!);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialize(context);
    bool isHorizontal = widget.scrollAxis == Axis.horizontal;
    Alignment? alignment;
    switch (widget.crossAxisAlignment) {
      case CrossAxisAlignment.start:
        alignment = isHorizontal ? Alignment.topCenter : Alignment.centerLeft;
        break;
      case CrossAxisAlignment.end:
        alignment = isHorizontal ? Alignment.bottomCenter : Alignment.centerRight;
        break;
      case CrossAxisAlignment.center:
        alignment = Alignment.center;
        break;
      case CrossAxisAlignment.stretch:
      case CrossAxisAlignment.baseline:
        alignment = null;
        break;
    }
    Widget marqueeViews = ListView.builder(
      controller: _controller,
      scrollDirection: widget.scrollAxis,
      reverse: widget.textDirection == TextDirection.rtl,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) {
        final text = i.isEven
            ? Text(
                widget.text,
                style: widget.style,
                textScaleFactor: widget.textScaleFactor,
              )
            : _buildBlankSpace();
        return alignment == null
            ? text
            : Align(
                alignment: alignment,
                child: text,
              );
      },
    );
    return kIsWeb ? marqueeViews : _wrapWithFadingEdgeScrollView(marqueeViews);
  }

  Widget _buildBlankSpace() {
    return SizedBox(
      width: widget.scrollAxis == Axis.horizontal ? widget.blankSpace : null,
      height: widget.scrollAxis == Axis.vertical ? widget.blankSpace : null,
    );
  }

  Widget _wrapWithFadingEdgeScrollView(Widget child) {
    return FadingEdgeScrollView.fromScrollView(
        gradientFractionOnStart: !_showFading ? 0.0 : widget.fadingStartFraction,
        gradientFractionOnEnd: !_showFading ? 0.0 : widget.fadingEndFraction,
        child: child as ScrollView);
  }

  @override
  void dispose() {
    _isRunning = false;
    super.dispose();
  }

  void _initialize(BuildContext context) {
    final totalDistance = _textWidth(context) + widget.blankSpace;
    final acceleratingDistance = widget.acceleratingCurve.integral *
        widget.velocity *
        _acceleratingDuration.inMilliseconds /
        1000.0;
    final deceleratingDistance = widget.deceleratingCurve.integral *
        widget.velocity *
        _deceleratingDuration.inMilliseconds /
        1000.0;
    final linearDistance =
        (totalDistance - acceleratingDistance.abs() - deceleratingDistance.abs()) *
            (widget.velocity > 0 ? 1 : -1);

    _startPosition = 2 * totalDistance - widget.paddingBeforeText;
    _acceleratingTarget = _startPosition + acceleratingDistance;
    _linearTarget = _acceleratingTarget + linearDistance;
    _deceleratingTarget = _linearTarget + deceleratingDistance;

    _totalDuration = _acceleratingDuration +
        _deceleratingDuration +
        Duration(milliseconds: (linearDistance / widget.velocity * 1000.0).toInt());
    _linearDuration = _totalDuration - _acceleratingDuration - _deceleratingDuration;

    assert(_totalDuration > Duration.zero,
        "With the given values, the total duration for one round would be negative. This shouldn't happen unless time travel has been invented.");
    assert(
      _linearDuration! >= Duration.zero,
      "Acceleration and deceleration phase overlap. To fix this, try a combination of these approaches:\n"
      "* Make the text longer, so there's more room to animate within.\n"
      "* Shorten the accelerationDuration or decelerationDuration.\n"
      "* Decrease the velocity, so the duration to animate within is longer.\n",
    );
  }

  double _textWidth(BuildContext context) {
    final span = TextSpan(text: widget.text, style: widget.style);
    final constraints = BoxConstraints(maxWidth: double.infinity);
    final richText = Text.rich(span).build(context) as RichText;
    final renderObject = richText.createRenderObject(context);
    renderObject.layout(constraints);
    final boxesSelection = renderObject.getBoxesForSelection(TextSelection(
      baseOffset: 0,
      extentOffset: TextSpan(text: widget.text).toPlainText().length,
    ));
    return boxesSelection.last.right;
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
      if (key > t) return _values[key]!;
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
    for (final double t in values.keys) values[t] = values[t]! / integral;
    return _IntegralCurve._(original, integral, values);
  }
}
