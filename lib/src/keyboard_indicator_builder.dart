import 'package:flutter/material.dart';

import 'controller.dart';
import 'key_indicator_event.dart';

/// A builder that builds a widget that indicates a keyboard key pressed.
typedef KeyboardIndicatorWidgetBuilder = Widget Function(
    BuildContext context, List<KeyIndicatorEvent> keys);

/// A widget that indicates a history of keyboard keys pressed. It only shows
/// the last [maxLength] distinct keys pressed. If the same key is pressed
/// multiple times, it will show how many times it was pressed.
class KeyboardMouseIndicatorBuilder extends StatefulWidget {
  /// The controller of the keyboard indicator.
  final KeyboardIndicatorController? controller;

  /// The maximum number of keys to allow in the history. This controls how
  /// many items from the history should be visible in the indicator. Items
  /// are discarded from the beginning of the history when the length of the
  /// history exceeds this value.
  /// If [showAsHistory] is true, the list of keys pressed will contain history
  /// of keys pressed up to [maxLength] distinct keys.
  /// This is not used if [showAsHistory] is false.
  final int maxLength;

  /// The builder that builds the widget that indicates the keyboard keys pressed.
  /// The builder is called with the context and the list of keys pressed.
  ///
  /// If [showAsHistory] is true, the list of keys pressed will contain history
  /// of keys pressed up to [maxLength] distinct keys.
  /// If [showAsHistory] is false, the list of keys pressed will contain only
  /// the pressed keys at the moment.
  ///
  /// The order of the keys pressed is from the oldest to the newest.
  final KeyboardIndicatorWidgetBuilder builder;

  /// Whether to show the keys pressed as history or not.
  /// This alters the behavior of keys list param of the [builder] callback.
  /// If [showAsHistory] is true, the list of keys pressed will contain history
  /// of keys pressed up to [maxLength] distinct keys.
  /// If [showAsHistory] is false, the list of keys pressed will contain only
  /// the pressed keys at the moment.
  final bool showAsHistory;

  /// Creates a [KeyboardMouseIndicatorBuilder] widget.
  const KeyboardMouseIndicatorBuilder({
    super.key,
    this.controller,
    this.maxLength = 5,
    required this.builder,
    this.showAsHistory = false,
  });

  @override
  State<KeyboardMouseIndicatorBuilder> createState() =>
      _KeyboardMouseIndicatorBuilderState();
}

class _KeyboardMouseIndicatorBuilderState
    extends State<KeyboardMouseIndicatorBuilder> {
  late KeyboardIndicatorController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??
        KeyboardIndicatorController(maxLength: widget.maxLength);
    controller.addListener(onChanged);

    WidgetsBinding.instance.keyboard.addHandler(onKeyEvent);

    WidgetsBinding.instance.pointerRouter.addGlobalRoute(onPointerEvent);
  }

  @override
  void didUpdateWidget(covariant KeyboardMouseIndicatorBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      controller.removeListener(onChanged);
      controller = widget.controller ??
          KeyboardIndicatorController(maxLength: widget.maxLength);
      controller.addListener(onChanged);
    }
    if (oldWidget.maxLength != widget.maxLength) {
      controller.maxLength = widget.maxLength;
    }
  }

  void onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      widget.showAsHistory
          ? controller.history
          : List.unmodifiable(
              controller.lastEvent != null ? [controller.lastEvent] : []),
    );
  }

  void onPointerEvent(PointerEvent event) {
    if (!(event is PointerDownEvent || event is PointerUpEvent)) return;
    controller.handlePointerEvent(
        event, WidgetsBinding.instance.keyboard.logicalKeysPressed);
  }

  bool onKeyEvent(KeyEvent event) {
    controller.handleKeyEvent(
        event, WidgetsBinding.instance.keyboard.logicalKeysPressed);
    return false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.pointerRouter.removeGlobalRoute(onPointerEvent);
    WidgetsBinding.instance.keyboard.removeHandler(onKeyEvent);
    controller.removeListener(onChanged);
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }
}
