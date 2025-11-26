import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../logic/code_alchemist_game.dart'; // Import AgentCommand enum

// --- EVENTS ---
abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object> get props => [];
}

class AddCommandEvent extends GameEvent {
  final AgentCommand command;
  const AddCommandEvent(this.command);
  @override
  List<Object> get props => [command];
}

class ClearCommandsEvent extends GameEvent {}

class RunCommandsEvent extends GameEvent {}

class ResetGameEvent extends GameEvent {}

// --- STATE ---
enum GameStatus { idle, running, completed }

class GameState extends Equatable {
  final List<AgentCommand> commands;
  final GameStatus status;

  const GameState({
    this.commands = const [],
    this.status = GameStatus.idle,
  });

  GameState copyWith({
    List<AgentCommand>? commands,
    GameStatus? status,
  }) {
    return GameState(
      commands: commands ?? this.commands,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [commands, status];
}

// --- BLOC ---
class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(const GameState()) {
    on<AddCommandEvent>((event, emit) {
      if (state.status == GameStatus.running) return; // Lock during run
      final newList = List<AgentCommand>.from(state.commands)..add(event.command);
      emit(state.copyWith(commands: newList));
    });

    on<ClearCommandsEvent>((event, emit) {
      if (state.status == GameStatus.running) return;
      emit(state.copyWith(commands: []));
    });

    on<RunCommandsEvent>((event, emit) {
      if (state.commands.isEmpty) return;
      emit(state.copyWith(status: GameStatus.running));
    });

    on<ResetGameEvent>((event, emit) {
      emit(state.copyWith(status: GameStatus.idle));
    });
  }
}
