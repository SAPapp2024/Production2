part of 'custom_auth_bloc.dart';

enum CustomAuthStatus { loading, successVerifyEmail, successResetPassword, expiredCode, invalidCode, disabledUser, userNotFound, genericError, canResetPassword, goLogin, invalidPassword }

final class CustomAuthState extends Equatable {
  const CustomAuthState({
    this.status = CustomAuthStatus.loading,
    this.email,
    this.password = const Password.pure(),
    this.isValid = false,
    this.errorMessage,
    this.showOpenAppButton = false,
  });

  final CustomAuthStatus status;
  final String? email;
  final Password password;
  final bool isValid;
  final String? errorMessage;
  final bool showOpenAppButton;

  CustomAuthState copyWith({
    CustomAuthStatus? status,
    String? email,
    Password? password,
    bool? isValid,
    String? errorMessage,
    bool? showOpenAppButton,
  }) {
    return CustomAuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      showOpenAppButton: showOpenAppButton ?? this.showOpenAppButton,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [status, email, password, isValid , errorMessage, showOpenAppButton];
}
