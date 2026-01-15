import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

/// Small pill for showing/adding project to timer session
class ProjectPill extends StatelessWidget {
  final String? projectName;
  final VoidCallback? onTap;

  const ProjectPill({super.key, this.projectName, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final hasProject = projectName != null && projectName!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: hasProject ? colors.primaryLight : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasProject
                ? colors.primary.withOpacity(0.3)
                : colors.textSecondary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasProject ? Icons.folder_rounded : Icons.add_rounded,
              size: 18,
              color: hasProject ? colors.primary : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              hasProject ? projectName! : 'Add Project',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hasProject ? colors.primary : colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
