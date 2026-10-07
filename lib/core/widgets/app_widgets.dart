import 'package:flutter/material.dart';

import '../../app/constants.dart';
import '../../app/theme.dart';
import '../models.dart';

class ScreenBody extends StatelessWidget {
  const ScreenBody(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: padding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: child,
              ),
            ),
          ),
        ),
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
            if (action != null)
              TextButton(onPressed: onAction, child: Text(action!)),
          ],
        ),
      );
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    this.positive,
  });
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final bool? positive;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 174,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(label,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ),
                    Icon(icon,
                        size: 20, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${positive == null ? '' : positive! ? '▲ ' : '▼ '}$detail',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: positive == null
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : positive!
                            ? AppColors.success
                            : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.text, this.status, {super.key});
  final String text;
  final DataStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      DataStatus.healthy || DataStatus.completed => AppColors.success,
      DataStatus.warning || DataStatus.stale => AppColors.warning,
      DataStatus.critical => AppColors.error,
      DataStatus.pending => AppColors.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: .55),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.science_outlined, size: 18),
            SizedBox(width: 10),
            Expanded(
                child: Text(demoDisclaimer, style: TextStyle(fontSize: 11))),
          ],
        ),
      );
}

class Sparkline extends StatelessWidget {
  const Sparkline({super.key, this.height = 150});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
            painter: _SparklinePainter(Theme.of(context).colorScheme.primary)),
      );
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = color.withValues(alpha: .1)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * .78)
      ..cubicTo(size.width * .13, size.height * .60, size.width * .21,
          size.height * .72, size.width * .34, size.height * .48)
      ..cubicTo(size.width * .50, size.height * .27, size.width * .59,
          size.height * .58, size.width * .72, size.height * .30)
      ..cubicTo(size.width * .83, size.height * .10, size.width * .91,
          size.height * .35, size.width, size.height * .12);
    final area = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, fill);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.color != color;
}

Future<bool> confirmAction(BuildContext context,
    {required String title, required String message}) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Confirm simulation')),
          ],
        ),
      ) ??
      false;
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}
