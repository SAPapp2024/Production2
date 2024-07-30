part of 'login_bloc.dart';

enum LoginStatus {
  initial, loading, failure, successUserNotVerified, successUserVerified
}

final class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  final LoginStatus status;
  final Email email;
  final Password password;
  final bool isValid;
  final String? errorMessage;

  LoginState copyWith({
    LoginStatus? status,
    Email? email,
    Password? password,
    bool? isValid,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, email, password, isValid , errorMessage];
}
