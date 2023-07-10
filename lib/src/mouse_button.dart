/// Represents a mouse button.
enum MouseButton {
  /// Represents absence of a mouse button.
  none,

  /// Represents the primary mouse button.
  primary,

  /// Represents the secondary mouse button.
  secondary,

  /// Represents the middle mouse button.
  middle,

  /// Represents the back mouse button.
  back,

  /// Represents the forward mouse button.
  forward;

  /// Whether this is [MouseButton.primary].
  bool get isPrimary => this == MouseButton.primary;

  /// Whether this is [MouseButton.secondary].
  bool get isSecondary => this == MouseButton.secondary;

  /// Whether this is [MouseButton.middle].
  bool get isMiddle => this == MouseButton.middle;

  /// Whether this is [MouseButton.back].
  bool get isBack => this == MouseButton.back;

  /// Whether this is [MouseButton.forward].
  bool get isForward => this == MouseButton.forward;
}
