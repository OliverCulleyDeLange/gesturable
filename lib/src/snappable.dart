import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

// Tutorial on physics animations
// https://flutter.dev/docs/cookbook/animation/physics-simulation#complete-example

class Snappable extends StatefulWidget {
  final Widget child;
  final Alignment snapTo;

  Snappable({@required this.child, @required this.snapTo});

  @override
  _SnappableState createState() => _SnappableState();
}

class _SnappableState extends State<Snappable> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Matrix4> _animation;

  Vector3 _translate;

  Vector3 centerTransformFromFocalPoint(Offset focalPoint, Size viewSize) =>
      Vector3(
        focalPoint.dx - (viewSize.width / 2),
        focalPoint.dy - (viewSize.height / 2),
        0.0,
      );

  /// Calculates and runs a [SpringSimulation].
  void _runAnimation(Offset pixelsPerSecond, Size size) {
    var snapOffset = widget.snapTo.alongSize(size);
    debugPrint("$snapOffset");
    _animation = _controller.drive(
      Matrix4Tween(
        begin: Matrix4.translation(_translate),
        end: Matrix4.translation(
            centerTransformFromFocalPoint(widget.snapTo.alongSize(size), size)),
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
    _controller = AnimationController(vsync: this);
    _translate = Vector3(0.0, 0.0, 0.0);

    _controller.addListener(() {
      setState(() {
        _translate = _animation.value.getTranslation();
      });
    });

//    _runAnimation(Offset(0, 0), Size(500,500));

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: (details) {
        _controller.stop();
      },
      onScaleEnd: (details) {
        debugPrint("Running snap animation");
//        _runAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.translation(_translate),
        transformHitTests: true,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

