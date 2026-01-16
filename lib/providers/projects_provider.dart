import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Project model
class Project {
  final String id;
  final String name;
  final Color color;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    // Manual ARGB calculation for SDK compatibility (toARGB32 requires Flutter 3.29+)
    'color':
        (color.alpha << 24) |
        (color.red << 16) |
        (color.green << 8) |
        color.blue,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as String,
    name: json['name'] as String,
    color: Color(json['color'] as int),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

/// Available project colors
const List<Color> projectColors = [
  Color(0xFFFF6712), // Orange
  Color(0xFF0891B2), // Cyan
  Color(0xFF059669), // Emerald
  Color(0xFF7C3AED), // Violet
  Color(0xFFDC2626), // Red
  Color(0xFF2563EB), // Blue
  Color(0xFFDB2777), // Pink
  Color(0xFF84CC16), // Lime
];

/// Provider for managing saved projects
class ProjectsProvider extends ChangeNotifier {
  static const String _projectsKey = 'saved_projects';
  static const int maxProjects = 15;

  List<Project> _projects = [];

  List<Project> get projects => List.unmodifiable(_projects);

  /// Initialize from stored preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_projectsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _projects = jsonList.map((j) => Project.fromJson(j)).toList();
      notifyListeners();
    }
  }

  /// Save projects to preferences
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_projects.map((p) => p.toJson()).toList());
    await prefs.setString(_projectsKey, jsonString);
  }

  /// Add a new project
  Future<void> addProject(String name, Color color) async {
    if (_projects.length >= maxProjects) {
      throw Exception('Maximum of $maxProjects projects allowed');
    }

    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
    );
    _projects.insert(0, project);
    notifyListeners();
    await _save();
  }

  /// Delete a project
  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    notifyListeners();
    await _save();
  }

  /// Update an existing project
  Future<void> updateProject(String id, String name, Color color) async {
    final index = _projects.indexWhere((p) => p.id == id);
    if (index != -1) {
      final oldProject = _projects[index];
      _projects[index] = Project(
        id: oldProject.id,
        name: name,
        color: color,
        createdAt: oldProject.createdAt,
      );
      notifyListeners();
      await _save();
    }
  }

  /// Get project by ID
  Project? getProject(String? id) {
    if (id == null) return null;
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Generate test projects (DEBUG ONLY)
  Future<void> generateTestProjects() async {
    final testProjects = [
      ('Work', projectColors[0]), // Orange
      ('Learning', projectColors[1]), // Cyan
      ('Side Project', projectColors[2]), // Emerald
      ('Reading', projectColors[3]), // Violet
      ('Exercise', projectColors[4]), // Red
    ];

    for (final (name, color) in testProjects) {
      // Check if project already exists
      final exists = _projects.any((p) => p.name == name);
      if (!exists) {
        await addProject(name, color);
      }
    }
  }

  /// Get all project IDs
  List<String> get projectIds => _projects.map((p) => p.id).toList();
}
