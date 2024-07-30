part of 'confirm_account_bloc.dart';

sealed class ConfirmAccountEvent extends Equatable {
  const ConfirmAccountEvent();

  @override
  List<Object> get props => [];
}

final class OnUpdateEmailVerifiedToTrue extends ConfirmAccountEvent {
  final User user;
  const OnUpdateEmailVerifiedToTrue(this.user);
}

final class CheckEmailVerified extends ConfirmAccountEvent {
  const CheckEmailVerified();
}

final class SignOut extends ConfirmAccountEvent {
  const SignOut();
}
