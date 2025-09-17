import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/skill.dart';
import '../models/skill_category.dart';
import '../models/skill_status.dart';
import '../services/storage_service.dart';
import '../widgets/skill_card.dart';
import '../widgets/category_header.dart';
import 'skill_details_screen.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  List<Skill> _skills = [];
  SkillCategory? _selectedCategory;
  SkillStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  void _loadSkills() {
    setState(() {
      _skills = StorageService.getAllSkills();
    });
  }

  List<Skill> get _filteredSkills {
    var filtered = _skills;

    if (_selectedCategory != null) {
      filtered =
          filtered.where((s) => s.category == _selectedCategory).toList();
    }

    if (_selectedStatus != null) {
      filtered = filtered.where((s) => s.status == _selectedStatus).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (s) =>
                    s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    s.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    s.tags.any(
                      (tag) => tag.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    ),
              )
              .toList();
    }

    return filtered;
  }

  Map<SkillCategory, List<Skill>> get _groupedSkills {
    final grouped = <SkillCategory, List<Skill>>{};

    for (final skill in _filteredSkills) {
      if (!grouped.containsKey(skill.category)) {
        grouped[skill.category] = [];
      }
      grouped[skill.category]!.add(skill);
    }

    // Sort skills within each category by priority and name
    for (final category in grouped.keys) {
      grouped[category]!.sort((a, b) {
        if (a.priority != b.priority) {
          return b.priority.compareTo(a.priority);
        }
        return a.name.compareTo(b.name);
      });
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.darkBackground, AppColors.darkSurface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Filters
              _buildFilters(),

              // Skills List
              Expanded(child: _buildSkillsList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSkillDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Skills',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    if (_selectedCategory == null &&
        _selectedStatus == null &&
        _searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedCategory != null)
            _buildFilterChip(
              label: _selectedCategory!.displayName,
              onDeleted: () => setState(() => _selectedCategory = null),
            ),
          if (_selectedStatus != null)
            _buildFilterChip(
              label: _selectedStatus!.displayName,
              onDeleted: () => setState(() => _selectedStatus = null),
            ),
          if (_searchQuery.isNotEmpty)
            _buildFilterChip(
              label: 'Search: $_searchQuery',
              onDeleted: () => setState(() => _searchQuery = ''),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      backgroundColor: AppColors.primary.withOpacity(0.2),
      labelStyle: GoogleFonts.inter(color: Colors.white, fontSize: 12),
    );
  }

  Widget _buildSkillsList() {
    final groupedSkills = _groupedSkills;

    if (groupedSkills.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedSkills.length,
      itemBuilder: (context, index) {
        final category = groupedSkills.keys.elementAt(index);
        final skills = groupedSkills[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryHeader(
              category: category,
              skillCount: skills.length,
              completedCount: skills.where((s) => s.isCompleted).length,
            ),
            const SizedBox(height: 12),
            ...skills.map(
              (skill) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SkillCard(
                  skill: skill,
                  onTap: () => _navigateToSkillDetails(skill),
                  onStatusChanged:
                      (newStatus) => _updateSkillStatus(skill, newStatus),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No skills found',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add a new skill',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Search Skills', style: GoogleFonts.poppins()),
            content: TextField(
              decoration: const InputDecoration(
                hintText: 'Enter skill name, description, or tag...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Filter Skills', style: GoogleFonts.poppins()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Filter
                DropdownButtonFormField<SkillCategory>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  value: _selectedCategory,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...SkillCategory.values.map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text('${category.icon} ${category.displayName}'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Status Filter
                DropdownButtonFormField<SkillStatus>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  value: _selectedStatus,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...SkillStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedStatus = null;
                    _searchQuery = '';
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }

  void _showAddSkillDialog() {
    // TODO: Implement add skill dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add skill feature coming soon!')),
    );
  }

  void _navigateToSkillDetails(Skill skill) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SkillDetailsScreen(skill: skill)),
    );
  }

  void _updateSkillStatus(Skill skill, SkillStatus newStatus) {
    final updatedSkill = skill.copyWith(
      status: newStatus,
      completedAt: newStatus == SkillStatus.completed ? DateTime.now() : null,
    );

    StorageService.updateSkill(updatedSkill);
    _loadSkills();
  }
}
