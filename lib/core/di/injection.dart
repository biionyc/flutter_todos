import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';
import '../network/api_client.dart';
import '../network/http_api_client.dart';
import '../network_info/network_info.dart';
import '../network_info/network_info_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/todos/data/datasources/todo_local_datasource.dart';
import '../../features/todos/data/datasources/todo_local_datasource_impl.dart';
import '../../features/todos/data/datasources/todo_remote_datasource.dart';
import '../../features/todos/data/datasources/todo_remote_datasource_impl.dart';
import '../../features/todos/data/repositories/todo_repository_impl.dart';
import '../../features/todos/domain/repositories/todo_repository.dart';
import '../../features/todos/presentation/bloc/todo_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> setupDI() async {
  serviceLocator.registerLazySingleton<Connectivity>(() => Connectivity());

  serviceLocator.registerLazySingleton<ApiClient>(() => HttpApiClient());
  serviceLocator.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  serviceLocator.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: serviceLocator<Connectivity>()),
  );

  // Auth
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );
  serviceLocator.registerFactory<AuthBloc>(
    () => AuthBloc(repository: serviceLocator<AuthRepository>()),
  );

  // Todos
  serviceLocator.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(apiClient: serviceLocator<ApiClient>()),
  );
  serviceLocator.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(
      databaseHelper: serviceLocator<DatabaseHelper>(),
    ),
  );
  serviceLocator.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      remoteDataSource: serviceLocator<TodoRemoteDataSource>(),
      localDataSource: serviceLocator<TodoLocalDataSource>(),
      networkInfo: serviceLocator<NetworkInfo>(),
      databaseHelper: serviceLocator<DatabaseHelper>(),
    ),
  );
  serviceLocator.registerFactory<TodoBloc>(
    () => TodoBloc(repository: serviceLocator<TodoRepository>()),
  );
}
