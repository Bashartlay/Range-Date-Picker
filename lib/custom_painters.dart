import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayRangePainter extends CustomPainter {
  final bool isStart;
  final bool isEnd;
  final bool isMiddle;
  final Color mainColor;
  final Color secondaryColor;

  DayRangePainter(
      {required this.isStart, required this.isEnd, required this.isMiddle, required this.mainColor, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
    ..color = mainColor
    ..style = PaintingStyle.fill;

    final paint1 = Paint()
    ..color = secondaryColor
    ..style = PaintingStyle.fill;

    if (isStart) {
      final pathStart = Path();
      pathStart.moveTo(
          size.width, size.height); 
      pathStart.lineTo(size.width, 0); 
      pathStart.lineTo(0, size.height); 
      pathStart.close();
      canvas.drawPath(pathStart, paint);

      final pathEnd = Path();
      pathEnd.moveTo(0, 0); 
      pathEnd.lineTo(size.width, 0); 
      pathEnd.lineTo(0, size.height); 
      pathEnd.close();
      canvas.drawPath(pathEnd, paint1);
    } else if (isEnd) {
      final pathEnd = Path();
      pathEnd.moveTo(0, 0); 
      pathEnd.lineTo(size.width, 0); 
      pathEnd.lineTo(0, size.height); 
      pathEnd.close();
      canvas.drawPath(pathEnd, paint);

      final pathStart = Path();
      pathStart.moveTo(
          size.width, size.height); 
      pathStart.lineTo(size.width, 0); 
      pathStart.lineTo(0, size.height); 
      pathStart.close();
      canvas.drawPath(pathStart, paint1);
    } else if (isMiddle) {
      final pathMiddle = Path();
      pathMiddle.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(pathMiddle, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class StartDayPainter extends CustomPainter {
  final Color color;

  StartDayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, size.height); 
    path.lineTo(size.width, 0); 
    path.lineTo(0, size.height); 
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class EndDayPainter extends CustomPainter {
  final Color color;

  EndDayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0); 
    path.lineTo(size.width, 0); 
    path.lineTo(0, size.height); 
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
