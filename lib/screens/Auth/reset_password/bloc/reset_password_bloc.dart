import 'package:agro_k/screens/common/models/models.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  AuthService authService;

  ResetPasswordBloc({required this.authService})
      : super(const ResetPasswordState()) {
    on<ResetPasswordEmailChanged>(_onEmailChanged);
    on<ResetPasswordSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
    ResetPasswordEmailChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email]),
      ),
    );
  }

  Future<void> _onSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(
          status: ResetPasswordStatus.loading, errorMessage: null));
      try {
        await authService.resetPassword(email: state.email.value);
        emit(state.copyWith(status: ResetPasswordStatus.success));
      } on FirebaseAuthException catch (err) {
        emit(state.copyWith(status: ResetPasswordStatus.failure, errorMessage: err.message == null ? "There was an error." : err.message!.contains("auth/user-not-found") ? "No user found with this email." : err.message));
      } on ResetPasswordTooSoonException catch (_) {
        emit(state.copyWith(
            status: ResetPasswordStatus.failure,
            errorMessage:
                "You have to wait one minute before requesting a new password reset."));
      } catch (_) {
        emit(state.copyWith(
            status: ResetPasswordStatus.failure,
            errorMessage: "There was an error."));
      }
    } else {
      emit(state.copyWith(
          status: ResetPasswordStatus.failure,
          errorMessage: null));
    }
  }
}
