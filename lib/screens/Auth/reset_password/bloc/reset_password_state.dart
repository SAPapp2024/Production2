part of 'reset_password_bloc.dart';

enum ResetPasswordStatus {
  initial, loading, failure, success
}

final class ResetPasswordState extends Equatable {
  const ResetPasswordState({
    this.status = ResetPasswordStatus.initial,
    this.email = const Email.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  final ResetPasswordStatus status;
  final Email email;
  final bool isValid;
  final String? errorMessage;

  ResetPasswordState copyWith({
    ResetPasswordStatus? status,
    Email? email,
    bool? isValid,
    String? errorMessage,
  }) {
    return ResetPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, email, isValid , errorMessage];
}
