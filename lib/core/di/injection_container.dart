import 'package:get_it/get_it.dart';
import '../../features/game/presentation/bloc/game_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Game
  sl.registerFactory(() => GameBloc());
}
