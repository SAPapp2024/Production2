part of 'reset_password_bloc.dart';

sealed class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();

  @override
  List<Object> get props => [];
}

final class ResetPasswordEmailChanged extends ResetPasswordEvent {
  const ResetPasswordEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

final class ResetPasswordSubmitted extends ResetPasswordEvent {
  const ResetPasswordSubmitted();
}
