import 'package:flutter/material.dart';

import '../features/dashboard/view_models.dart';
import '../theme/agrisense_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'AgriSense',
      header: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AgriColors.line),
            ),
            child: Image.asset(
              'assets/agrisense-logo.jpg',
              fit: BoxFit.contain,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AgriSense',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: AgriColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'KEBUN ANDA',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AgriColors.green,
                    letterSpacing: 1.25,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class PageContainer extends StatelessWidget {
  const PageContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 18, 18, 32),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.description,
    this.action,
    this.semanticsHeader = true,
  });

  final String title;
  final String? description;
  final Widget? action;
  final bool semanticsHeader;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: semanticsHeader,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        if (action != null) ...[const SizedBox(width: 12), action!],
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.status,
    this.small = false,
  });

  final String label;
  final AgriStatus status;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final (foreground, background, icon) = switch (status) {
      AgriStatus.healthy => (
        AgriColors.green,
        AgriColors.softGreen,
        Icons.check_circle_rounded,
      ),
      AgriStatus.attention => (
        AgriColors.amber,
        AgriColors.softAmber,
        Icons.info_rounded,
      ),
      AgriStatus.info => (
        AgriColors.blue,
        AgriColors.softBlue,
        Icons.info_rounded,
      ),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 13 : 15, color: foreground),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: small ? 11 : 12,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.tint = AgriColors.green,
    this.background = AgriColors.softGreen,
    this.size = 42,
  });
  final IconData icon;
  final Color tint;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: size * .5, color: tint),
    );
  }
}

class InlineAction extends StatelessWidget {
  const InlineAction({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AgriColors.green,
        minimumSize: const Size(48, 44),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 3),
          const Icon(Icons.arrow_forward_rounded, size: 16),
        ],
      ),
    );
  }
}
