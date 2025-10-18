import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_card.dart';

/// Health tips screen displaying offline health education content
/// Shows categorized health tips with expandable details
class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  List<dynamic> _tips = [];
  List<dynamic> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHealthTips();
  }

  /// Load health tips from local JSON file
  Future<void> _loadHealthTips() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/tips.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      setState(() {
        _tips = jsonData['tips'] ?? [];
        _categories = jsonData['categories'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load health tips: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Health Tips',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildCategoryFilter(),
                    Expanded(child: _buildTipsList()),
                  ],
                ),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget() {
    return Center(
      child: CustomCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHealthTips,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build category filter
  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All', _selectedCategory == 'All'),
                const SizedBox(width: 8),
                ..._categories.map((category) {
                  final categoryName = category['name'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCategoryChip(
                      categoryName,
                      _selectedCategory == categoryName,
                      color: Color(int.parse(category['color'].substring(1), radix: 16) + 0xFF000000),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build category chip
  Widget _buildCategoryChip(String name, bool isSelected, {Color? color}) {
    return FilterChip(
      label: Text(name),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? name : 'All';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: color ?? AppColors.primaryRed.withValues(alpha: 0.2),
      checkmarkColor: color ?? AppColors.primaryRed,
      labelStyle: TextStyle(
        color: isSelected ? (color ?? AppColors.primaryRed) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Build tips list
  Widget _buildTipsList() {
    final filteredTips = _selectedCategory == 'All'
        ? _tips
        : _tips.where((tip) => tip['category'] == _selectedCategory).toList();

    if (filteredTips.isEmpty) {
      return Center(
        child: CustomCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No tips available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting a different category',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.padding),
      itemCount: filteredTips.length,
      itemBuilder: (context, index) {
        final tip = filteredTips[index];
        return _buildTipCard(tip);
      },
    );
  }

  /// Build tip card
  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: ExpansionTile(
          title: Text(
            tip['title'] ?? 'Health Tip',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(tip['category']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tip['category'] ?? 'General',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(tip['category']),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (tip['priority'] == 'high')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'HIGH PRIORITY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tip['content'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detailed Information',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tip['detailedContent'] ?? tip['content'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  if (tip['targetAudience'] != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Target: ${_formatTargetAudience(tip['targetAudience'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get category color
  Color _getCategoryColor(String? category) {
    if (category == null) return AppColors.primaryBlue;
    
    final categoryData = _categories.firstWhere(
      (cat) => cat['name'] == category,
      orElse: () => {'color': '#89CFF0'},
    );
    
    try {
      return Color(int.parse(categoryData['color'].substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return AppColors.primaryBlue;
    }
  }

  /// Format target audience
  String _formatTargetAudience(String? audience) {
    if (audience == null) return 'General';
    
    switch (audience) {
      case 'pregnant_women':
        return 'Pregnant Women';
      case 'new_mothers':
        return 'New Mothers';
      case 'children':
        return 'Children';
      case 'adults':
        return 'Adults';
      case 'all':
        return 'Everyone';
      default:
        return audience.replaceAll('_', ' ').split(' ').map((word) => 
          word.isEmpty ? word : word[0].toUpperCase() + word.substring(1)
        ).join(' ');
    }
  }
}
