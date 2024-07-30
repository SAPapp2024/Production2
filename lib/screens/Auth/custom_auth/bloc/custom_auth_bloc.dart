import 'dart:io';

import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/screens/common/models/models.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'custom_auth_event.dart';
part 'custom_auth_state.dart';

class CustomAuthBloc extends Bloc<CustomAuthEvent, CustomAuthState> {
  AuthService authService;
  String oobCode;
  String actionType;

  CustomAuthBloc({required this.authService, required this.oobCode, required this.actionType})
      : super(const CustomAuthState()) {
    on<SubmitOobCode>(_onCustomAuth);
    on<PasswordChanged>(_onPasswordChanged);
    on<SubmitNewPassword>(_onSubmitNewPassword);
  }

  Future<void> _onCustomAuth(
      SubmitOobCode event,
    Emitter<CustomAuthState> emit,
  ) async {
    try {
      String? email;
      CustomAuthStatus status;
      if (actionType == "verifyEmail") {
        var actionCodeInfo = await FirebaseAuth.instance.checkActionCode(oobCode);
        await FirebaseAuth.instance.applyActionCode(oobCode);
        email = actionCodeInfo.data["email"];
        status = CustomAuthStatus.successVerifyEmail;
        bool showOpenAppButton = state.showOpenAppButton;
        if (kIsWeb && Platform.isIOS) {
          try {
            final deviceInfoPlugin = DeviceInfoPlugin();
            final deviceInfo = await deviceInfoPlugin.deviceInfo;
            final allInfo = deviceInfo.data;
            showOpenAppButton = allInfo["browserName"] == "BrowserName.safari";
          } catch (e) {
            debugPrint(e.toString());
          }
        }
        emit(state.copyWith(status: status, email: email, showOpenAppButton: showOpenAppButton));
      } else if (actionType == "resetPassword") {
        var actionCodeInfo = await FirebaseAuth.instance.checkActionCode(oobCode);
        email = actionCodeInfo.data["email"];
        status = CustomAuthStatus.canResetPassword;
        emit(state.copyWith(status: status, email: email));
        debugPrint("Debug error reset password 2");
      } else {
        emit(state.copyWith(status: CustomAuthStatus.goLogin));
      }
    } on FirebaseAuthException catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>()
          .recordError(exception, stacktrace);
      CustomAuthStatus status;
      if (exception.code == "expired-action-code") {
        status = CustomAuthStatus.expiredCode;
      } else if (exception.code == "invalid-action-code") {
        status = CustomAuthStatus.invalidCode;
      } else if (exception.code == "user-disabled") {
        status = CustomAuthStatus.disabledUser;
      } else if (exception.code == "user-not-found") {
        status = CustomAuthStatus.userNotFound;
      } else {
        status = CustomAuthStatus.genericError;
      }
      emit(state.copyWith(status: status));
    }
  }

  void _onPasswordChanged(
      PasswordChanged event,
    Emitter<CustomAuthState> emit,
  ) {
    debugPrint("Debug error reset password 5 - ${event.password}");
    Password password = Password.dirty(event.password);
    emit(state.copyWith(
      password: password,
      isValid: Formz.validate([password]),
    ));
  }

  void _onSubmitNewPassword(
      SubmitNewPassword event,
    Emitter<CustomAuthState> emit,
  ) async {
    if (state.isValid) {
      try {
        await FirebaseAuth.instance.confirmPasswordReset(
            code: oobCode, newPassword: state.password.value);
        CustomAuthStatus status = CustomAuthStatus.successResetPassword;
        emit(state.copyWith(status: status));
      } on FirebaseAuthException catch (exception, stacktrace) {
        getIt.get<RemoteErrorLoggingService>()
            .recordError(exception, stacktrace);
        CustomAuthStatus status;
        if (exception.code == "expired-action-code") {
          status = CustomAuthStatus.expiredCode;
        } else if (exception.code == "invalid-action-code") {
          status = CustomAuthStatus.invalidCode;
        } else if (exception.code == "user-disabled") {
          status = CustomAuthStatus.disabledUser;
        } else if (exception.code == "user-not-found") {
          status = CustomAuthStatus.userNotFound;
        } else {
          status = CustomAuthStatus.genericError;
        }
        emit(state.copyWith(status: status));
      } catch (exception, stacktrace) {
        getIt.get<RemoteErrorLoggingService>()
            .recordError(exception, stacktrace);
        emit(state.copyWith(status: CustomAuthStatus.genericError));
      }
    } else {
      emit(state.copyWith(status: CustomAuthStatus.invalidPassword));
    }
  }
}
