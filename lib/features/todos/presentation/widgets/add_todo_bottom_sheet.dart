import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';

class AddTodoBottomSheet extends StatefulWidget {
  final String? todoTitle;
  final int todoId;
  final bool isEdit;
  const AddTodoBottomSheet({
    super.key,
    this.todoTitle,
    required this.todoId,
    this.isEdit = false,
  });

  @override
  State<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends State<AddTodoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.todoTitle ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.isEdit) {
        context.read<TodoBloc>().add(
          UpdateTodoTitleEvent(
            id: widget.todoId,
            title: _titleController.text.trim(),
          ),
        );
      } else {
        context.read<TodoBloc>().add(
          AddTodoEvent(title: _titleController.text.trim()),
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 28,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEdit ? 'Update task' : 'New task',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _titleController,
              label: 'Task title',
              hint: 'e.g. Call dentist',
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Task title is required'
                  : null,
              onFieldSubmitted: (_) => _submit(),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: widget.isEdit ? 'Update task' : 'Add task',
              onPressed: _submit,
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
