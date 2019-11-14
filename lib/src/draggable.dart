import 'package:flutter/material.dart';
import 'multiple-gestures.dart';

// Tutorial on physics animations
// https://flutter.dev/docs/cookbook/animation/physics-simulation#complete-example

/// A draggable card that moves back to [snapTo] when it's released.
class Draggable extends StatefulWidget {
  final Widget child;
  final Alignment snapTo;

  Draggable({@required this.child, @required this.snapTo});

  @override
  _DraggableState createState() => _DraggableState();
}

class _DraggableState extends State<Draggable> with SingleTickerProviderStateMixin {
  Alignment _alignment;

  @override
  void initState() {
    super.initState();
    _alignment = widget.snapTo;

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        AllowMultiplePanGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            AllowMultiplePanGestureRecognizer>(
          () => AllowMultiplePanGestureRecognizer(), //constructor
          (AllowMultiplePanGestureRecognizer instance) {
            instance
              ..onStart = (details) {
//                controller.stop();
              }
              ..onUpdate = (details) {
//                debugPrint("Delta: ${details.delta}, Size: ${size}");
                setState(() {
                  _alignment += Alignment(
                    details.delta.dx / (size.width / 2),
                    details.delta.dy / (size.height / 2),
                  );
                });
              }
              ..onEnd = (details) {
                debugPrint("End of move event");
              };
          },
        )
      },
      child: Align(
        alignment: _alignment,
        child: widget.child,
      ),
    );
  }
}
