import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'key_indicator_event.dart';
import 'extensions.dart';
import 'keyboard_mouse_indicator.dart';

/// A controller for the [KeyboardMouseIndicator] widget.
class KeyboardIndicatorController with ChangeNotifier {
  /// Creates a [KeyboardIndicatorController] widget.
  KeyboardIndicatorController({this.maxLength = 5});

  KeyIndicatorEvent? _lastEvent;

  final List<KeyIndicatorEvent> _history = [];

  /// The maximum number of keys to show in the indicator. This controls how
  /// many items from the history should be visible in the indicator. Items
  /// are discarded from the beginning of the history when the length of the
  /// history exceeds this value.
  int maxLength;

  /// The last key event.
  KeyIndicatorEvent? get lastEvent => _lastEvent;

  /// An unmodifiable list of keys history. The last item in the list is the
  /// most recent key pressed. This list will never be longer than [maxLength].
  List<KeyIndicatorEvent> get history => List.unmodifiable(_history);

  /// Adds a new key to the history. If the key is already in the history and
  /// it is the last item in the history, it will increment the count of the
  /// last item. Otherwise, it will add the key to the end of the history.
  /// If the history is already at [maxLength], it will remove the first item
  /// from the history.
  void _add(KeyIndicatorEvent event) {
    if (_history.isEmpty) {
      _history.add(event);
    } else if (_history.lastOrNull == event) {
      _history.last = event.copyWith(count: _history.last.count + 1);
    } else {
      _history.add(event);
    }

    if (_history.length > maxLength) _history.removeAt(0);

    notifyListeners();
  }

  /// Handles a key event for keyboard.
  void handleKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> pressedKeys) {
    _lastEvent = KeyIndicatorEvent(
      keyboardKey:
          pressedKeys.firstWhereOrNull((key) => !modifierKeys.contains(key)),
      modifiersPressed:
          pressedKeys.where((key) => modifierKeys.contains(key)).toSet(),
    );
    if (event is RawKeyDownEvent || event is KeyDownEvent) {
      onKeyDown(event, pressedKeys);
    } else if (event is RawKeyUpEvent || event is KeyUpEvent) {
      onKeyUp(event, pressedKeys);
      notifyListeners();
    }
  }

  /// Handles key down event for keyboard..
  void onKeyDown(KeyEvent event, Set<LogicalKeyboardKey> pressedKeys) {
    final KeyIndicatorEvent? last = _history.lastOrNull;
    final bool isModifierKey = modifierKeys.contains(event.logicalKey);
    final bool isNonModifierKey = !isModifierKey;

    final tempKeyEvent = KeyIndicatorEvent(
      modifiersPressed: isModifierKey ? {event.logicalKey} : {},
      keyboardKey: isNonModifierKey ? event.logicalKey : null,
    );

    if (last == null || last.mouseButton != null || last.isFinal) {
      // No last event found or last event was a mouse event. So, add a new event.
      final currentModifierKeys =
          pressedKeys.where((key) => modifierKeys.contains(key)).toSet();
      if (isNonModifierKey) {
        _add(KeyIndicatorEvent(
          modifiersPressed: currentModifierKeys,
          keyboardKey: event.logicalKey,
        ));
      } else {
        _add(KeyIndicatorEvent(
          modifiersPressed: currentModifierKeys,
          keyboardKey: isNonModifierKey ? event.logicalKey : null,
        ));
      }
    } else if (last == tempKeyEvent) {
      // This is the same event as the last event. So, increment the count.
      _history.last = last.copyWith(count: last.count + 1);
    } else {
      if (last.keyboardKey == null) {
        // only modifier keys were pressed in the last event.
        // So, update the last event.
        final item = last.copyWith(
          modifiersPressed: isModifierKey
              ? {...last.modifiersPressed, event.logicalKey}
              : null,
          keyboardKey: isNonModifierKey ? event.logicalKey : null,
        );
        if (_history.length > 1 && _history[_history.length - 2] == item) {
          _history.removeLast();
          _history.last = item.copyWith(count: _history.last.count + 1);
        } else {
          _history.last = item;
        }
      } else {
        if (isModifierKey) {
          // Last event had a printable key and this event has a modifier key.
          // So, add a new event.
          _add(tempKeyEvent);
        } else {
          if (event.logicalKey == last.keyboardKey) {
            // Last event had a printable key and this event has the same printable key.
            // So, increment the count.
            _history.last = last.copyWith(count: last.count + 1);
          } else {
            // Last event had a printable key and this event has a different printable key.
            // So, create a new event with this printable key and last event's modifiers.
            _add(KeyIndicatorEvent(
              modifiersPressed: last.modifiersPressed,
              keyboardKey: event.logicalKey,
            ));
          }
        }
      }
    }
    notifyListeners();
  }

  /// Handles key up event for keyboard.
  void onKeyUp(KeyEvent event, Set<LogicalKeyboardKey> pressedKeys) {
    final bool isModifierKey = modifierKeys.contains(event.logicalKey);
    final bool isNonModifierKey = !isModifierKey;

    final KeyIndicatorEvent last = _history.last;

    // Last event was a mouse event. So, ignore this event.
    if (last.mouseButton != null) return;

    // Anomaly:This is a non-modifier key event and the last event's printable key is
    // different from this event's printable key. So, ignore this event.
    if (isNonModifierKey && last.keyboardKey != event.logicalKey) return;

    // Anomaly: This is a modifier key event and the last event's modifiers do not
    // contain this event's modifier. So, ignore this event.
    if (isModifierKey && !last.modifiersPressed.contains(event.logicalKey)) {
      return;
    }

    if (_history.last.isFinal) return;

    if (isModifierKey) {
      // one of the modifier keys was released. create a new event with the
      // remaining modifiers.
      if (last.modifiersPressed.length == 1) {
        // only one modifier key was pressed. Make the last event final.
        _history.last = last.copyWith(isFinal: true);
        notifyListeners();
        return;
      } else {
        // more than one modifier key was pressed. Create a new event with the
        // remaining modifiers and mark last event as final.
        _history.last = last.copyWith(isFinal: true);
        // add(KeyIndicatorEvent(
        //   keyboardKey: last.keyboardKey,
        //   modifiersPressed: last.modifiersPressed
        //       .where((element) => element != event.logicalKey)
        //       .toSet(),
        // ));
      }
    } else {
      // A printable key was released. Make the last event final.
      _history.last = last.copyWith(isFinal: true);

      // if (last.modifiersPressed.isNotEmpty) {
      //   // A printable key was released while a modifier key was pressed.
      //   // Create a new event with the remaining modifiers.
      //   add(KeyIndicatorEvent(
      //     modifiersPressed: last.modifiersPressed,
      //   ));
      // }
    }
    notifyListeners();
  }

  /// Handles a pointer event for mouse.
  void handlePointerEvent(
      PointerEvent event, Set<LogicalKeyboardKey> pressedKeys) {
    if (event is PointerDownEvent) {
      _lastEvent = KeyIndicatorEvent(mouseButton: event.buttonPressed);
      _add(KeyIndicatorEvent(mouseButton: event.buttonPressed));
    } else if (event is PointerUpEvent) {
      _lastEvent = KeyIndicatorEvent(
        modifiersPressed:
            pressedKeys.where((key) => modifierKeys.contains(key)).toSet(),
        keyboardKey:
            pressedKeys.lastWhereOrNull((key) => !modifierKeys.contains(key)),
      );
      notifyListeners();
    }
  }

  /// Clears the history.
  void clear() {
    _history.clear();
    _lastEvent = null;
    notifyListeners();
  }
}
