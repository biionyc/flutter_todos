import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_colors.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/todos/presentation/bloc/todo_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider<TodoBloc>(create: (_) => serviceLocator<TodoBloc>()),
      ],
      child: MaterialApp(
        title: 'My Tasks',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: AppColors.bgPrimary),
        home: const LoginPage(),
      ),
    );
  }
}
