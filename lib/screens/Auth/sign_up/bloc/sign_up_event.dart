part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

final class SignUpFirstNameChanged extends SignUpEvent {
  const SignUpFirstNameChanged(this.firstName);

  final String firstName;

  @override
  List<Object> get props => [firstName];
}

final class SignUpLastNameChanged extends SignUpEvent {
  const SignUpLastNameChanged(this.lastName);

  final String lastName;

  @override
  List<Object> get props => [lastName];
}

final class SignUpEmailChanged extends SignUpEvent {
  const SignUpEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

final class SignUpPasswordChanged extends SignUpEvent {
  const SignUpPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

final class SignUpConfirmPasswordChanged extends SignUpEvent {
  const SignUpConfirmPasswordChanged(this.confirmPassword);

  final String confirmPassword;

  @override
  List<Object> get props => [confirmPassword];
}

final class SignUpSubmitted extends SignUpEvent {
  const SignUpSubmitted();
}
