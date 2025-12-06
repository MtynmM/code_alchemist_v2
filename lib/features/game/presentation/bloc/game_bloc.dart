import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/game_enums.dart';

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

class ExecutionCompletedEvent extends GameEvent {}

class UpdateExecutionIndexEvent extends GameEvent {
  final int index;
  const UpdateExecutionIndexEvent(this.index);
  @override
  List<Object> get props => [index];
}

// --- STATE ---
enum GameStatus { idle, running, completed }

class GameState extends Equatable {
  final List<AgentCommand> commands;
  final GameStatus status;
  final int currentExecutingIndex;

  const GameState({
    this.commands = const [],
    this.status = GameStatus.idle,
    this.currentExecutingIndex = -1,
  });

  GameState copyWith({
    List<AgentCommand>? commands,
    GameStatus? status,
    int? currentExecutingIndex,
  }) {
    return GameState(
      commands: commands ?? this.commands,
      status: status ?? this.status,
      currentExecutingIndex: currentExecutingIndex ?? this.currentExecutingIndex,
    );
  }

  @override
  List<Object> get props => [commands, status, currentExecutingIndex];
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
      emit(state.copyWith(status: GameStatus.running, currentExecutingIndex: -1));
    });

    on<ResetGameEvent>((event, emit) {
      emit(state.copyWith(status: GameStatus.idle, currentExecutingIndex: -1));
    });

    on<ExecutionCompletedEvent>((event, emit) {
      emit(state.copyWith(status: GameStatus.idle, currentExecutingIndex: -1));
    });

    on<UpdateExecutionIndexEvent>((event, emit) {
      emit(state.copyWith(currentExecutingIndex: event.index));
    });
  }
}
