import 'package:agro_k/app/routes.dart';
import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/screens/Auth/confirm_account/view/confirm_account_screen.dart';
import 'package:agro_k/screens/Auth/log_in/bloc/login_bloc.dart';
import 'package:agro_k/screens/Auth/sign_up/view/sign_up_screen.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/screens/Profile/mobile_user_profile_screen.dart';
import 'package:agro_k/screens/common/models/models.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../reset_password/view/reset_password_screen.dart';

class LogInScreen extends StatelessWidget {
  static const String id = '/log_in';

  static Widget withBloc() {
    return BlocProvider(
      create: (_) => LoginBloc(authService: getIt<AuthService>()),
      child: const LogInScreen(),
    );
  }

  const LogInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == LoginStatus.successUserVerified) {
          context.go(DashboardScreen.id);
        } else if (state.status == LoginStatus.successUserNotVerified) {
          context.pushNamed(ConfirmAccountScreen.id,
              extra: ConfirmAccountScreenArguments(
                  emailPhone: state.email.value));
        } else if (state.status == LoginStatus.failure &&
            state.errorMessage != null) {
          showOneButtonAlertDialog(context, "Ok", () {
            Navigator.pop(context);
          }, "Error", state.errorMessage!);
        }
      },
      child: const SelectionArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                      child: !kIsWeb ? _MobileLogIn() : _WebLogIn()),
                  _LoadingIndicator()
                ],
              ),
            )),
      ),
    );
  }
}

class _WebLogIn extends StatelessWidget {
  const _WebLogIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Card(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4))),
            elevation: 8,
            child: SizedBox(
              width: 800,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    height: 25,
                  ),
                  const Row(
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        "Analysis by Agro-K",
                        style: TextStyle(
                            color: AppColors.appPrimaryGreen, fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Row(
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Flexible(
                        child: Text(
                          "Know your crop's nutritional status before there is a problem.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 32),
                    child: Row(
                      children: [
                        Visibility(
                            visible: MediaQuery.of(context).size.width > 800,
                            child: Image.asset(
                              "images/loginImage.jpeg",
                              width: 365,
                              height: 426,
                              fit: BoxFit.fill,
                            )),
                        Expanded(
                          child: Column(
                            children: [
                              const Row(children: [
                                SizedBox(
                                  width: 25,
                                ),
                                Text(
                                  "Log In",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              ]),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  const Text(
                                    "Don't have an account?",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        context.pushNamed(SignUpScreen.id);
                                      },
                                      child: const Text(
                                        "Sign Up",
                                        style: TextStyle(
                                            color: AppColors.appPrimaryGreen,
                                            fontSize: 16),
                                      )),
                                ],
                              ),
                              const Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 20, left: 25, right: 25),
                                    child: _EmailTextFormField(),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 25, right: 25),
                                    child: _PasswordTextFormField(),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        context
                                            .pushNamed(ResetPasswordScreen.id);
                                      },
                                      child: const Text("Forgot your Password?",
                                          style: TextStyle(
                                              color: AppColors.appPrimaryGreen,
                                              fontSize: 16))),
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: TextButton(
                                    onPressed: () async {
                                      context.read<LoginBloc>().add(const LoginSubmitted());
                                    },
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            AppColors.appPrimaryGreen),
                                    child: const Text("Log in")),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              const Row(
                                children: [
                                  SizedBox(
                                    width: 25,
                                  ),
                                  Text(
                                    "This site is protected by Agro-K",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        goToPrivacyPolicy();
                                      },
                                      style: TextButton.styleFrom(
                                          foregroundColor:
                                              AppColors.appPrimaryGreen,
                                          textStyle:
                                              const TextStyle(fontSize: 14)),
                                      child: const Text("Privacy Policy")),
                                  const Text("and",
                                      style: TextStyle(color: Colors.grey)),
                                  TextButton(
                                      onPressed: () {
                                        goToTermsOfService(context);
                                      },
                                      style: TextButton.styleFrom(
                                          foregroundColor:
                                              AppColors.appPrimaryGreen,
                                          textStyle:
                                              const TextStyle(fontSize: 14)),
                                      child: const Text("Terms of Service")),
                                  const Text("apply",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordTextFormField extends StatelessWidget {
  const _PasswordTextFormField();

  @override
  Widget build(BuildContext context) {
    LoginStatus status = context.select((LoginBloc bloc) => bloc.state.status);
    String? error = context.select((LoginBloc bloc) => bloc.state.password.error?.getDescription());
    return TextFormField(
      obscureText: true,
      style: const TextStyle(color: Colors.black),
      onFieldSubmitted: (_) =>
          kIsWeb ? context.read<LoginBloc>().add(const LoginSubmitted()) : null,
      decoration: InputDecoration(
        errorText: status == LoginStatus.failure ? error : null,
        labelText: "Password",
        border: const OutlineInputBorder(),
        errorStyle: const TextStyle(color: Colors.red),
      ),
      onChanged: (value) {
        context.read<LoginBloc>().add(LoginPasswordChanged(value));
      },
    );
  }
}

class _EmailTextFormField extends StatelessWidget {
  const _EmailTextFormField();

  @override
  Widget build(BuildContext context) {
    LoginStatus status = context.select((LoginBloc bloc) => bloc.state.status);
    String? error = context.select((LoginBloc bloc) => bloc.state.email.error?.getDescription());
    return TextFormField(
      autofocus: true,
      style: const TextStyle(color: Colors.black),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) =>
          kIsWeb ? context.read<LoginBloc>().add(const LoginSubmitted()) : null,
      decoration: InputDecoration(
        errorText: status == LoginStatus.failure ? error : null,
        labelText: "Email",
        border: const OutlineInputBorder(),
        errorStyle: const TextStyle(color: Colors.red),
      ),
      onChanged: (value) {
        context.read<LoginBloc>().add(LoginEmailChanged(value));
      },
    );
  }
}

class _MobileLogIn extends StatelessWidget {
  const _MobileLogIn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 25,
        ),
        Stack(alignment: AlignmentDirectional.center, children: [
          Container(
            width: MediaQuery.of(context).size.width - 50,
            height: 90,
            color: AppColors.appPrimaryGreen,
          ),
          Image.asset("images/agrokLogo.png")
        ]),
        const SizedBox(
          height: 60,
        ),
        const Row(
          children: [
            SizedBox(
              width: 25,
            ),
            Text(
              "Analysis by Agro-K",
              style: TextStyle(color: AppColors.appPrimaryGreen, fontSize: 20),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        const Row(
          children: [
            SizedBox(
              width: 25,
            ),
            Flexible(
              child: Text(
                "Know your crop's nutritional status before there is a problem.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(
              width: 25,
            )
          ],
        ),
        const SizedBox(
          height: 80,
        ),
        const Row(children: [
          SizedBox(
            width: 25,
          ),
          Text(
            "Log In",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ]),
        Row(
          children: [
            const SizedBox(
              width: 25,
            ),
            const Text(
              "Don't have an account?",
              style: TextStyle(color: Colors.black),
            ),
            TextButton(
                onPressed: () {
                  context.pushNamed(SignUpScreen.id);
                },
                child: const Text(
                  "Sign Up",
                  style:
                      TextStyle(color: AppColors.appPrimaryGreen, fontSize: 16),
                )),
          ],
        ),
        const Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20, left: 25, right: 25),
              child: _EmailTextFormField(),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: _PasswordTextFormField(),
            ),
          ],
        ),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            TextButton(
                onPressed: () {
                  context.pushNamed(ResetPasswordScreen.id);
                },
                child: const Text("Forgot your Password?",
                    style: TextStyle(
                        color: AppColors.appPrimaryGreen, fontSize: 16))),
          ],
        ),
        const SizedBox(
          height: 40,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width - 50,
          child: TextButton(
              onPressed: () async {
                context.read<LoginBloc>().add(const LoginSubmitted());
              },
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.appPrimaryGreen),
              child: const Text("Log in")),
        ),
        const SizedBox(
          height: 40,
        ),
        const Row(
          children: [
            SizedBox(
              width: 25,
            ),
            Text(
              "This site is protected by Agro-K",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 20,
            ),
            TextButton(
                onPressed: () {
                  goToPrivacyPolicy();
                },
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.appPrimaryGreen,
                    textStyle: const TextStyle(fontSize: 14)),
                child: const Text("Privacy Policy")),
            const Text("and", style: TextStyle(color: Colors.grey)),
            TextButton(
                onPressed: () {
                  goToTermsOfService(context);
                },
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.appPrimaryGreen,
                    textStyle: const TextStyle(fontSize: 14)),
                child: const Text("Terms of Service")),
            const Text("apply", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }


}

void goToPrivacyPolicy() {
  const url =
      'https://agro-k.com/sapAnalysisApp/PrivacyPolicy.html';
  if (kIsWeb) {
    launchUrl(Uri.parse(url));
  } else {
    launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
  }
}

void goToTermsOfService(BuildContext context) {
  const url =
      'https://agro-k.com/sapAnalysisApp/TermsOfService.pdf';
  if (kIsWeb) {
    launchUrl(Uri.parse(url));
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PdfWebViewScreen(
                url: url,
                name: 'Terms of Service',
              )),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    var status =
        context.select<LoginBloc, LoginStatus>((bloc) => bloc.state.status);
    return Visibility(
        visible: status == LoginStatus.loading,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()),
        ));
  }
}
