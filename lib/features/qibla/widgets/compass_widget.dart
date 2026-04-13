import 'dart:math';

import 'package:flutter/material.dart';
import 'package:khushu/core/theme/app_colors.dart';

class CompassWidget extends StatelessWidget {
  final double qiblaDirection;  // screen-relative angle (already adjusted)
  final double compassHeading;  // raw compass heading
  final double qiblaOffset;    // fixed bearing from north (for display)
  final bool isAligned;

  const CompassWidget({
    super.key,
    required this.qiblaDirection,
    required this.compassHeading,
    required this.qiblaOffset,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    final normalizedBearing = qiblaOffset % 360;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Rotating compass ring (face + ticks + cardinals) ──────────
              Transform.rotate(
                angle: -compassHeading * pi / 180,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Compass face, outer/inner rings and tick marks
                      CustomPaint(
                        size: const Size(300, 300),
                        painter: _CompassFacePainter(isDark: isDark),
                      ),

                      // N — top  (sage/deepGreen, brighter)
                      Positioned(
                        top: 14,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'N',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.sage
                                  : AppColors.deepGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),

                      // S — bottom
                      Positioned(
                        bottom: 14,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'S',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ),
                      ),

                      // W — left
                      Positioned(
                        left: 14,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            'W',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ),
                      ),

                      // E — right
                      Positioned(
                        right: 14,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            'E',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ),
                      ),

                      // North needle (rotates with ring — always points magnetic north)
                      CustomPaint(
                        size: const Size(300, 300),
                        painter: _NorthNeedlePainter(isDark: isDark),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Qibla arrow (qiblaDirection is already screen-relative) ──
              Transform.rotate(
                angle: qiblaDirection * pi / 180,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: _QiblaArrowPainter(isDark: isDark),
                ),
              ),

              // ── Ka'bah cube at center (rotates with Qibla arrow) ──────────
              Transform.rotate(
                angle: qiblaDirection * pi / 180,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: _KaabahCubePainter(isDark: isDark),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Bearing readout
        Text(
          '${normalizedBearing.toStringAsFixed(1)}°',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Qibla Direction',
          style: TextStyle(
            fontSize: 14,
            color: secondaryColor,
          ),
        ),

        const SizedBox(height: 20),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 12, height: 12, color: const Color(0xFFC75050)),
            const SizedBox(width: 6),
            Text(
              'North',
              style: TextStyle(fontSize: 12, color: secondaryColor),
            ),
            const SizedBox(width: 20),
            Container(
              width: 12,
              height: 12,
              color: isDark ? AppColors.sage : AppColors.deepGreen,
            ),
            const SizedBox(width: 6),
            Text(
              'Qibla',
              style: TextStyle(fontSize: 12, color: secondaryColor),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Compass face: background, outer ring, inner ring, tick marks ─────────────

class _CompassFacePainter extends CustomPainter {
  final bool isDark;
  const _CompassFacePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 2;
    final innerRingRadius = outerRadius - 18;

    // Background fill
    final bgPaint = Paint()
      ..color =
          isDark ? const Color(0xFF2A2A27) : const Color(0xFFEDE8DF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, bgPaint);

    // Outer ring stroke
    final outerRingPaint = Paint()
      ..color = isDark
          ? const Color(0xFFA8C5A0).withOpacity(0.25)
          : const Color(0xFF3D5A3A).withOpacity(0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, outerRadius, outerRingPaint);

    // Inner ring stroke
    final innerRingPaint = Paint()
      ..color = isDark
          ? const Color(0xFFA8C5A0).withOpacity(0.12)
          : const Color(0xFF3D5A3A).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, innerRingRadius, innerRingPaint);

    // Tick marks every 30°
    for (int deg = 0; deg < 360; deg += 30) {
      final isMajor = deg % 90 == 0;
      final tickLength = isMajor ? 14.0 : 8.0;
      final tickWidth = isMajor ? 1.5 : 1.0;
      final tickOpacity = isMajor ? 0.55 : 0.25;

      final tickColor = isDark
          ? const Color(0xFFA8C5A0).withOpacity(tickOpacity)
          : const Color(0xFF3D5A3A).withOpacity(tickOpacity);

      final tickPaint = Paint()
        ..color = tickColor
        ..strokeWidth = tickWidth
        ..strokeCap = StrokeCap.round;

      final rad = deg * pi / 180;
      final outerX = center.dx + outerRadius * sin(rad);
      final outerY = center.dy - outerRadius * cos(rad);
      final innerX = center.dx + (outerRadius - tickLength) * sin(rad);
      final innerY = center.dy - (outerRadius - tickLength) * cos(rad);

      canvas.drawLine(Offset(outerX, outerY), Offset(innerX, innerY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(_CompassFacePainter old) => old.isDark != isDark;
}

// ─── North needle: thin diamond, red north half, gray south half ──────────────

class _NorthNeedlePainter extends CustomPainter {
  final bool isDark;
  const _NorthNeedlePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 2;
    final needleHalfLength = outerRadius - 22; // stays inside ticks
    const halfWidth = 5.0;

    // North (red) half — points toward top (north)
    final northPath = Path()
      ..moveTo(center.dx, center.dy - needleHalfLength) // tip at north
      ..lineTo(center.dx - halfWidth, center.dy)
      ..lineTo(center.dx + halfWidth, center.dy)
      ..close();

    canvas.drawPath(
      northPath,
      Paint()..color = const Color(0xFFC75050),
    );

    // South half — dim gray
    final southPath = Path()
      ..moveTo(center.dx, center.dy + needleHalfLength) // tail at south
      ..lineTo(center.dx - halfWidth, center.dy)
      ..lineTo(center.dx + halfWidth, center.dy)
      ..close();

    canvas.drawPath(
      southPath,
      Paint()
        ..color = isDark
            ? const Color(0xFF6B6B62).withOpacity(0.5)
            : const Color(0xFF8A8275).withOpacity(0.45),
    );

    // Center cap
    canvas.drawCircle(
      center,
      4,
      Paint()..color = const Color(0xFFC75050),
    );
  }

  @override
  bool shouldRepaint(_NorthNeedlePainter old) => old.isDark != isDark;
}

// ─── Qibla arrow: larger sage green arrow ─────────────────────────────────────

class _QiblaArrowPainter extends CustomPainter {
  final bool isDark;
  const _QiblaArrowPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 2;
    // Arrow tip reaches just inside the inner ring area
    final tipY = -(outerRadius - 26);
    // Tail is shorter on the opposite side
    const tailY = 38.0;
    const halfWidth = 7.0;
    const headHalfWidth = 13.0;
    const headLength = 22.0;

    final arrowColor =
        isDark ? const Color(0xFFA8C5A0) : const Color(0xFF3D5A3A);
    final tailColor = arrowColor.withOpacity(0.35);

    // Arrow head (pointed tip)
    final headPath = Path()
      ..moveTo(0, tipY) // tip
      ..lineTo(-headHalfWidth, tipY + headLength)
      ..lineTo(0, tipY + headLength - 6)
      ..lineTo(headHalfWidth, tipY + headLength)
      ..close();

    // Arrow shaft
    final shaftPath = Path()
      ..moveTo(-halfWidth, tipY + headLength - 2)
      ..lineTo(-halfWidth, 0)
      ..lineTo(halfWidth, 0)
      ..lineTo(halfWidth, tipY + headLength - 2)
      ..close();

    // Tail (dim)
    final tailPath = Path()
      ..moveTo(-halfWidth, 0)
      ..lineTo(-halfWidth, tailY)
      ..lineTo(0, tailY + 10)
      ..lineTo(halfWidth, tailY)
      ..lineTo(halfWidth, 0)
      ..close();

    // Translate to center
    canvas.save();
    canvas.translate(center.dx, center.dy);

    canvas.drawPath(shaftPath, Paint()..color = arrowColor);
    canvas.drawPath(headPath, Paint()..color = arrowColor);
    canvas.drawPath(tailPath, Paint()..color = tailColor);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_QiblaArrowPainter old) => old.isDark != isDark;
}

// ─── Ka'bah isometric cube at center ─────────────────────────────────────────

class _KaabahCubePainter extends CustomPainter {
  final bool isDark;
  const _KaabahCubePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Cube dimensions (isometric-ish)
    const w = 18.0; // half-width of top face
    const h = 10.0; // top face depth (isometric perspective)
    const wallH = 16.0; // height of side walls

    // Slightly above center so it sits at the pivot of the arrow
    final cx = center.dx;
    final cy = center.dy - 4;

    // Top face vertices (diamond/parallelogram)
    final topLeft = Offset(cx - w, cy);
    final topTop = Offset(cx, cy - h);
    final topRight = Offset(cx + w, cy);
    final topBottom = Offset(cx, cy + h);

    // Bottom of left & right walls
    final leftBottom = Offset(cx - w, cy + wallH);
    final midBottom = Offset(cx, cy + h + wallH);
    final rightBottom = Offset(cx + w, cy + wallH);

    // Top face
    final topPaint = Paint()
      ..color = isDark
          ? const Color(0xFF6B8C66)
          : const Color(0xFF7DA078);
    final topPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topTop.dx, topTop.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(topBottom.dx, topBottom.dy)
      ..close();
    canvas.drawPath(topPath, topPaint);

    // Left wall
    final leftPaint = Paint()..color = const Color(0xFF3D5A3A);
    final leftPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topBottom.dx, topBottom.dy)
      ..lineTo(midBottom.dx, midBottom.dy)
      ..lineTo(leftBottom.dx, leftBottom.dy)
      ..close();
    canvas.drawPath(leftPath, leftPaint);

    // Right wall
    final rightPaint = Paint()
      ..color = isDark
          ? const Color(0xFF2A4228)
          : const Color(0xFF2E4A2C);
    final rightPath = Path()
      ..moveTo(topRight.dx, topRight.dy)
      ..lineTo(topBottom.dx, topBottom.dy)
      ..lineTo(midBottom.dx, midBottom.dy)
      ..lineTo(rightBottom.dx, rightBottom.dy)
      ..close();
    canvas.drawPath(rightPath, rightPaint);

    // Hizam (gold band) — left wall portion
    const bandTopRatio = 0.45;
    const bandBotRatio = 0.65;

    final hizamLeftPaint = Paint()..color = const Color(0xFFD4C9A8);
    final hizamLeftPath = Path()
      ..moveTo(
        topLeft.dx,
        topLeft.dy + (leftBottom.dy - topLeft.dy) * bandTopRatio,
      )
      ..lineTo(
        topBottom.dx,
        topBottom.dy + (midBottom.dy - topBottom.dy) * bandTopRatio,
      )
      ..lineTo(
        topBottom.dx,
        topBottom.dy + (midBottom.dy - topBottom.dy) * bandBotRatio,
      )
      ..lineTo(
        topLeft.dx,
        topLeft.dy + (leftBottom.dy - topLeft.dy) * bandBotRatio,
      )
      ..close();
    canvas.drawPath(hizamLeftPath, hizamLeftPaint);

    // Hizam — right wall portion
    final hizamRightPaint = Paint()..color = const Color(0xFFC4B998);
    final hizamRightPath = Path()
      ..moveTo(
        topRight.dx,
        topRight.dy + (rightBottom.dy - topRight.dy) * bandTopRatio,
      )
      ..lineTo(
        topBottom.dx,
        topBottom.dy + (midBottom.dy - topBottom.dy) * bandTopRatio,
      )
      ..lineTo(
        topBottom.dx,
        topBottom.dy + (midBottom.dy - topBottom.dy) * bandBotRatio,
      )
      ..lineTo(
        topRight.dx,
        topRight.dy + (rightBottom.dy - topRight.dy) * bandBotRatio,
      )
      ..close();
    canvas.drawPath(hizamRightPath, hizamRightPaint);

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(topPath, outlinePaint);
    canvas.drawPath(leftPath, outlinePaint);
    canvas.drawPath(rightPath, outlinePaint);
  }

  @override
  bool shouldRepaint(_KaabahCubePainter old) => old.isDark != isDark;
}
