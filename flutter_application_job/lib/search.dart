import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'services/firebase_service.dart';
import 'models/job_model.dart';
import 'theme/app_colors.dart';
import 'widgets/save_job_button.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = '';
  List<String> _filters = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Jobs',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find your perfect opportunity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Job title, keywords, or company...',
                        prefixIcon: Icon(Icons.search, color: AppColors.secondary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Remote', Icons.home_outlined),
                  _buildFilterChip('Full-time', Icons.schedule),
                  _buildFilterChip('Part-time', Icons.access_time),
                  _buildFilterChip('Hybrid', Icons.location_on_outlined),
                  _buildFilterChip('Accessible', Icons.accessible),
                ],
              ),
            ),
          ),

          // Search Results from Firestore
          Expanded(
            child: StreamBuilder<List<Job>>(
              stream: _firebaseService.getAllJobs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allJobs = snapshot.data ?? [];
                final filteredJobs = _filterJobs(allJobs);

                if (_searchQuery.isEmpty && _filters.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildSearchResults(filteredJobs);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _filters.contains(label);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.secondary),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _filters.add(label);
            } else {
              _filters.remove(label);
            }
          });
        },
        selectedColor: AppColors.secondary,
        backgroundColor: AppColors.backgroundCard,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Start Your Search',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter keywords or apply filters to find jobs',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Job> jobs) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Search Results (${jobs.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        if (jobs.isEmpty)
          _buildNoResults()
        else
          ...jobs.expand((job) => [
                _buildJobCard(job),
                const SizedBox(height: 12),
              ]),
      ],
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No matches found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try different keywords or remove filters',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  List<Job> _filterJobs(List<Job> jobs) {
    final query = _searchQuery.trim();
    
    // Apply query and filter matching
    return jobs.where((job) {
      final matchesQuery = _matchesQuery(job, query);
      final matchesFilters = _matchesFilters(job);
      return matchesQuery && matchesFilters;
    }).toList();
  }

  bool _matchesFilters(Job job) {
    for (final filter in _filters) {
      switch (filter) {
        case 'Remote':
          if (!job.remote) return false;
          break;
        case 'Hybrid':
          // For now, we'll consider jobs without explicit remote flag as hybrid potential
          break;
        case 'Full-time':
          if (job.flexibleHours == true) return false;
          break;
        case 'Part-time':
          if (job.flexibleHours != true) return false;
          break;
        case 'Accessible':
          if (job.accessibilityFeatures.isEmpty) return false;
          break;
      }
    }
    return true;
  }

  bool _matchesQuery(Job job, String query) {
    if (query.isEmpty) return true;
    final haystack = '${job.title} ${job.company} ${job.location ?? ''}'
        .toLowerCase();
    final normalized = query.toLowerCase().trim();

    if (haystack.contains(normalized)) return true;

    final tokens = normalized.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    if (tokens.isEmpty) return true;
    final allTokensMatch = tokens.every((token) => haystack.contains(token));
    if (allTokensMatch) return true;

    return _isSubsequenceMatch(normalized.replaceAll(' ', ''), haystack);
  }

  bool _isSubsequenceMatch(String needle, String haystack) {
    if (needle.isEmpty) return true;
    var i = 0;
    for (var j = 0; j < haystack.length && i < needle.length; j++) {
      if (haystack[j] == needle[i]) {
        i++;
      }
    }
    return i == needle.length;
  }

  Widget _buildJobCard(Job job) {
    final icon = job.remote ? Icons.home_outlined : Icons.business_outlined;
    final color = job.remote ? AppColors.secondary : AppColors.accent;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.company ?? 'Company',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              job.location ?? (job.remote ? 'Remote' : 'On-site'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          Flexible(
                            child: Text(
                              job.salary ?? 'Negotiable',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildSaveButton(job),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(Job job) {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return Icon(Icons.bookmark_outline, color: Colors.grey.shade400);
    }

    return SaveJobButton(userId: currentUser.uid, jobId: job.id);
  }
}


