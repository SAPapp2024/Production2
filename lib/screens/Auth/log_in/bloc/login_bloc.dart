import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/screens/common/models/models.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/utilities/exceptions.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  AuthService authService;

  LoginBloc({required this.authService})  : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([state.password, email]),
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([password, state.email]),
      ),
    );
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));
      try {
        UserCredential result =
        await authService.signIn(email: state.email.value, password: state.password.value);
        UserModel? user = await authService.getUserInDB();
        if (result.user?.emailVerified == true) {
          if (!kIsWeb) {
            await authService.updateNotificationToken(result.user!.uid);
          }
          if (user != null && !user.isConfirmed) {
            await authService.updateEmailVerifiedToTrue(user: result.user!);
          }
          emit(state.copyWith(status: LoginStatus.successUserVerified));
        } else {
          emit(state.copyWith(status: LoginStatus.successUserNotVerified));

        }
      } on DisabledUserException catch (err) {
        emit(state.copyWith(status: LoginStatus.failure, errorMessage: err.toString()));
      } on DeletedUserException catch (err) {
        emit(state.copyWith(status: LoginStatus.failure, errorMessage: err.toString()));
      } on FirebaseAuthException catch (err) {
        debugPrint("err.code: ${err.code}");
        emit(state.copyWith(status: LoginStatus.failure, errorMessage: err.message == null ? "Error logging in. Please try again." : err.message!.contains("auth/user-not-found") ? "No user found with this email." : err.message));
      } catch (_) {
        emit(state.copyWith(status: LoginStatus.failure, errorMessage: "There was an error."));
      }
    } else {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: null));
    }
  }
}
