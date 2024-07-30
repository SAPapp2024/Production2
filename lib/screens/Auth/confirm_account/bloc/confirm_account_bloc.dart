import 'dart:async';

import 'package:agro_k/services/auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'confirm_account_event.dart';
part 'confirm_account_state.dart';

class ConfirmAccountBloc extends Bloc<ConfirmAccountEvent, ConfirmAccountState> {
  AuthService authService;

  ConfirmAccountBloc({required this.authService})
      : super(const ConfirmAccountState()) {
    on<CheckEmailVerified>(_onCheckEmailVerified);
    on<SignOut>(_onSignOut);
    on<OnUpdateEmailVerifiedToTrue>(_onUpdateEmailVerifiedToTrue);
  }

  void _onCheckEmailVerified(CheckEmailVerified event, Emitter<ConfirmAccountState> emit) async {
    try {
      emit(state.copyWith(status: ConfirmAccountStatus.loading));
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser == null) {
        emit(state.copyWith(status: ConfirmAccountStatus.goLogin));
      } else if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        Timer.periodic(const Duration(milliseconds: 500), (timer) async {
          await FirebaseAuth.instance.currentUser?.reload();
          if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
            timer.cancel();
            add(OnUpdateEmailVerifiedToTrue(FirebaseAuth.instance.currentUser!));
          }
        });
      } else {
        authService.updateEmailVerifiedToTrue(user: FirebaseAuth.instance.currentUser!);
        emit(state.copyWith(status: ConfirmAccountStatus.goDashboard));
      }
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: ConfirmAccountStatus.failure, errorMessage: e.message ?? "Unknown error."));
    }
  }

  void _onUpdateEmailVerifiedToTrue(OnUpdateEmailVerifiedToTrue event, Emitter<ConfirmAccountState> emit) async {
    try {
      emit(state.copyWith(status: ConfirmAccountStatus.loading));
      authService.updateEmailVerifiedToTrue(user: event.user);
      emit(state.copyWith(status: ConfirmAccountStatus.goDashboard));
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: ConfirmAccountStatus.failure, errorMessage: e.message ?? "Unknown error."));
    }
  }

  void _onSignOut(SignOut event, Emitter<ConfirmAccountState> emit) async {
    try {
      emit(state.copyWith(status: ConfirmAccountStatus.loading));
      await authService.signOut();
      emit(state.copyWith(status: ConfirmAccountStatus.signOutSuccessfully));
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: ConfirmAccountStatus.failure, errorMessage: e.message ?? "Unknown error."));
    }
  }

}
