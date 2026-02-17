import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user_model.dart' as um;
import 'services/firebase_service.dart';
import 'theme/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillController = TextEditingController();

  List<String> _skills = [];
  Map<String, dynamic> _preferences = {};
  List<String> _functionalNeeds = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  um.User? _user;

  final List<String> _availablePreferences = [
    'Remote',
    'Full-time',
    'Part-time',
    'Contract',
    'Flexible Hours',
  ];

  final List<String> _availableFunctionalNeeds = [
    'Wheelchair Accessible',
    'Flexible Breaks',
    'Screen Reader Compatible',
    'Large Text Support',
    'Quiet Work Environment',
    'Hearing Loop/Captioning',
    'Mobility Assistance',
    'Visual Assistance',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      final user = await FirebaseService().getUser(currentUser.uid);
      if (user != null) {
        setState(() {
          _user = user;
          _nameController.text = user.name ?? '';
          _phoneController.text = user.phone ?? '';
          _locationController.text = user.location ?? '';
          _bioController.text = user.bio ?? '';
          _skills = List.from(user.skills);
          _preferences = Map.from(user.preferences);
          _functionalNeeds = List.from(user.functionalNeeds);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final updatedUser = _user!.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _skills,
        preferences: _preferences,
        functionalNeeds: _functionalNeeds,
      );

      await FirebaseService().updateUser(currentUser.uid, updatedUser.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.accent,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // Pass true to indicate profile was updated
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _togglePreference(String pref) {
    setState(() {
      if (_preferences.containsKey(pref)) {
        _preferences.remove(pref);
      } else {
        _preferences[pref] = true;
      }
    });
  }

  void _toggleFunctionalNeed(String need) {
    setState(() {
      if (_functionalNeeds.contains(need)) {
        _functionalNeeds.remove(need);
      } else {
        _functionalNeeds.add(need);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                )
              else
                const SizedBox.shrink(),
              if (_errorMessage != null) const SizedBox(height: 16),
              _buildField(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Phone',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Location',
                controller: _locationController,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Bio',
                controller: _bioController,
                icon: Icons.edit_note,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Skills'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillController,
                      decoration: InputDecoration(
                        hintText: 'Add a skill',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _addSkill,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills
                    .map((skill) => Chip(
                          label: Text(skill),
                          onDeleted: () => _removeSkill(skill),
                          backgroundColor: AppColors.secondary,
                          labelStyle: const TextStyle(color: Colors.white),
                          deleteIconColor: Colors.white,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Work Preferences'),
              const SizedBox(height: 12),
              Column(
                children: _availablePreferences
                    .map((pref) => CheckboxListTile(
                          title: Text(pref),
                          value: _preferences.containsKey(pref) && _preferences[pref] == true,
                          onChanged: (_) => _togglePreference(pref),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Accessibility Requirements'),
              const SizedBox(height: 12),
              Column(
                children: _availableFunctionalNeeds
                    .map((need) => CheckboxListTile(
                          title: Text(need),
                          value: _functionalNeeds.contains(need),
                          onChanged: (_) => _toggleFunctionalNeed(need),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }
}
