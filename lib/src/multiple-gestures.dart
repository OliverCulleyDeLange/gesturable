// From https://www.davidanaya.io/flutter/combine-multiple-gestures.html
// Custom Gesture Recognizer.
// rejectGesture() is overridden. When a gesture is rejected, this is the function that is called. By default, it disposes of the
// Recognizer and runs clean up. However we modified it so that instead the Recognizer is disposed of, it is actually manually added.
// The result is instead you have one Recognizer winning the Arena, you have two. It is a win-win.
import 'package:flutter/gestures.dart';

class AllowMultipleScaleGestureRecognizer extends ScaleGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}

class AllowMultiplePanGestureRecognizer extends PanGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}