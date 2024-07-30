import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/screens/Auth/reset_password/bloc/reset_password_bloc.dart';
import 'package:agro_k/screens/common/models/models.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordScreen extends StatelessWidget {
  static const String id = '/reset_password';

  const ResetPasswordScreen({super.key});

  static Widget withBloc() {
    return BlocProvider(
      create: (context) => ResetPasswordBloc(authService: getIt.get()),
      child: const ResetPasswordScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return BlocListener<ResetPasswordBloc, ResetPasswordState>(
      listener: (context, state) {
        if (state.status == ResetPasswordStatus.success) {
          showOneButtonAlertDialog(context, "Ok", () {
            Navigator.pop(context);
            context.goBackWeb();
          }, "Success!",
              "Check your email for instructions on how to reset your password.");
        } else if (state.status == ResetPasswordStatus.failure &&
            state.errorMessage != null) {
          showOneButtonAlertDialog(context, "Ok", () {
            Navigator.pop(context);
          }, "Error", state.errorMessage!);
        }
      },
      child: SelectionArea(
        child: Scaffold(
          appBar: kIsWeb
              ? null
              : AppBar(
                  backgroundColor: AppColors.appPrimaryGreen,
                  title: const Text(
                    "Reset Password",
                  )),
          backgroundColor: Colors.white,
          body: const SafeArea(
              child: Stack(
            children: [
              SingleChildScrollView(
                child: !kIsWeb
                    ? _MobileResetPassword()
                    : _WebResetPassword(),
              ),
              _LoadingIndicator()
            ],
          )),
        ),
      ),
    );
  }
}

class _WebResetPassword extends StatelessWidget {
  const _WebResetPassword();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Card(
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(4))),
            elevation: 8,
            child: Container(
              width: 800,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context)
                                  .size
                                  .width -
                              50,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: AppColors.appPrimaryGreen,
                          ),
                        ),
                        Image.asset(
                          "images/agrokLogo.png",
                          width: 250,
                          height: 88,
                        )
                      ]),
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            "Reset password",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 26),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            "Please enter your email to reset your password.",
                            style:
                                TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const _EmailTextFormField(),
                  const SizedBox(
                    height: 50,
                  ),
                  TextButton(
                      onPressed: () {
                        context.read<ResetPasswordBloc>().add(
                            const ResetPasswordSubmitted());
                      },
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              AppColors.appPrimaryGreen,
                          padding: const EdgeInsets.all(15.0)),
                      child: const Text("Continue")),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextButton(
                        onPressed: () {
                          context.tryPop();
                        },
                        child: const Text(
                          "Back",
                          style: TextStyle(
                              color: AppColors.appPrimaryGreen,
                              fontSize: 16),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

class _MobileResetPassword extends StatelessWidget {
  const _MobileResetPassword();

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          const SizedBox(
            height: 150,
          ),
          const Row(
            children: [
              SizedBox(
                width: 25,
              ),
              Flexible(
                child: Text(
                  "Please enter your email to reset your password.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(
                width: 25,
              )
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 25, right: 25),
            child: _EmailTextFormField(),
          ),
          const SizedBox(
            height: 100,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            child: TextButton(
                onPressed: () {
                  context
                      .read<ResetPasswordBloc>()
                      .add(const ResetPasswordSubmitted());
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.appPrimaryGreen),
                child: const Text("Continue")),
          ),
        ],
      );
  }
}

class _EmailTextFormField extends StatelessWidget {
  const _EmailTextFormField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResetPasswordStatus status = context.select((ResetPasswordBloc bloc) => bloc.state.status);
    String? error = context.select((ResetPasswordBloc bloc) => bloc.state.email.error?.getDescription());
    return TextFormField(
      autofocus: true,
      style: const TextStyle(color: Colors.black),
      onFieldSubmitted: (_) => kIsWeb
          ? context
              .read<ResetPasswordBloc>()
              .add(const ResetPasswordSubmitted())
          : null,
      onChanged: (value) => context
          .read<ResetPasswordBloc>()
          .add(ResetPasswordEmailChanged(value)),
      decoration: InputDecoration(
        errorText: status == ResetPasswordStatus.failure ? error : null,
        labelText: "Email",
        border: const OutlineInputBorder(),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var status = context.select((ResetPasswordBloc bloc) => bloc.state.status);
    return Visibility(
        visible: status == ResetPasswordStatus.loading,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()),
        ));
  }
}
