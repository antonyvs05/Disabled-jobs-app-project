import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../theme/app_colors.dart';

/// Reusable save button widget for saving/unsaving jobs
/// Handles all bookmark functionality in one place
class SaveJobButton extends StatefulWidget {
  final String userId;
  final String jobId;
  final VoidCallback? onSaveChanged;

  const SaveJobButton({
    required this.userId,
    required this.jobId,
    this.onSaveChanged,
    super.key,
  });

  @override
  State<SaveJobButton> createState() => _SaveJobButtonState();
}

class _SaveJobButtonState extends State<SaveJobButton>
    with WidgetsBindingObserver {
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSavedStatus();
    }
  }

  Future<void> _loadSavedStatus() async {
    final saved =
        await FirebaseService().isJobSaved(widget.userId, widget.jobId);
    if (mounted) {
      setState(() {
        _isSaved = saved;
      });
    }
  }

  Future<void> _toggleSaveStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSaved) {
        await FirebaseService()
            .removeSavedJob(widget.userId, widget.jobId);
      } else {
        await FirebaseService().saveJob(widget.userId, widget.jobId);
      }

      if (mounted) {
        setState(() {
          _isSaved = !_isSaved;
          _isLoading = false;
        });
        widget.onSaveChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error toggling saved job: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isSaved ? Icons.bookmark : Icons.bookmark_outline,
        color:
            _isSaved ? AppColors.secondary : Colors.grey.shade400,
      ),
      onPressed: _isLoading ? null : _toggleSaveStatus,
      tooltip: _isSaved ? 'Remove from saved' : 'Save job',
    );
  }
}
