// Tutorial on physics animations
// https://flutter.dev/docs/cookbook/animation/physics-simulation#complete-example

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

typedef ShouldSnap = bool Function(Velocity velocity);
typedef OnMove = void Function(Vector3 offset, double scale, double rotate);

/// A draggable card that moves back to [Alignment.center] when it's
/// released.
class Movable extends StatefulWidget {
  final Widget child;
  final Alignment snapTo;
  final ShouldSnap shouldSnap;
  final OnMove onMove;

  Movable({@required this.child, @required this.snapTo, @required this.shouldSnap, @required this.onMove});

  @override
  _MovableState createState() => _MovableState();
}

class _MovableState extends State<Movable> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Matrix4> _animation;

  double _scale;
  double _previousScale;

  Vector3 _translate;
  Vector3 _previousTranslate;

  double _rotate;
  double _previousRotation;

  /// Calculates and runs a [SpringSimulation].
  void _runAnimation(Offset pixelsPerSecond, Size size) {
    var snapOffset = widget.snapTo.alongSize(size);
//    debugPrint("$snapOffset");
    _animation = _controller.drive(
      Matrix4Tween(
        begin: Matrix4.translation(_translate),
        end: Matrix4.translation(
            centerTransformFromFocalPoint(snapOffset, size)),
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _scale = 1;
    _previousScale = 1;
    _translate = Vector3(0.0, 0.0, 0.0);
    _previousTranslate = Vector3(0.0, 0.0, 0.0);
    _rotate = 0;
    _previousRotation = 0;

    _controller = AnimationController(vsync: this);

    _controller.addListener(() {
      setState(() {
        _translate = _animation.value.getTranslation();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Vector3 centerTransformFromFocalPoint(Offset focalPoint, Size viewSize) =>
      Vector3(
        focalPoint.dx - (viewSize.width / 2),
        focalPoint.dy - (viewSize.height / 2),
        0.0,
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onScaleStart: (details) {
        _controller.stop();
        setState(() {
          _previousTranslate =
              centerTransformFromFocalPoint(details.focalPoint, size);
        });
      },
      onScaleUpdate: (details) {
        widget.onMove(_translate, _scale, _rotate);
        setState(() {
          _rotate += details.rotation - _previousRotation;
          _previousRotation = details.rotation;

          _scale += details.scale - _previousScale;
          _previousScale = details.scale;

          var _pos = centerTransformFromFocalPoint(details.focalPoint, size);
          var _delta = _pos - _previousTranslate;
          _translate += _delta;
          _previousTranslate = _pos;
        });
      },
      onScaleEnd: (details) {
        if (widget.shouldSnap(details.velocity)) {
          _runAnimation(details.velocity.pixelsPerSecond, size);
        }
        setState(() {
          _previousRotation = 0;
          _previousScale = 1;
        });
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.translation(_translate)
          ..rotateZ(_rotate)
          ..scale(_scale, _scale, 0.0),
        transformHitTests: true,
        child: widget.child,
      ),
    );
  }
}
