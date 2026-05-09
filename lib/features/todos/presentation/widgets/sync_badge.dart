import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SyncBadge extends StatelessWidget {
  final bool isSyncing;
  final int pendingCount;

  const SyncBadge({
    super.key,
    required this.isSyncing,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = pendingCount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPending ? AppColors.offlineBadgeBg : AppColors.syncBadgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSyncing
                ? Icons.sync
                : isPending
                ? Icons.cloud_off_outlined
                : Icons.cloud_done_outlined,
            size: 14,
            color: isPending ? AppColors.amber : AppColors.green,
          ),
          const SizedBox(width: 6),
          Text(
            isPending
                ? '$pendingCount ${pendingCount == 1 ? 'change' : 'changes'} pending'
                : 'Synced',
            style: TextStyle(
              color: isPending ? AppColors.amber : AppColors.green,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
