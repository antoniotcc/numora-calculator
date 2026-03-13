import 'package:flutter/material.dart';
import 'package:numora/components/core/text_style.dart';
import 'package:numora/components/core/text_style.dart' as TextStyles;

class SizedButton extends StatelessWidget {
  final double height;
  final int elevationButton;
  final Color colorButton;
  final String texto;
  final VoidCallback onPressed;
  final BorderRadius borderRadius;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  const SizedButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.colorButton = const Color(0xFF3A3D66),
    this.elevationButton = 6,
    this.height = 65,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });
  Widget build(BuildContext context) {
  const double extraTap = 10; // área extra para presionar

  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onLongPressStart: (_) => onLongPressStart?.call(),
    onLongPressEnd: (_) => onLongPressEnd?.call(),
    child: SizedBox(
      height: height + extraTap, // área táctil más grande
      child: Center(
        child: SizedBox(
          height: height, // tamaño visual real del botón
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              elevation: elevationButton.toDouble(),
              backgroundColor: colorButton,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(texto, style: TextStyles.bodyButton),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
