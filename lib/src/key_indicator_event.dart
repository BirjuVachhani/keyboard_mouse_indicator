import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

import 'mouse_button.dart';

/// An event that represents a key pressed or a mouse button pressed event
class KeyIndicatorEvent with EquatableMixin {
  /// The number of times the key was pressed in a row.
  final int count;

  /// The mouse button that was pressed.
  final MouseButton? mouseButton;

  /// The keyboard key that was pressed.
  final LogicalKeyboardKey? keyboardKey;

  /// The set of modifiers that were pressed when the key was pressed.
  final Set<LogicalKeyboardKey> modifiersPressed;

  /// Whether this event is marked as final. An event is marked as final if
  /// any subsequent event cannot be merged with this event.
  final bool isFinal;

  /// Creates a [KeyIndicatorEvent] widget.
  KeyIndicatorEvent({
    this.count = 1,
    this.mouseButton,
    this.keyboardKey,
    bool isFinal = false,
    Set<LogicalKeyboardKey> modifiersPressed = const {},
  })  : assert(count > 0),
        isFinal = mouseButton != null || isFinal,
        modifiersPressed = {...modifiersPressed};

  /// Creates a copy of this [KeyIndicatorEvent] but with the given fields
  /// replaced with the new values.
  KeyIndicatorEvent copyWith({
    int? count,
    MouseButton? mouseButton,
    LogicalKeyboardKey? keyboardKey,
    Set<LogicalKeyboardKey>? modifiersPressed,
    bool? isFinal,
  }) {
    return KeyIndicatorEvent(
      count: count ?? this.count,
      mouseButton: mouseButton ?? this.mouseButton,
      keyboardKey: keyboardKey ?? this.keyboardKey,
      modifiersPressed: modifiersPressed ?? this.modifiersPressed,
      isFinal: isFinal ?? this.isFinal,
    );
  }

  @override
  List<Object?> get props => [
        mouseButton,
        keyboardKey,
        modifiersPressed,
      ];
}
