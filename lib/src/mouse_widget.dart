import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'mouse_button.dart';

/// The default width of the mouse indicator.
const double kDefaultMouseIndicatorWidth = 42;

/// The default height of the mouse indicator.
const double kDefaultMouseIndicatorHeight = 60;

/// The default aspect ratio of the mouse indicator.
const double kDefaultMouseIndicatorAspectRatio =
    kDefaultMouseIndicatorWidth / kDefaultMouseIndicatorHeight;

/// A widget that displays a mouse.
class MouseWidget extends StatelessWidget {
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

  /// The button that is currently pressed.
  final MouseButton buttonPressed;

  /// Style of the widget. Provides customization for the UI.
  final MouseIndicatorStyle style;

  /// Creates a [MouseIndicator] widget.
  const MouseWidget({
    super.key,
    this.width,
    this.height,
    this.onStateChanged,
    this.buttonPressed = MouseButton.none,
    this.style = const MouseIndicatorStyle(),
  })  : assert(width == null || width > 0, 'width must be greater than 0'),
        assert(height == null || height > 0, 'height must be greater than 0');

  @override
  Widget build(BuildContext context) {
    final double width = this.width ??
        (this.height != null
            ? this.height! * kDefaultMouseIndicatorAspectRatio
            : kDefaultMouseIndicatorWidth);

    final double height = this.height ??
        (this.width != null
            ? this.width! / kDefaultMouseIndicatorAspectRatio
            : kDefaultMouseIndicatorHeight);

    final border = getBorder(context, width);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _MouseButtonsPainter(
          indicatorColor: style.indicatorColor ??
              style.borderColor ??
              Theme.of(context).colorScheme.onSurface,
          scrollButtonWidth: style.scrollButtonWidth,
          scrollButtonWidthFactor: style.scrollButtonWidthFactor,
          heightFactor: style.buttonsHeightFactor,
          showScrollButton: style.showScrollButton,
          buttonPressed: buttonPressed,
          backgroundColor: style.backgroundColor,
          border: border,
          showBorder: style.showBorder,
          spacing: style.spacing ?? border.side.width,
        ),
      ),
    );
  }

  /// Returns the border to use for the widget.
  OutlinedBorder getBorder(BuildContext context, double width) {
    if (style.border != null) return style.border!;
    return RoundedRectangleBorder(
      borderRadius: style.borderRadius ??
          BorderRadius.only(
            topLeft: Radius.circular(width / 4),
            topRight: Radius.circular(width / 4),
            bottomLeft: Radius.circular(width / 2),
            bottomRight: Radius.circular(width / 2),
          ),
      side: BorderSide(
        color: style.borderColor ?? Theme.of(context).colorScheme.onSurface,
        width: style.borderWidth ?? 1,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties.add(EnumProperty<MouseButton>('buttonPressed', buttonPressed));
    properties.add(DiagnosticsProperty<MouseIndicatorStyle>('style', style));
  }
}

/// A painter that draws the mouse buttons.
class _MouseButtonsPainter extends CustomPainter {
  final Color indicatorColor;
  final Color? backgroundColor;
  final double? scrollButtonWidth;
  final double? scrollButtonWidthFactor;
  final double heightFactor;
  final bool showScrollButton;
  final MouseButton buttonPressed;
  final OutlinedBorder border;
  final bool showBorder;
  final double spacing;

  double get borderWidth => border.side.width;

  Color get borderColor => border.side.color;

  late final Paint borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = borderColor
    ..strokeWidth = borderWidth;

  /// Creates a new [_MouseButtonsPainter].
  _MouseButtonsPainter({
    required this.indicatorColor,
    required this.backgroundColor,
    required this.scrollButtonWidth,
    required this.scrollButtonWidthFactor,
    required this.heightFactor,
    required this.showScrollButton,
    required this.buttonPressed,
    required this.border,
    required this.showBorder,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect area = (Offset.zero & size);
    final Rect effectiveArea =
        showBorder ? area.deflate(borderWidth / 2) : area;

    final buttonsHeight = area.height * heightFactor;
    final buttonsArea = Rect.fromLTWH(
      effectiveArea.left,
      effectiveArea.top,
      effectiveArea.width,
      buttonsHeight,
    );

    // clip to border
    canvas.clipPath(border.getOuterPath(area.deflate(borderWidth > 1 ? 1 : 0)));

    // draw background
    if (backgroundColor != null && backgroundColor!.opacity != 0) {
      drawBackground(canvas, buttonsArea, area);
    }

    if (!showBorder) {
      drawButtons(canvas, buttonsArea,
          debugShowAll: true, color: backgroundColor);
    }
    drawButtons(canvas, buttonsArea);
    if (showBorder) drawBottomLine(canvas, buttonsArea);
    if (showBorder) drawDividers(canvas, buttonsArea);

    // border
    if (showBorder) {
      canvas.drawPath(border.getOuterPath(effectiveArea), borderPaint);
    }
  }

  void drawBackground(Canvas canvas, Rect buttonsArea, Rect area) {
    final paint = Paint()..color = backgroundColor ?? Colors.transparent;

    if (showBorder) {
      canvas.drawRect(area, paint);
      return;
    }

    final rect = Rect.fromLTRB(
      area.left,
      buttonsArea.bottom + spacing,
      area.right,
      area.bottom,
    );

    canvas.drawRect(rect, paint);
  }

  /// Draws the mouse buttons.
  void drawButtons(
    Canvas canvas,
    Rect buttonsArea, {
    bool debugShowAll = false,
    Color? color,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color ?? indicatorColor;

    final buttonHeight = buttonsArea.height;

    final double buttonWidth;
    if (!showScrollButton) {
      buttonWidth = buttonsArea.width / 2;
    } else {
      buttonWidth =
          (buttonsArea.width - getScrollButtonWidth(buttonsArea.width)) / 2;
    }

    final double gap = !showBorder ? spacing / 2 : 0;

    if (debugShowAll || buttonPressed.isPrimary) {
      // Draw left button
      final buttonRect = Rect.fromLTWH(
        buttonsArea.left,
        buttonsArea.top,
        buttonWidth - gap,
        buttonHeight,
      );
      canvas.drawRect(buttonRect, paint);
    }

    if (debugShowAll || buttonPressed.isSecondary) {
      // Draw right button
      final buttonRect = Rect.fromLTWH(
        buttonsArea.right - buttonWidth + gap,
        buttonsArea.top,
        buttonWidth,
        buttonHeight,
      );
      canvas.drawRect(buttonRect, paint);
    }

    if (debugShowAll || buttonPressed.isMiddle && showScrollButton) {
      // Draw scroll button
      final buttonRect = Rect.fromLTWH(
        buttonsArea.left + buttonWidth + gap,
        buttonsArea.top,
        getScrollButtonWidth(buttonsArea.width) - (gap * 2),
        buttonHeight,
      );
      canvas.drawRect(buttonRect, paint);
    }
  }

  /// Draws button dividers/separators
  void drawDividers(Canvas canvas, Rect buttonsArea) {
    final dividerHeight = buttonsArea.height;

    final double buttonWidth;
    if (!showScrollButton) {
      buttonWidth = buttonsArea.width / 2;
    } else {
      buttonWidth =
          (buttonsArea.width - getScrollButtonWidth(buttonsArea.width)) / 2;
    }

    if (showScrollButton) {
      // 2 dividers
      canvas.drawLine(
        Offset(buttonsArea.left + buttonWidth, buttonsArea.top),
        Offset(buttonsArea.left + buttonWidth, dividerHeight),
        borderPaint,
      );
      canvas.drawLine(
        Offset(buttonsArea.right - buttonWidth, buttonsArea.top),
        Offset(buttonsArea.right - buttonWidth, dividerHeight),
        borderPaint,
      );
    } else {
      // 1 divider in center
      canvas.drawLine(
        Offset(buttonsArea.width / 2, buttonsArea.top),
        Offset(buttonsArea.width / 2, dividerHeight),
        borderPaint,
      );
    }
  }

  /// Returns the width of the scroll button.
  double getScrollButtonWidth(double totalWidth) {
    if (scrollButtonWidth != null) return scrollButtonWidth!;
    if (scrollButtonWidthFactor != null) {
      return (totalWidth / 3) * scrollButtonWidthFactor!;
    }
    return totalWidth / 3;
  }

  /// Draws the bottom line.
  void drawBottomLine(Canvas canvas, Rect buttonsArea) {
    final start = Offset(buttonsArea.left, buttonsArea.height);
    final end = Offset(buttonsArea.right, buttonsArea.height);
    canvas.drawLine(start, end, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _MouseButtonsPainter oldDelegate) =>
      oldDelegate.indicatorColor != indicatorColor ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.scrollButtonWidth != scrollButtonWidth ||
      oldDelegate.scrollButtonWidthFactor != scrollButtonWidthFactor ||
      oldDelegate.heightFactor != heightFactor ||
      oldDelegate.showScrollButton != showScrollButton ||
      oldDelegate.buttonPressed != buttonPressed ||
      oldDelegate.showBorder != showBorder ||
      oldDelegate.border != border;
}

/// Defines the style of the mouse region.
class MouseIndicatorStyle with Diagnosticable {
  /// The color of the border.
  /// Defaults to Theme.of(context).colorScheme.onSurface.
  ///
  /// If [border] is used, then this must be null. Border color will be
  /// determined by [border].
  final Color? borderColor;

  /// The color of the background. Defaults to transparent.
  final Color? backgroundColor;

  /// The color of the indicator. Defaults to border color.
  /// Defaults to [borderColor] if provided, otherwise
  /// Theme.of(context).colorScheme.onSurface.
  final Color? indicatorColor;

  /// The width of the border. Defaults to 1
  ///
  /// If [border] is used, then this must be null. Border width will be
  /// determined by [border].
  final double? borderWidth;

  /// The border radius of outer frame. If null, the default border radius
  /// will be used. The default border radius is asymmetric with the
  /// top-left and top-right corners having same radius and the bottom-left
  /// and bottom-right corners having same radius.
  ///
  /// If [border] is used, then this must be null. Border radius will be
  /// determined by [border].
  final BorderRadius? borderRadius;

  /// A custom border to use instead of the default border.
  final OutlinedBorder? border;

  /// The width of the scroll button in pixels unlike [scrollButtonWidthFactor]
  /// which is a factor of the width of the widget.
  ///
  /// Either [scrollButtonWidth] or [scrollButtonWidthFactor] can be provided.
  ///
  /// If null, the width will be determined by [scrollButtonWidthFactor].
  /// If both are null, the width will be same as the width of the
  /// other buttons.
  final double? scrollButtonWidth;

  /// The width factor of the scroll button that determines how much of the
  /// width the scroll button should take. The value must be between 0 and 1.
  /// The width is determined by multiplying this factor with the width of the
  /// a single button as if all 3 buttons has the same width.
  ///
  /// e.g. <per_button_width> * scrollButtonWidthFactor;
  ///
  /// [scrollButtonWidthFactor] with value of 1 means the width of the scroll
  /// button will be same as the width of the other buttons.
  ///
  /// Either [scrollButtonWidth] or [scrollButtonWidthFactor] can be provided.
  ///
  /// If null, the width will be determined by [scrollButtonWidth].
  /// If both are null, the width will be same as the width of the
  /// other buttons.
  final double? scrollButtonWidthFactor;

  /// The height factor of the buttons that determines how much of the height
  /// the buttons should take. The value must be between 0 and 1 where 1 means
  /// the buttons will take the entire height of the widget.
  final double buttonsHeightFactor;

  /// Whether to show the middle/scroll button.
  final bool showScrollButton;

  /// Whether to show the border.
  final bool showBorder;

  /// The spacing between the buttons when [showBorder] is false..
  final double? spacing;

  /// Creates a new [MouseIndicatorStyle].
  const MouseIndicatorStyle({
    this.borderColor,
    this.backgroundColor,
    this.indicatorColor,
    this.borderWidth,
    this.border,
    this.scrollButtonWidth,
    this.scrollButtonWidthFactor,
    this.buttonsHeightFactor = 0.45,
    this.showScrollButton = true,
    this.showBorder = true,
    this.spacing,
    this.borderRadius,
  })  : assert(borderWidth == null || borderWidth > 0,
            'borderWidth must be greater than 0'),
        assert(
          buttonsHeightFactor > 0 && buttonsHeightFactor <= 1,
          'buttonsHeightFactor must be between 0 and 1',
        ),
        assert(
          scrollButtonWidth == null || scrollButtonWidth >= 0,
          'scrollButtonWidth must be greater than 0',
        ),
        assert(
          scrollButtonWidthFactor == null ||
              (scrollButtonWidthFactor > 0 && scrollButtonWidthFactor <= 1),
          'scrollButtonWidthFactor must be between 0 and 1',
        ),
        assert(
          scrollButtonWidth == null || scrollButtonWidthFactor == null,
          'Cannot set both scrollButtonWidth and scrollButtonWidthFactor',
        ),
        assert(
            border == null ||
                (borderWidth == null &&
                    borderRadius == null &&
                    borderColor == null),
            'Cannot provide borderRadius, borderColor or borderWidth when border is provided');

  /// Creates a new [MouseIndicatorStyle] with a filled background and no border.
  MouseIndicatorStyle.filled({
    this.backgroundColor,
    this.indicatorColor,
    this.scrollButtonWidth,
    this.scrollButtonWidthFactor,
    this.buttonsHeightFactor = 0.45,
    this.showScrollButton = true,
    this.spacing,
  })  : borderColor = null,
        borderWidth = null,
        border = null,
        showBorder = false,
        borderRadius = null;

  /// Creates a new [MouseIndicatorStyle] with a border.
  MouseIndicatorStyle.outlined({
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.backgroundColor,
    this.indicatorColor,
    this.border,
    this.scrollButtonWidth,
    this.scrollButtonWidthFactor,
    this.buttonsHeightFactor = 0.45,
    this.showScrollButton = true,
  })  : spacing = null,
        showBorder = true;

  /// Creates a copy of this [MouseIndicatorStyle] but with the given fields replaced
  /// with the new values.
  MouseIndicatorStyle copyWith({
    Color? borderColor,
    Color? backgroundColor,
    Color? indicatorColor,
    double? borderWidth,
    OutlinedBorder? border,
    double? scrollButtonWidth,
    double? scrollButtonWidthFactor,
    double? buttonsHeightFactor,
    bool? showScrollButton,
    bool? showBorder,
    double? spacing,
  }) {
    return MouseIndicatorStyle(
      borderColor: borderColor ?? this.borderColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      borderWidth: borderWidth ?? this.borderWidth,
      border: border ?? this.border,
      scrollButtonWidth: scrollButtonWidth ?? this.scrollButtonWidth,
      scrollButtonWidthFactor:
          scrollButtonWidthFactor ?? this.scrollButtonWidthFactor,
      buttonsHeightFactor: buttonsHeightFactor ?? this.buttonsHeightFactor,
      showScrollButton: showScrollButton ?? this.showScrollButton,
      showBorder: showBorder ?? this.showBorder,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(ColorProperty('borderColor', borderColor));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('indicatorColor', indicatorColor));
    properties.add(DoubleProperty('borderWidth', borderWidth));
    properties.add(DiagnosticsProperty<OutlinedBorder>('border', border));
    properties.add(DoubleProperty('scrollButtonWidth', scrollButtonWidth));
    properties.add(
        DoubleProperty('scrollButtonWidthFactor', scrollButtonWidthFactor));
    properties.add(DoubleProperty('buttonsHeightFactor', buttonsHeightFactor));
    properties.add(FlagProperty('showScrollButton',
        value: showScrollButton,
        ifTrue: 'Show Scroll Button',
        ifFalse: 'No Scroll Button'));
    properties.add(FlagProperty('showBorder',
        value: showBorder, ifTrue: 'Show Border', ifFalse: 'No Border'));
    properties.add(DoubleProperty('spacing', spacing));
    super.debugFillProperties(properties);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MouseIndicatorStyle &&
        other.borderColor == borderColor &&
        other.backgroundColor == backgroundColor &&
        other.indicatorColor == indicatorColor &&
        other.borderWidth == borderWidth &&
        other.border == border &&
        other.scrollButtonWidth == scrollButtonWidth &&
        other.scrollButtonWidthFactor == scrollButtonWidthFactor &&
        other.buttonsHeightFactor == buttonsHeightFactor &&
        other.showScrollButton == showScrollButton &&
        other.showBorder == showBorder &&
        other.spacing == spacing;
  }

  @override
  int get hashCode => Object.hash(
        borderColor,
        backgroundColor,
        indicatorColor,
        borderWidth,
        border,
        scrollButtonWidth,
        scrollButtonWidthFactor,
        buttonsHeightFactor,
        showScrollButton,
        showBorder,
        spacing,
      );
}
