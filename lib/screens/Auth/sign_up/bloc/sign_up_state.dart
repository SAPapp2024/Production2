part of 'sign_up_bloc.dart';

enum SignUpStatus {
  initial, loading, failure, success
}

final class SignUpState extends Equatable {
  const SignUpState({
    this.status = SignUpStatus.initial,
    this.firstName = const RequiredField.pure(),
    this.lastName = const RequiredField.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  final SignUpStatus status;
  final RequiredField firstName;
  final RequiredField lastName;
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;
  final bool isValid;
  final String? errorMessage;

  SignUpState copyWith({
    SignUpStatus? status,
    RequiredField? firstName,
    RequiredField? lastName,
    Email? email,
    Password? password,
    ConfirmPassword? confirmPassword,
    bool? isValid,
    String? errorMessage,
  }) {
    return SignUpState(
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, firstName, lastName, email, password, confirmPassword, isValid, errorMessage];
}
