part of 'confirm_account_bloc.dart';

enum ConfirmAccountStatus {
  initial, loading, failure, goLogin, goDashboard, signOutSuccessfully
}

final class ConfirmAccountState extends Equatable {
  const ConfirmAccountState({
    this.status = ConfirmAccountStatus.initial,
    this.errorMessage,
  });

  final ConfirmAccountStatus status;
  final String? errorMessage;

  ConfirmAccountState copyWith({
    ConfirmAccountStatus? status,
    String? errorMessage,
  }) {
    return ConfirmAccountState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
