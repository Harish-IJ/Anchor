import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

/// Small pill for showing/adding project to timer session
class ProjectPill extends StatelessWidget {
  final String? projectName;
  final VoidCallback? onTap;
  final bool isSuggested;
  final VoidCallback? onClear;

  const ProjectPill({
    super.key,
    this.projectName,
    this.onTap,
    this.isSuggested = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final hasProject = projectName != null && projectName!.isNotEmpty;

    return CustomPaint(
      painter: isSuggested ? _DashedBorderPainter(color: colors.primary) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSuggested
              ? colors.primary.withValues(alpha: 0.1)
              : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: isSuggested
              ? null // Border handled by painter
              : Border.all(
                  color: colors.textSecondary.withValues(alpha: 0.2),
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      // Use star for suggestions
                      isSuggested
                          ? Icons.auto_awesome_rounded
                          : (hasProject
                                ? Icons.folder_rounded
                                : Icons.add_rounded),
                      size: 14,
                      color: hasProject ? colors.primary : colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        hasProject ? projectName! : 'Add Project',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: hasProject
                              ? colors.textPrimary
                              : colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isSuggested && onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
      );

    // Draw dashed path
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double distance = 0.0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final extractPath = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
