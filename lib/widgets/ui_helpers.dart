import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

// Animated ambient background for auth screens
class KAmbientBackground extends StatefulWidget {
  const KAmbientBackground({super.key});

  @override
  State<KAmbientBackground> createState() => _KAmbientBackgroundState();
}

class _KAmbientBackgroundState extends State<KAmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: _GlowPainter(_controller.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final double t;
  const _GlowPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base background
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0D1117));

    // Green glow — top-left, breathes slowly
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.65),
          radius: 1.4 + t * 0.25,
          colors: [
            const Color(0xFF2D6A4F).withValues(alpha: 0.3 + t * 0.1),
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    // Terra cotta glow — bottom-right, inverse pulse
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.8, 0.75),
          radius: 0.9 + (1 - t) * 0.2,
          colors: [
            const Color(0xFFC1440E).withValues(alpha: 0.13 + (1 - t) * 0.05),
            Colors.transparent,
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.t != t;
}

// Theme colors
// Keep the overall background the same, but adjust surfaces and accents
// so the app has a distinct visual style.
const kBg = Color(0xFF0D1117); // unchanged scaffold background
const kSurface = Color(0xFF11151F); // slightly cooler, more contrasty cards
const kSurface2 = Color(0xFF1A2130); // secondary surface, a touch brighter
const kGreen = Color(0xFF1E8467); // deeper teal-green primary
const kGreenLight = Color(0xFF5ED1A7); // lighter mint accent
const kTerra = Color(0xFFCC5C3B); // warmer terra accent
const kGold = Color(0xFFE0B15C); // softer gold
const kCream = Color(0xFFF1E9DC); // lighter, warmer text on dark
const kMuted = Color(0xFF9A9690); // slightly brighter muted text

// Category color lookup
Color kCategoryColor(String category) {
  const colors = {
    'Hospital': Color(0xFFE05A28),
    'Police Station': Color(0xFF3A86FF),
    'Library': Color(0xFFD4A853),
    'Restaurant': Color(0xFFFF6B6B),
    'Café': Color(0xFFA0522D),
    'Park': Color(0xFF52B788),
    'Tourist Attraction': Color(0xFFBB86FC),
  };
  return colors[category] ?? const Color(0xFF8B8680);
}

// Category icon lookup
IconData kCategoryIcon(String category) {
  const icons = {
    'Hospital': Icons.local_hospital_rounded,
    'Police Station': Icons.local_police_rounded,
    'Library': Icons.menu_book_rounded,
    'Restaurant': Icons.restaurant_rounded,
    'Café': Icons.coffee_rounded,
    'Park': Icons.park_rounded,
    'Tourist Attraction': Icons.photo_camera_rounded,
  };
  return icons[category] ?? Icons.place_rounded;
}

// Gradient button
Widget kGradientButton(String label, VoidCallback? onPressed, {IconData? icon}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kGreen, kGreenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kGreen.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: icon != null
            ? Icon(icon, color: Colors.white, size: 18)
            : const SizedBox.shrink(),
        label: Text(
          label,
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    ),
  );
}

// Category icon badge
Widget kCategoryBadge(String category) {
  final color = kCategoryColor(category);
  final icon = kCategoryIcon(category);
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
    ),
    child: Icon(icon, color: color, size: 18),
  );
}

// Shimmer placeholder card
Widget kShimmerCard() => Shimmer.fromColors(
      baseColor: kSurface,
      highlightColor: kSurface2.withValues(alpha: 0.9),
      child: Container(
        height: 96,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
      ),
    );
