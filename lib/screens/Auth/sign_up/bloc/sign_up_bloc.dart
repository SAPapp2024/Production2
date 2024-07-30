import 'package:agro_k/screens/common/models/models.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {

  AuthService authService;

  SignUpBloc({required this.authService})  : super(const SignUpState()) {
    on<SignUpFirstNameChanged>(_onFirstNameChanged);
    on<SignUpLastNameChanged>(_onLastNameChanged);
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<SignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignUpSubmitted>(_onSubmitted);
  }

  void _onFirstNameChanged(
    SignUpFirstNameChanged event,
    Emitter<SignUpState> emit,
  ) {
    final firstName = RequiredField.dirty(event.firstName);
    emit(
      state.copyWith(
        firstName: firstName,
        isValid: Formz.validate([firstName, state.lastName, state.email, state.password, state.confirmPassword]),
      ),
    );
  }

  void _onLastNameChanged(
    SignUpLastNameChanged event,
    Emitter<SignUpState> emit,
  ) {
    final lastName = RequiredField.dirty(event.lastName);
    emit(
      state.copyWith(
        lastName: lastName,
        isValid: Formz.validate([state.firstName, lastName, state.email, state.password, state.confirmPassword]),
      ),
    );
  }

  void _onEmailChanged(
    SignUpEmailChanged event,
    Emitter<SignUpState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([state.firstName, state.lastName, email, state.password, state.confirmPassword])
      ),
    );
  }

  void _onPasswordChanged(
    SignUpPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    final password = Password.dirty(event.password);
    final confirmPassword = ConfirmPassword.dirty(password: password.value, value: state.confirmPassword.value);
    emit(
      state.copyWith(
        password: password,
        confirmPassword: confirmPassword,
        isValid: Formz.validate([state.firstName, state.lastName, state.email, password, state.confirmPassword])
      ),
    );
  }

  void _onConfirmPasswordChanged(
    SignUpConfirmPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    final confirmPassword = ConfirmPassword.dirty(password: state.password.value, value: event.confirmPassword);
    emit(
      state.copyWith(
        confirmPassword: confirmPassword,
        isValid: Formz.validate([state.firstName, state.lastName, state.email, state.password, confirmPassword])
      ),
    );
  }

  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: SignUpStatus.loading, errorMessage: null));
      try {
        await authService.signUp(
            firstName: state.firstName.value,
            lastName: state.lastName.value,
            email: state.email.value,
            phone: null,
            password: state.password.value);
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        emit(state.copyWith(status: SignUpStatus.success));
      } on FirebaseAuthException catch (err) {
        emit(state.copyWith(status: SignUpStatus.failure, errorMessage: err.message ?? "Error logging in. Please try again."));
      } catch (_) {
        emit(state.copyWith(status: SignUpStatus.failure, errorMessage: "There was an error."));
      }
    } else {
      emit(state.copyWith(status: SignUpStatus.failure, errorMessage: null));
    }
  }
}
