import 'package:equatable/equatable.dart';
import 'package:budgeit/common/helper/message/Failure.dart';

abstract class EditStreamState extends Equatable {
  const EditStreamState();

  @override
  List<Object?> get props => [];
}

class EditStreamInitial extends EditStreamState {}

class EditStreamLoading extends EditStreamState {}

class EditStreamSuccess extends EditStreamState {
  final String message;

  const EditStreamSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EditStreamError extends EditStreamState {
  final Failure failure;

  const EditStreamError(this.failure);

  @override
  List<Object?> get props => [failure];
}