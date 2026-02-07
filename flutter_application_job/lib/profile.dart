import 'package:flutter/material.dart';
import 'models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock user data
  late User currentUser;

  @override
  void initState() {
    super.initState();
    // Initialize with mock data
    currentUser = User(
      id: '1',
      email: 'user@example.com',
      role: UserRole.job_seeker,
      skills: ['Flutter', 'Dart', 'UI/UX Design'],
      preferences: {
        'remote_work': true,
        'flexible_hours': true,
        'salary_range': '40000-60000',
      },
      functionalNeeds: [
        'Screen Reader Support',
        'Flexible Working Hours',
        'Remote Work Options',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      name: 'John Doe',
      phone: '+1234567890',
      location: 'New York, NY',
      bio: 'Experienced developer looking for accessible workplace opportunities.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditProfileDialog();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              } else if (value == 'settings') {
                _showSettingsDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade800,
                    Colors.blue.shade600,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser.name ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentUser.role == UserRole.job_seeker 
                          ? 'Job Seeker' 
                          : 'Employer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bio Section
                  _buildSectionTitle('About'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        currentUser.bio ?? 'No bio available',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Contact Information
                  _buildSectionTitle('Contact Information'),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        _buildInfoTile(Icons.phone, 'Phone', currentUser.phone ?? 'Not provided'),
                        const Divider(height: 1),
                        _buildInfoTile(Icons.location_on, 'Location', currentUser.location ?? 'Not provided'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Skills Section
                  _buildSectionTitle('Skills'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: currentUser.skills.isEmpty
                          ? const Text('No skills added yet')
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: currentUser.skills.map((skill) {
                                return Chip(
                                  label: Text(skill),
                                  backgroundColor: Colors.blue.shade50,
                                  labelStyle: TextStyle(color: Colors.blue.shade800),
                                );
                              }).toList(),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Functional Needs Section
                  _buildSectionTitle('Accessibility Requirements'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: currentUser.functionalNeeds.isEmpty
                          ? const Text('No accessibility requirements specified')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: currentUser.functionalNeeds.map((need) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.accessible,
                                        size: 20,
                                        color: Colors.blue.shade800,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          need,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Preferences Section
                  _buildSectionTitle('Work Preferences'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: currentUser.preferences.isEmpty
                          ? const Text('No preferences set')
                          : Column(
                              children: currentUser.preferences.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key.replaceAll('_', ' ').toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      Text(entry.value.toString()),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Account Info
                  _buildSectionTitle('Account Information'),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        _buildInfoTile(
                          Icons.calendar_today,
                          'Member Since',
                          _formatDate(currentUser.createdAt),
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          Icons.badge,
                          'User ID',
                          currentUser.id,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade800),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings page coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(context, (route) => route.isFirst); // Go back to login
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}