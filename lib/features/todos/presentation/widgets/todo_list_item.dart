import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/todo_model.dart';
import '../../domain/entities/todo_entity.dart';

class TodoListItem extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback onToggleCompleted;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoListItem({
    super.key,
    required this.todo,
    required this.onToggleCompleted,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSynced = todo is TodoModel
        ? (todo as TodoModel).isSynced
        : true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggleCompleted,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: todo.completed ? AppColors.green : Colors.transparent,
                border: Border.all(
                  color: todo.completed
                      ? AppColors.green
                      : AppColors.borderPrimary,
                  width: 2,
                ),
              ),
              child: todo.completed
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              child: Text(
                todo.title,
                style: TextStyle(
                  color: todo.completed
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontSize: 16,
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          if (!isSynced)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.amber,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.red,
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
