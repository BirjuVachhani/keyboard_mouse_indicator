import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controller.dart';
import 'key_indicator_event.dart';
import 'keyboard_indicator_builder.dart';
import 'mouse_indicator.dart';

/// A widget that indicates a history of keyboard keys pressed. It only shows
/// the last [maxLength] distinct keys pressed. If the same key is pressed
/// multiple times, it will show how many times it was pressed.
class KeyboardMouseIndicator extends StatelessWidget {
  /// The text style of the keys indicator text.
  final TextStyle? textStyle;

  /// The controller of the keyboard indicator.
  final KeyboardIndicatorController? controller;

  /// The maximum number of keys to show in the indicator. This controls how
  /// many items from the history should be visible in the indicator. Items
  /// are discarded from the beginning of the history when the length of the
  /// history exceeds this value.
  final int maxLength;

  /// The spacing between the keys text in the indicator.
  final double itemSpacing;

  /// The alignment indicators.
  final Alignment alignment;

  /// The builder for the indicator items.
  final Widget Function(int index, KeyIndicatorEvent item)? itemBuilder;

  /// Whether to show the keys pressed as history or not.
  final bool showAsHistory;

  /// Whether to fade history items as they become older.
  final bool fadeText;

  /// Whether to show the mouse indicator or not.
  final bool showMouseIndicator;

  /// The builder for the key label.
  final String Function(LogicalKeyboardKey key)? keyLabelBuilder;

  /// Widget to display for the mouse indicator.
  final Widget? mouseIndicator;

  /// Creates a [KeyboardMouseIndicator] widget.
  const KeyboardMouseIndicator({
    super.key,
    this.textStyle,
    this.controller,
    this.maxLength = 5,
    this.itemSpacing = 4,
    this.alignment = Alignment.centerLeft,
    this.itemBuilder,
    this.showAsHistory = true,
    this.fadeText = true,
    this.showMouseIndicator = true,
    this.keyLabelBuilder,
    this.mouseIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: alignment.x < 0
          ? CrossAxisAlignment.start
          : alignment.x > 0
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center,
      children: [
        KeyboardMouseIndicatorBuilder(
          controller: controller,
          maxLength: maxLength,
          showAsHistory: showAsHistory,
          builder: (context, List<KeyIndicatorEvent> pressedKeys) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: alignment.x < 0
                  ? CrossAxisAlignment.start
                  : alignment.x > 0
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.center,
              children: [
                for (int index = 0; index < pressedKeys.length; index++)
                  Builder(
                    builder: (context) {
                      final event = pressedKeys[index];

                      if (itemBuilder != null) {
                        return itemBuilder!(index, event);
                      }

                      final textColor = textStyle?.color ??
                          Theme.of(context).colorScheme.onSurface;

                      final percentage = (index + 1) / pressedKeys.length;
                      final colorOpacity = fadeText
                          ? const Interval(0, 0.8).transform(percentage)
                          : 1.0;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom:
                              index != pressedKeys.length - 1 ? itemSpacing : 0,
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: prettify(event),
                            children: [
                              if (event.count > 1)
                                TextSpan(
                                  text: ' x${event.count}',
                                  style: const TextStyle(letterSpacing: 1),
                                ),
                            ],
                          ),
                          textAlign: alignment.x < 0
                              ? TextAlign.start
                              : alignment.x > 0
                                  ? TextAlign.end
                                  : TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1,
                          ).merge(textStyle).copyWith(
                                color: textColor.withOpacity(colorOpacity),
                              ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
        if (showMouseIndicator) ...[
          const SizedBox(height: 16),
          mouseIndicator ?? const MouseIndicator(),
        ],
      ],
    );
  }

  /// Returns a prettified string of the given [event].
  String prettify(KeyIndicatorEvent event) {
    if (event.mouseButton != null) {
      return event.mouseButton!.isPrimary
          ? 'Left Mouse'
          : event.mouseButton!.isSecondary
              ? 'Right Mouse'
              : 'Middle Mouse';
    }
    final printableKey = prettifyKey(event.keyboardKey);
    if (event.modifiersPressed.isEmpty) return printableKey;
    final modifiers =
        event.modifiersPressed.map(keyLabelBuilder ?? prettifyKey).join(' + ');

    if (printableKey.isEmpty) return modifiers;

    return '$modifiers + $printableKey';
  }

  /// Returns a prettified string of the given [key].
  String prettifyKey(LogicalKeyboardKey? key) {
    if (key == null) return '';
    if (isMetaPressed(key)) return 'CMD'; // ⌘
    if (isControlPressed(key)) return 'CTRL';
    if (isShiftPressed(key)) return 'SHIFT'; // ⇧
    if (isAltPressed(key)) {
      return defaultTargetPlatform == TargetPlatform.macOS ? 'OPT' : 'ALT';
    }
    return key.keyLabel;
  }

  /// Returns whether the given [key] can be considered as a control key.
  bool isControlPressed(LogicalKeyboardKey key) => controlKeys.contains(key);

  /// Returns whether the given [key] can be considered as a shift key.
  bool isShiftPressed(LogicalKeyboardKey key) => shiftKeys.contains(key);

  /// Returns whether the given [key] can be considered as an alt key.
  bool isAltPressed(LogicalKeyboardKey key) => altKeys.contains(key);

  /// Returns whether the given [key] can be considered as a meta key.
  bool isMetaPressed(LogicalKeyboardKey key) => metaKeys.contains(key);
}

/// List of keys that are considered as control keys.
const controlKeys = <LogicalKeyboardKey>[
  LogicalKeyboardKey.controlLeft,
  LogicalKeyboardKey.controlRight,
  LogicalKeyboardKey.control,
];

/// List of keys that are considered as meta keys.
const metaKeys = <LogicalKeyboardKey>[
  LogicalKeyboardKey.metaLeft,
  LogicalKeyboardKey.metaRight,
  LogicalKeyboardKey.meta,
];

/// List of keys that are considered as shift keys.
const shiftKeys = <LogicalKeyboardKey>[
  LogicalKeyboardKey.shiftLeft,
  LogicalKeyboardKey.shiftRight,
  LogicalKeyboardKey.shift,
];

/// List of keys that are considered as alt keys.
const altKeys = <LogicalKeyboardKey>[
  LogicalKeyboardKey.altLeft,
  LogicalKeyboardKey.altRight,
  LogicalKeyboardKey.alt,
];

/// List of keys that are considered as modifier keys.
const modifierKeys = <LogicalKeyboardKey>[
  ...controlKeys,
  ...metaKeys,
  ...shiftKeys,
  ...altKeys,
];
