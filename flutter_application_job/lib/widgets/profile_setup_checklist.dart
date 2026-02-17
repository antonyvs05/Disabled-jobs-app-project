import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_colors.dart';

class ProfileSetupChecklist extends StatelessWidget {
  final User user;

  const ProfileSetupChecklist({
    required this.user,
    super.key,
  });

  /// Calculate profile completion status
  Map<String, bool> _getChecklistItems() {
    return {
      'Full name': user.name != null && user.name!.isNotEmpty,
      'Email verified': true, // Assuming verified if user exists
      'Phone number': user.phone != null && user.phone!.isNotEmpty,
      'Location': user.location != null && user.location!.isNotEmpty,
      'Bio': user.bio != null && user.bio!.isNotEmpty,
      'Skills': user.skills.isNotEmpty,
      'Job preferences': user.preferences.isNotEmpty && user.preferences.values.any((v) => v),
    };
  }

  /// Calculate completion percentage
  int _getCompletedCount() {
    final items = _getChecklistItems();
    return items.values.where((v) => v).length;
  }

  int _getTotalCount() {
    return _getChecklistItems().length;
  }

  bool _isProfileComplete() {
    return _getCompletedCount() == _getTotalCount();
  }

  @override
  Widget build(BuildContext context) {
    final checklist = _getChecklistItems();
    final completedCount = _getCompletedCount();
    final totalCount = _getTotalCount();
    final isComplete = _isProfileComplete();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isComplete
              ? [AppColors.success.withValues(alpha: 0.1), AppColors.success.withValues(alpha: 0.05)]
              : [AppColors.secondary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.05)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete ? '✓ Profile Complete!' : 'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isComplete ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set up your profile to access all features',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.greyMedium,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isComplete ? AppColors.success : AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completedCount/$totalCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completedCount / totalCount,
                minHeight: 6,
                backgroundColor: AppColors.greyLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? AppColors.success : AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Checklist items
            ...checklist.entries.map((entry) {
              final isCompleted = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? AppColors.success : AppColors.greyLight,
                        border: Border.all(
                          color: isCompleted ? AppColors.success : AppColors.greyMedium,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16,
                          color: isCompleted ? AppColors.greyMedium : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!isCompleted)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.greyMedium,
                      ),
                  ],
                ),
              );
            }).toList(),

            if (!isComplete)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Complete your profile to create and apply for jobs',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
