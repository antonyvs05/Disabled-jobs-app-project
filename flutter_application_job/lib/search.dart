import 'package:flutter/material.dart';

enum _LocationType { remote, hybrid, onSite }

enum _EmploymentType { fullTime, partTime }

class _Job {
  final String title;
  final String company;
  final _LocationType locationType;
  final _EmploymentType employmentType;
  final bool accessible;
  final String salary;
  final IconData icon;
  final Color color;

  const _Job({
    required this.title,
    required this.company,
    required this.locationType,
    required this.employmentType,
    required this.accessible,
    required this.salary,
    required this.icon,
    required this.color,
  });
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _filters = [];

  final List<_Job> _allJobs = const [
    _Job(
      title: 'Software Engineer',
      company: 'Tech Innovators Inc.',
      locationType: _LocationType.remote,
      employmentType: _EmploymentType.fullTime,
      accessible: true,
      salary: '\$70,000 - \$90,000',
      icon: Icons.code,
      color: Color(0xFF3498DB),
    ),
    _Job(
      title: 'Data Analyst',
      company: 'Analytics Pro',
      locationType: _LocationType.hybrid,
      employmentType: _EmploymentType.fullTime,
      accessible: true,
      salary: '\$55,000 - \$70,000',
      icon: Icons.analytics,
      color: Color(0xFF27AE60),
    ),
    _Job(
      title: 'UX Designer',
      company: 'Design Masters',
      locationType: _LocationType.onSite,
      employmentType: _EmploymentType.fullTime,
      accessible: false,
      salary: '\$60,000 - \$75,000',
      icon: Icons.design_services,
      color: Color(0xFF9B59B6),
    ),
    _Job(
      title: 'Customer Support Rep',
      company: 'Service Plus Co.',
      locationType: _LocationType.hybrid,
      employmentType: _EmploymentType.partTime,
      accessible: true,
      salary: '\$35,000 - \$45,000',
      icon: Icons.support_agent,
      color: Color(0xFF2ECC71),
    ),
    _Job(
      title: 'QA Tester',
      company: 'Quality Labs',
      locationType: _LocationType.remote,
      employmentType: _EmploymentType.partTime,
      accessible: true,
      salary: '\$40,000 - \$55,000',
      icon: Icons.bug_report,
      color: Color(0xFFE67E22),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _filteredJobs();
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
                  Color(0xFF2C3E50),
                  Color(0xFF34495E),
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
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
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

          // Search Results
          Expanded(
            child: _searchQuery.isEmpty && _filters.isEmpty
                ? _buildEmptyState()
                : _buildSearchResults(filteredJobs),
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
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF3498DB)),
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
        selectedColor: const Color(0xFF3498DB),
        backgroundColor: const Color(0xFFE8F4F8),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF2C3E50),
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

  Widget _buildSearchResults(List<_Job> jobs) {
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
                _buildJobCard(
                  job.title,
                  job.company,
                  _formatLocation(job.locationType),
                  job.salary,
                  job.icon,
                  job.color,
                ),
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

  List<_Job> _filteredJobs() {
    final query = _searchQuery.trim();
    return _allJobs.where((job) {
      final matchesQuery = _matchesQuery(job, query);
      final matchesFilters = _matchesFilters(job);
      return matchesQuery && matchesFilters;
    }).toList();
  }

  bool _matchesFilters(_Job job) {
    for (final filter in _filters) {
      switch (filter) {
        case 'Remote':
          if (job.locationType != _LocationType.remote) return false;
          break;
        case 'Hybrid':
          if (job.locationType != _LocationType.hybrid) return false;
          break;
        case 'Full-time':
          if (job.employmentType != _EmploymentType.fullTime) return false;
          break;
        case 'Part-time':
          if (job.employmentType != _EmploymentType.partTime) return false;
          break;
        case 'Accessible':
          if (!job.accessible) return false;
          break;
      }
    }
    return true;
  }

  bool _matchesQuery(_Job job, String query) {
    if (query.isEmpty) return true;
    final haystack = '${job.title} ${job.company} ${_formatLocation(job.locationType)}'
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

  String _formatLocation(_LocationType type) {
    switch (type) {
      case _LocationType.remote:
        return 'Remote';
      case _LocationType.hybrid:
        return 'Hybrid';
      case _LocationType.onSite:
        return 'On-site';
    }
  }

  Widget _buildJobCard(
    String title,
    String company,
    String location,
    String salary,
    IconData icon,
    Color color,
  ) {
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
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      Text(
                        salary,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.bookmark_outline,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
