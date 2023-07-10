import 'package:flutter/material.dart';

import 'extensions.dart';
import 'mouse_button.dart';
import 'mouse_widget.dart';

/// A widget that shows a mouse UI with 3 buttons that indicates the state of
/// the mouse buttons.
///
/// This is an independent widget that is not scoped to any particular
/// widget tree. It can be used anywhere in the widget tree. It listens to
/// the global mouse events and updates that come from underlying platform.
class MouseIndicator extends StatefulWidget {
  /// The width of the widget. If null, the width will be determined by
  /// [height] and [kDefaultMouseIndicatorAspectRatio] if [height] is not null.
  /// This is done to maintain the aspect ratio of the widget.
  /// If both are null, the width will be [kDefaultMouseIndicatorWidth].
  final double? width;

  /// The height of the widget. If null, the height will be determined by
  /// [width] and [kDefaultMouseIndicatorAspectRatio] if [width] is not null.
  /// This is done to maintain the aspect ratio of the widget.
  /// If both are null, the height will be [kDefaultMouseIndicatorHeight].
  final double? height;

  /// Called when the state of the mouse buttons changes (pressed or released).
  final ValueChanged<MouseButton>? onStateChanged;

  /// The style of the mouse indicator.
  final MouseIndicatorStyle style;

  /// Creates a [MouseIndicator] widget.
  const MouseIndicator({
    super.key,
    this.width,
    this.height,
    this.onStateChanged,
    this.style = const MouseIndicatorStyle(),
  });

  @override
  State<MouseIndicator> createState() => _MouseIndicatorState();
}

class _MouseIndicatorState extends State<MouseIndicator> {
  MouseButton buttonPressed = MouseButton.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.pointerRouter.addGlobalRoute(onGlobalPointerEvent);
  }

  /// Called when a global pointer event occurs.
  void onGlobalPointerEvent(PointerEvent event) {
    if (!(event is PointerDownEvent || event is PointerUpEvent)) return;
    buttonPressed = event.buttonPressed;
    setState(() {});
    widget.onStateChanged?.call(buttonPressed);
  }

  @override
  Widget build(BuildContext context) {
    return MouseWidget(
      width: widget.width,
      height: widget.height,
      style: widget.style,
      buttonPressed: buttonPressed,
      onStateChanged: widget.onStateChanged,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.pointerRouter
        .removeGlobalRoute(onGlobalPointerEvent);
    super.dispose();
  }
}
