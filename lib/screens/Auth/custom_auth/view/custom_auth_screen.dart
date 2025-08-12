
import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/screens/Auth/custom_auth/bloc/custom_auth_bloc.dart';
import 'package:agro_k/screens/Auth/log_in/view/log_in_screen.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAuthActionScreen extends StatelessWidget {
  static const String id = '/auth';

  const CustomAuthActionScreen({super.key});

  static Widget withBloc({required String oobCode, required String actionType}) {
    return BlocProvider(
      create: (context) => CustomAuthBloc(
          authService: getIt.get<AuthService>(),
          oobCode: oobCode,
          actionType: actionType)
        ..add(const SubmitOobCode()),
      child: const CustomAuthActionScreen(),
    );
  }

  Widget authActionResultContainer(String message, BuildContext context, bool showOpenApp) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
                color: AppColors.black1,
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton(
            onPressed: () async {
              if (showOpenApp) {
                final url = Uri.parse("https://SAPapp2024.github.io/agrok");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  if (!context.mounted) return;
                  context.goNamed(LogInScreen.id);
                }
              } else {
                context.goNamed(LogInScreen.id);
              }
            },
            child: Text(
              showOpenApp ? "Open App" : "Log In",
              style: const TextStyle(color: AppColors.appPrimaryGreen, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget resetPasswordContainer(String? email, BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
      child: !kIsWeb
          ? Column(
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
                        email != null
                            ? "Please set a new password for $email."
                            : "Please set a new password.",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(
                      width: 25,
                    )
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: _PasswordTextFormField(),
                ),
                const SizedBox(
                  height: 100,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width - 50,
                    child: TextButton(
                        onPressed: () {
                          context
                              .read<CustomAuthBloc>()
                              .add(const SubmitNewPassword());
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.appPrimaryGreen),
                        child: const Text("Continue"))),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextButton(
                      onPressed: () {
                        context.goNamed(LogInScreen.id);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                            color: AppColors.appPrimaryGreen, fontSize: 16),
                      )),
                ),
              ],
            )
          : Center(
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
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 50,
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
                                  "Set new password",
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
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  email != null
                                      ? "Please set a new password for $email."
                                      : "Please set a new password.",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              const SizedBox(
                                width: 25,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        const _PasswordTextFormField(),
                        const SizedBox(
                          height: 50,
                        ),
                        TextButton(
                            onPressed: () {
                              debugPrint("Debug error reset password 4");
                              context
                                  .read<CustomAuthBloc>()
                                  .add(const SubmitNewPassword());
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppColors.appPrimaryGreen,
                                padding: const EdgeInsets.all(15.0)),
                            child: const Text("Continue")),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TextButton(
                              onPressed: () {
                                context.goNamed(LogInScreen.id);
                              },
                              child: const Text(
                                "Cancel",
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
            ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    CustomAuthState state = context.select((CustomAuthBloc bloc) => bloc.state);
    bool showOpenApp = state.showOpenAppButton;
    Widget body;
    switch (state.status) {
      case CustomAuthStatus.loading:
        body = Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()),
        );
        break;
      case CustomAuthStatus.canResetPassword:
        debugPrint("Debug error reset password 3");
        body = resetPasswordContainer(state.email, context);
        break;
      case CustomAuthStatus.successResetPassword:
        body = authActionResultContainer(
            "Password changed successfully.", context, showOpenApp);
        break;
      case CustomAuthStatus.successVerifyEmail:
        body =
            authActionResultContainer("Email verified successfully.", context, showOpenApp);
        break;
      case CustomAuthStatus.expiredCode:
        body = authActionResultContainer("The code is expired.", context, showOpenApp);
        break;
      case CustomAuthStatus.invalidCode:
        body = authActionResultContainer(
            state.email != null
                ? "User is already verified."
                : "The code is not valid.",
            context, showOpenApp);
        break;
      case CustomAuthStatus.disabledUser:
        body = authActionResultContainer("This user is not enabled", context, showOpenApp);
        break;
      case CustomAuthStatus.userNotFound:
        body = authActionResultContainer("User not found.", context, showOpenApp);
        break;
      case CustomAuthStatus.genericError:
        body = authActionResultContainer("There was an error.", context, showOpenApp);
        break;
      case CustomAuthStatus.invalidPassword:
        body = authActionResultContainer("Password can't be empty.", context, showOpenApp);
        break;
      case CustomAuthStatus.goLogin:
        context.go(DashboardScreen.id);
        return Container();
    }
    return Scaffold(
      body: body,
    );
  }
}

class _PasswordTextFormField extends StatelessWidget {
  const _PasswordTextFormField();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      style: const TextStyle(color: Colors.black),
      obscureText: true,
      onChanged: (value) {
        context.read<CustomAuthBloc>().add(PasswordChanged(value));
      },
      decoration: const InputDecoration(
        labelText: "New Password",
        border: OutlineInputBorder(),
        errorStyle: TextStyle(color: Colors.red),
      ),
    );
  }
}
