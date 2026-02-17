import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'services/firebase_service.dart';
import 'models/job_model.dart';
import 'models/user_model.dart' show User;
import 'profile.dart';
import 'search.dart';
import 'saved.dart';
import 'job_details.dart';
import 'theme/app_colors.dart';
import 'widgets/save_job_button.dart';
import 'widgets/profile_setup_checklist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Access Work',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: _currentIndex == 3 ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const SearchPage(),
          const SavedPage(),
          const ProfilePage(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: () {
          _showMeetingOptions();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.search,
                label: 'Search',
              ),
              const SizedBox(width: 48),
              _buildNavItem(
                index: 2,
                icon: Icons.bookmark_outline,
                label: 'Saved',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.secondary : Colors.grey.shade600;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMeetingOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.group_add, color: AppColors.secondary),
                  title: const Text('Join a meeting'),
                  subtitle: const Text('Enter a session code to join'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.video_call, color: AppColors.secondary),
                  title: const Text('Create a meeting'),
                  subtitle: const Text('Start a new session'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        // Welcome Section
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover inclusive job opportunities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Setup Checklist
                FutureBuilder<User?>(
                  future: FirebaseService().getUser(auth.FirebaseAuth.instance.currentUser?.uid ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final user = snapshot.data!;
                      final checklist = _getProfileChecklist(user);
                      final isComplete = checklist.values.every((v) => v);
                      
                      // Only show if incomplete
                      if (!isComplete) {
                        return ProfileSetupChecklist(user: user);
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 24),

                // Categories Section
                const Text(
                  'Job Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryCard('Technology', Icons.computer, Colors.blue),
                      _buildCategoryCard('Healthcare', Icons.local_hospital, Colors.red),
                      _buildCategoryCard('Education', Icons.school, Colors.green),
                      _buildCategoryCard('Business', Icons.business, Colors.orange),
                      _buildCategoryCard('Arts', Icons.palette, Colors.purple),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Featured Jobs Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Jobs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // View all jobs
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Job Cards from Database
                StreamBuilder<List<Job>>(
                  stream: FirebaseService().getAllJobs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final jobs = snapshot.data ?? [];
                    final featuredJobs = jobs.take(3).toList();

                    if (featuredJobs.isEmpty) {
                      return Center(
                        child: Text(
                          'No jobs available',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      );
                    }

                    return Column(
                      children: featuredJobs.expand((job) {
                        final icon = job.remote ? Icons.home_outlined : Icons.business_outlined;
                        final color = job.remote ? Colors.blue : Colors.green;
                        
                        return [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailsPage(job: job),
                                ),
                              );
                            },
                            child: _buildJobCard(
                              job.id,
                              job.title,
                              job.company ?? 'Company',
                              job.location ?? (job.remote ? 'Remote' : 'On-site'),
                              job.salary ?? 'Negotiable',
                              icon,
                              color,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ];
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    String jobId,
    String title,
    String company,
    String location,
    String salary,
    IconData icon,
    Color color,
  ) {
    // Create a simple Job object for saving functionality
    // We'll use the jobId as a pseudo-ID for home page featured jobs
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
                      fontWeight: FontWeight.bold,
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
                              location,
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
                              salary,
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
            _buildHomePageSaveButton(jobId),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePageSaveButton(String jobId) {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return Icon(Icons.bookmark_outline, color: Colors.grey.shade400);
    }

    return SaveJobButton(
      key: ValueKey('$currentUser-$jobId'),
      userId: currentUser.uid,
      jobId: jobId,
    );
  }

  Map<String, bool> _getProfileChecklist(User user) {
    return {
      'Full name': user.name != null && user.name!.isNotEmpty,
      'Email verified': true,
      'Phone number': user.phone != null && user.phone!.isNotEmpty,
      'Location': user.location != null && user.location!.isNotEmpty,
      'Bio': user.bio != null && user.bio!.isNotEmpty,
      'Skills': user.skills.isNotEmpty,
      'Job preferences': user.preferences.isNotEmpty && user.preferences.values.any((v) => v),
    };
  }
}