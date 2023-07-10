import 'package:flutter/gestures.dart';

import 'mouse_button.dart';

/// Extensions for [PointerEvent].
extension PointerEventExt on PointerEvent {
  /// Returns the [MouseButton] that was pressed.
  MouseButton get buttonPressed {
    if ((buttons & kPrimaryMouseButton) != 0) {
      return MouseButton.primary;
    }
    if ((buttons & kSecondaryMouseButton) != 0) {
      return MouseButton.secondary;
    }
    if ((buttons & kMiddleMouseButton) != 0) {
      return MouseButton.middle;
    }
    if ((buttons & kBackMouseButton) != 0) {
      return MouseButton.back;
    }
    if ((buttons & kForwardMouseButton) != 0) {
      return MouseButton.forward;
    }
    return MouseButton.none;
  }
}
