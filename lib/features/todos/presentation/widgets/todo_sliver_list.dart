import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/features/todos/presentation/widgets/add_todo_bottom_sheet.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import 'delete_confirm_dialog.dart';
import 'todo_list_item.dart';

class TodoSliverList extends StatelessWidget {
  const TodoSliverList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (_, current) =>
          current is TodosLoadInProgress ||
          current is TodosLoadSuccess ||
          current is TodosLoadFailure,
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<TodoBloc>().add(LoadTodosEvent());
          },
          color: AppColors.green,
          backgroundColor: AppColors.offlineBadgeBg,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (state is TodosLoadInProgress)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  ),
                )
              else if (state is TodosLoadFailure)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (state is TodosLoadSuccess && state.todos.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No tasks yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else if (state is TodosLoadSuccess)
                SliverList.separated(
                  itemCount: state.todos.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: AppColors.borderPrimary, height: 1),
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return TodoListItem(
                      todo: todo,
                      onToggleCompleted: () {
                        context.read<TodoBloc>().add(
                          UpdateTodoCompletedEvent(
                            id: todo.id,
                            completed: !todo.completed,
                          ),
                        );
                      },
                      onEdit: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.bgSecondary,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => AddTodoBottomSheet(
                          todoTitle: todo.title,
                          todoId: todo.id,
                          isEdit: true,
                        ),
                      ),
                      onDelete: () => showDialog<void>(
                        context: context,
                        builder: (_) => DeleteConfirmDialog(
                          onConfirm: () => context.read<TodoBloc>().add(
                            DeleteTodoEvent(id: todo.id),
                          ),
                        ),
                      ),
                    );
                  },
                )
              else
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }
}
