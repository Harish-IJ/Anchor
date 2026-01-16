import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../providers/projects_provider.dart';

/// Bottom sheet for selecting or creating a project
class ProjectPickerSheet extends StatefulWidget {
  final String? currentProjectId;
  final void Function(Project project) onSelect;
  final VoidCallback onClear;

  const ProjectPickerSheet({
    super.key,
    this.currentProjectId,
    required this.onSelect,
    required this.onClear,
  });

  @override
  State<ProjectPickerSheet> createState() => _ProjectPickerSheetState();
}

class _ProjectPickerSheetState extends State<ProjectPickerSheet> {
  bool _isCreating = false;
  bool _isEditing = false;
  Project? _editingProject;
  final _nameController = TextEditingController();
  Color _selectedColor = projectColors[0];
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _nameController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _startCreate() {
    setState(() {
      _isCreating = true;
      _isEditing = false;
      _editingProject = null;
      _nameController.clear();
      _selectedColor = projectColors[0];
    });
  }

  void _startEdit(Project project) {
    setState(() {
      _isCreating = false;
      _isEditing = true;
      _editingProject = project;
      _nameController.text = project.name;
      _selectedColor = project.color;
    });
  }

  void _cancelForm() {
    setState(() {
      _isCreating = false;
      _isEditing = false;
      _editingProject = null;
      _nameController.clear();
      _selectedColor = projectColors[0];
    });
  }

  Future<void> _saveProject() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final projectsProvider = context.read<ProjectsProvider>();

    if (_isEditing && _editingProject != null) {
      await projectsProvider.updateProject(
        _editingProject!.id,
        name,
        _selectedColor,
      );
    } else {
      await projectsProvider.addProject(name, _selectedColor);
      final newProject = projectsProvider.projects.first;
      widget.onSelect(newProject);
    }

    _cancelForm();
  }

  void _confirmDelete(Project project) {
    final colors = context.read<ThemeProvider>().colors;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Project?',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${project.name}"? This cannot be undone.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final projectsProvider = context.read<ProjectsProvider>();
              final currentProjectId = widget.currentProjectId;
              final onClear = widget.onClear;
              Navigator.pop(ctx);
              if (project.id == currentProjectId) {
                onClear();
              }
              await projectsProvider.deleteProject(project.id);
              // Reset to list view after deletion
              if (mounted) {
                setState(() {
                  _isEditing = false;
                  _editingProject = null;
                });
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final projectsProvider = context.watch<ProjectsProvider>();
    final projects = projectsProvider.projects;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Handle and Header
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Handle
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.textSecondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isCreating
                                ? 'New Project'
                                : _isEditing
                                ? 'Edit Project'
                                : 'Projects',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (!_isCreating && !_isEditing)
                            GestureDetector(
                              onTap: () {
                                if (projects.length >=
                                    ProjectsProvider.maxProjects) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Maximum of ${ProjectsProvider.maxProjects} projects allowed',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                _startCreate();
                              },
                              child: Opacity(
                                opacity:
                                    projects.length >=
                                        ProjectsProvider.maxProjects
                                    ? 0.5
                                    : 1.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_rounded,
                                        size: 18,
                                        color: colors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'New',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              if (_isCreating || _isEditing)
                SliverToBoxAdapter(child: _buildForm(theme, colors))
              else
                _buildProjectsList(theme, colors, projects),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm(ThemeData theme, dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name input
          TextField(
            controller: _nameController,
            autofocus: true,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Project name',
              hintStyle: TextStyle(color: colors.textSecondary),
              filled: true,
              fillColor: colors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Color label
          Text(
            'Color (for reports)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Color selector
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: projectColors.map((color) {
              final isSelected = _selectedColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colors.textPrimary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: colors.textSecondary.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Save' : 'Create',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          // Delete button (Only when editing)
          if (_isEditing && _editingProject != null) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => _confirmDelete(_editingProject!),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Delete Project'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  SliverList _buildProjectsList(
    ThemeData theme,
    dynamic colors,
    List<Project> projects,
  ) {
    // Sort projects: Selected first, then others
    final sortedProjects = List<Project>.from(projects);
    if (widget.currentProjectId != null) {
      sortedProjects.sort((a, b) {
        if (a.id == widget.currentProjectId) return -1;
        if (b.id == widget.currentProjectId) return 1;
        return 0;
      });
    }

    if (sortedProjects.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 64,
                    color: colors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No projects yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "New" to create your first project',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == sortedProjects.length) {
          if (widget.currentProjectId == null) return const SizedBox();
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: TextButton(
                onPressed: () {
                  widget.onClear();
                  Navigator.pop(context);
                },
                child: Text(
                  'Clear Selection',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            ),
          );
        }

        final project = sortedProjects[index];
        final isSelected = project.id == widget.currentProjectId;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: GestureDetector(
            onTap: () {
              if (isSelected) {
                widget.onClear();
              } else {
                widget.onSelect(project);
              }
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withValues(alpha: 0.1)
                    : colors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? colors.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Color dot
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: project.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  // Check mark if selected
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: colors.primary,
                      ),
                    ),
                  // Edit button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _startEdit(project),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 20,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }, childCount: sortedProjects.length + 1),
    );
  }
}

/// Show project picker as bottom sheet
Future<void> showProjectPicker({
  required BuildContext context,
  String? currentProjectId,
  required void Function(Project project) onSelect,
  required VoidCallback onClear,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ProjectPickerSheet(
        currentProjectId: currentProjectId,
        onSelect: onSelect,
        onClear: onClear,
      ),
    ),
  );
}
