import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/screens/Auth/confirm_account/bloc/confirm_account_bloc.dart';
import 'package:agro_k/screens/Auth/log_in/view/log_in_screen.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ConfirmAccountScreen extends StatelessWidget {
  static const String id = '/confirm_account';
  final String? emailPhone;

  static Widget withBloc({String? emailPhone}) {
    return BlocProvider(
      create: (_) => ConfirmAccountBloc(
        authService: getIt<AuthService>(),
      )..add(const CheckEmailVerified()),
      child: ConfirmAccountScreen(emailPhone: emailPhone,),
    );
  }

  const ConfirmAccountScreen({Key? key, required this.emailPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return BlocListener<ConfirmAccountBloc, ConfirmAccountState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ConfirmAccountStatus.goLogin) {
          context.goNamed(LogInScreen.id);
        } else if (state.status == ConfirmAccountStatus.goDashboard) {
          context.goNamed(DashboardScreen.id);
        } else if (state.status == ConfirmAccountStatus.failure) {
          showOneButtonAlertDialog(context, "Ok", () {
            Navigator.pop(context);
          }, "Error", state.errorMessage ?? "Unknown error.");
        } else if (state.status == ConfirmAccountStatus.signOutSuccessfully) {
          context.goNamed(LogInScreen.id);
        }
      },
      child: SelectionArea(
        child: Scaffold(
          appBar: kIsWeb
              ? null
              : AppBar(
                  backgroundColor: AppColors.appPrimaryGreen,
                  title: const Text(
                    "Confirm Account",
                  )),
          backgroundColor: Colors.white,
          body: SafeArea(
              child: SingleChildScrollView(
            child: !kIsWeb
                ? _MobileConfirmAccountScreen(emailPhone: emailPhone)
                : _WebConfirmAccountScreen(emailPhone: emailPhone),
          )),
        ),
      ),
    );
  }
  

}

class _WebConfirmAccountScreen extends StatelessWidget {
  const _WebConfirmAccountScreen({
    required this.emailPhone,
  });

  final String? emailPhone;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Card(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4))),
            elevation: 8,
            child: Container(
              width: 800,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - 50,
                          height: 90,
                          color: AppColors.appPrimaryGreen,
                        ),
                        Image.asset("images/agrokLogo.png")
                      ]),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "A verification email has been sent to the email ${emailPhone ?? FirebaseAuth.instance.currentUser!.email}. Please verify your email to continue.",
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const _ResendCodeButton(),
                  const SizedBox(
                    height: 16,
                  ),
                  const _CancelButton(),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

class _MobileConfirmAccountScreen extends StatelessWidget {
  const _MobileConfirmAccountScreen({
    required this.emailPhone,
  });

  final String? emailPhone;

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          const SizedBox(
            height: 150,
          ),
          Row(
            children: [
              const SizedBox(
                width: 25,
              ),
              Flexible(
                child: Text(
                  "A verification email has been sent to the email ${emailPhone ?? FirebaseAuth.instance.currentUser!.email}. Please verify your email to continue.",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(
                width: 25,
              )
            ],
          ),
          const SizedBox(
            height: 200,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            child: const _ResendCodeButton(),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            child: const _CancelButton(),
          ),
        ],
      );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          context.read<ConfirmAccountBloc>().add(const SignOut());
        },
        child: const Text(
          "Cancel",
          style: TextStyle(color: AppColors.appPrimaryGreen),
        ));
  }
}

class _ResendCodeButton extends StatelessWidget {
  const _ResendCodeButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      },
      child: const Text(
        "Resend Code",
        style: TextStyle(
            color: AppColors.appPrimaryGreen, fontSize: 16),
      ),
    );
  }
}
