part of 'custom_auth_bloc.dart';

sealed class CustomAuthEvent extends Equatable {
  const CustomAuthEvent();

  @override
  List<Object> get props => [];
}

final class SubmitOobCode extends CustomAuthEvent {
  const SubmitOobCode();
}

class PasswordChanged extends CustomAuthEvent {
  const PasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

class SubmitNewPassword extends CustomAuthEvent {
  const SubmitNewPassword();
}
