import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteConfirmDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgSecondary,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text(
        'Delete task',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: const Text(
        'Are you sure you want to delete this task? This cannot be undone.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text(
            'Delete',
            style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
