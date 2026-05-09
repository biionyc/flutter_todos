import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network_info/network_info.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/add_todo_bottom_sheet.dart';
import '../widgets/offline_banner.dart';
import '../widgets/sync_badge.dart';
import '../widgets/todo_sliver_list.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;
  final ValueNotifier<bool> _isOffline = ValueNotifier(false);

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _networkInfo = serviceLocator<NetworkInfo>();
    context.read<TodoBloc>().add(LoadTodosEvent());
    _networkInfo.isConnected.then((connected) {
      if (mounted) _isOffline.value = !connected;
    });
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((
      connected,
    ) {
      if (mounted) {
        _isOffline.value = !connected;
        if (connected) context.read<TodoBloc>().add(SyncTodosEvent());
      }
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) context.read<TodoBloc>().add(SearchTodosEvent(query: query));
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _isOffline.dispose();
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoBloc, TodoState>(
      listenWhen: (_, current) =>
          current is TodosLoadFailure ||
          current is TodosServerError ||
          current is TodoAddFailure ||
          current is TodoUpdateFailure ||
          current is TodoDeleteFailure ||
          current is SyncSuccess ||
          current is SyncFailure,
      listener: (context, state) {
        final message = switch (state) {
          TodosLoadFailure(:final message) => message,
          TodosServerError(:final message) => message,
          TodoAddFailure(:final message) => message,
          TodoUpdateFailure(:final message) => message,
          TodoDeleteFailure(:final message) => message,
          SyncSuccess() => 'Local changes synced successfully',
          SyncFailure() => 'There was an error syncing local changes',
          _ => null,
        };
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.bgSecondary,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                const Text(
                  'My tasks',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<TodoBloc, TodoState>(
                  buildWhen: (_, current) =>
                      current is TodosLoadSuccess ||
                      current is TodosLoadInProgress,
                  builder: (context, state) {
                    final isSyncing =
                        state is TodosLoadSuccess && state.isSyncing;
                    final pendingCount = state is TodosLoadSuccess
                        ? state.pendingCount
                        : 0;
                    return SyncBadge(
                      isSyncing: isSyncing,
                      pendingCount: pendingCount,
                    );
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _searchController,
                  hint: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search_outlined, size: 20),
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: _isOffline,
                  builder: (_, isOffline, _) {
                    if (isOffline) {
                      return const OfflineBanner();
                    }

                    return const SizedBox.shrink();
                  },
                ),
                const Expanded(child: TodoSliverList()),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            backgroundColor: AppColors.bgSecondary,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const AddTodoBottomSheet(todoId: 0),
          ),
          backgroundColor: AppColors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
