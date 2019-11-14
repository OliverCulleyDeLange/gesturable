import 'package:flutter/material.dart';

import 'multiple-gestures.dart';

class Scalable extends StatefulWidget {
  final Widget child;

  Scalable({@required this.child});

  @override
  _ScalableState createState() => _ScalableState();
}

class _ScalableState extends State<Scalable> {
  double _scale;
  double _previousScale;
  double _rotate;
  double _previousRotation;

  @override
  void initState() {
    super.initState();
    _scale = 1;
    _previousScale = 1;
    _rotate = 0;
    _previousRotation = 0;
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        AllowMultipleScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            AllowMultipleScaleGestureRecognizer>(
              () => AllowMultipleScaleGestureRecognizer(), //constructor
              (AllowMultipleScaleGestureRecognizer instance) {
            instance
              ..onUpdate = (details) {
              setState(() {
                _scale += details.scale - _previousScale;
                _previousScale = details.scale;
                _rotate += details.rotation - _previousRotation;
                _previousRotation = details.rotation;
              });
            }
            ..onEnd = (details) {
              debugPrint("End of scaling event");
              setState(() {
                _previousScale = 1;
                _previousRotation = 0;
              });
            };
          },
        )
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationZ(_rotate)
          ..scale(_scale),
        transformHitTests: true,
        child: widget.child,
      ),
    );
  }
}
