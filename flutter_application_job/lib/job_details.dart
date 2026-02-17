import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'models/job_model.dart';
import 'models/user_model.dart';
import 'models/application_model.dart';
import 'services/firebase_service.dart';
import 'theme/app_colors.dart';
import 'widgets/save_job_button.dart';

class JobDetailsPage extends StatefulWidget {
  final Job job;

  const JobDetailsPage({
    required this.job,
    super.key,
  });

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  bool _hasApplied = false;
  bool _isApplying = false;
  User? _currentUser;
  String? _applicationError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkApplicationStatus();
  }

  Future<void> _loadUserData() async {
    final currentAuth = auth.FirebaseAuth.instance.currentUser;
    if (currentAuth != null) {
      final user = await FirebaseService().getUser(currentAuth.uid);
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    }
  }

  Future<void> _checkApplicationStatus() async {
    final currentAuth = auth.FirebaseAuth.instance.currentUser;
    if (currentAuth != null) {
      final hasApplied =
          await FirebaseService().hasApplied(currentAuth.uid, widget.job.id);
      if (mounted) {
        setState(() {
          _hasApplied = hasApplied;
        });
      }
    }
  }

  Future<void> _applyForJob() async {
    final currentAuth = auth.FirebaseAuth.instance.currentUser;
    if (currentAuth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to apply for jobs'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load your profile'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isApplying = true;
      _applicationError = null;
    });

    try {
      final application = Application(
        userId: currentAuth.uid,
        jobId: widget.job.id,
        status: ApplicationStatus.pending,
        createdAt: DateTime.now(),
      );

      await FirebaseService().createApplication(application);

      if (mounted) {
        setState(() {
          _hasApplied = true;
          _isApplying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _applicationError = 'Failed to submit application: $e';
          _isApplying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_applicationError!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAuth = auth.FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Job Details'),
        actions: [
          if (currentAuth != null)
            SaveJobButton(
              userId: currentAuth.uid,
              jobId: widget.job.id,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Header
            Container(
              width: double.infinity,
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
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.job.company ?? 'Company',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Quick Info Row
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildQuickInfo(
                          icon: Icons.location_on_outlined,
                          label: widget.job.location ?? 'N/A',
                        ),
                        _buildQuickInfo(
                          icon: Icons.attach_money,
                          label: widget.job.salary ?? 'Competitive',
                        ),
                        if (widget.job.remote)
                          _buildQuickInfo(
                            icon: Icons.home_outlined,
                            label: 'Remote',
                          ),
                        if (widget.job.flexibleHours)
                          _buildQuickInfo(
                            icon: Icons.schedule,
                            label: 'Flexible Hours',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Main Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Description
                  _buildSection(
                    'Job Description',
                    widget.job.description,
                  ),
                  const SizedBox(height: 24),

                  // Accessibility Features
                  if (widget.job.accessibilityFeatures.isNotEmpty) ...[
                    _buildSectionTitle('Accessibility Features'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.job.accessibilityFeatures
                          .map(
                            (feature) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: AppColors.secondary.withValues(alpha: 0.3),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: AppColors.secondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    feature,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Job Details Grid
                  _buildJobDetailsGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(currentAuth),
    );
  }

  Widget _buildQuickInfo({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white.withOpacity(0.9),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildJobDetailsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            label: 'Posted',
            value: _formatDate(widget.job.createdAt),
          ),
          const Divider(height: 16),
          _buildDetailRow(
            label: 'Remote',
            value: widget.job.remote ? 'Yes' : 'No',
          ),
          const Divider(height: 16),
          _buildDetailRow(
            label: 'Flexible Hours',
            value: widget.job.flexibleHours ? 'Yes' : 'No',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.greyDark,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(auth.User? currentAuth) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_applicationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _applicationError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                // Apply Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _hasApplied || _isApplying || currentAuth == null
                        ? null
                        : _applyForJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasApplied
                          ? AppColors.success
                          : AppColors.secondary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.success.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isApplying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _hasApplied
                                ? 'Already Applied'
                                : 'Apply Now',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Contact Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: currentAuth == null ? null : _showContactDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(
                        color: AppColors.secondary,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (currentAuth == null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Please login to apply or contact the employer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Employer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose how you\'d like to contact the employer:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildContactOption(
              icon: Icons.mail_outline,
              title: 'Send Email',
              subtitle: 'Send a message to the employer',
              onTap: () {
                Navigator.pop(context);
                _sendEmail();
              },
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              icon: Icons.message_outlined,
              title: 'Send Message',
              subtitle: 'Chat directly with the employer',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Messaging feature coming soon'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              icon: Icons.phone_outlined,
              title: 'Request Call',
              subtitle: 'Ask the employer to call you',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Call request sent (feature coming soon)'),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.secondary,
                size: 24,
              ),
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
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Email'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Compose your message:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Write your message here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email sent successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
