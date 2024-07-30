import 'package:agro_k/app/routes.dart';
import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/screens/Auth/confirm_account/view/confirm_account_screen.dart';
import 'package:agro_k/screens/Auth/log_in/view/log_in_screen.dart';
import 'package:agro_k/screens/Auth/sign_up/bloc/sign_up_bloc.dart';
import 'package:agro_k/screens/common/models/models.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatelessWidget {
  static const String id = '/sign_up';

  const SignUpScreen({super.key});

  static Widget withBloc() {
    return BlocProvider(
      create: (context) => SignUpBloc(
        authService: getIt.get(),
      ),
      child: const SignUpScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listenWhen: (previous, current) =>
          previous.status != current.status,
      listener: (context, state) {
        if (state.status == SignUpStatus.success) {
          context.goNamed(ConfirmAccountScreen.id,
              extra: ConfirmAccountScreenArguments(
                  emailPhone: state.email.value,));
        } else if (state.status == SignUpStatus.failure &&
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
                child: !kIsWeb
                    ? _MobileSignUp()
                    : _WebSignUp(),
              ),
              _LoadingIndicator()
            ],
          )),
        ),
      ),
    );
  }
}

class _WebSignUp extends StatelessWidget {
  const _WebSignUp();

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
                children: <Widget>[
                  Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context)
                                  .size
                                  .width -
                              50,
                          height: 90,
                          color: AppColors.appPrimaryGreen,
                        ),
                        Image.asset("images/agrokLogo.png")
                      ]),
                  const SizedBox(
                    height: 20,
                  ),
                  const Row(children: [
                    Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 26),
                    ),
                  ]),
                  Row(
                    children: [
                      const Text(
                        "Already a member?",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                          onPressed: () {
                            context.go(LogInScreen.id);
                          },
                          child: const Text(
                            "Log In",
                            style: TextStyle(
                                color:
                                    AppColors.appPrimaryGreen,
                                fontSize: 16),
                          )),
                    ],
                  ),
                  const Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _FirstNameTextFormField(),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: _LastNameTextFormField(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _EmailTextFormField(),
                      SizedBox(
                        height: 20,
                      ),
                      _PasswordTextFormField(),
                      SizedBox(
                        height: 20,
                      ),
                      _ConfirmPasswordTextFormField(),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width:
                        MediaQuery.of(context).size.width - 50,
                    child: TextButton(
                        onPressed: () {
                          context
                              .read<SignUpBloc>()
                              .add(const SignUpSubmitted());
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                AppColors.appPrimaryGreen,
                            padding: const EdgeInsets.all(15)),
                        child: const Text("Next")),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

class _MobileSignUp extends StatelessWidget {
  const _MobileSignUp();

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          const SizedBox(
            height: 25,
          ),
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
            height: 80,
          ),
          const Row(children: [
            SizedBox(
              width: 25,
            ),
            Text(
              "Sign Up",
              style:
                  TextStyle(color: Colors.black, fontSize: 20),
            ),
          ]),
          Row(
            children: [
              const SizedBox(
                width: 25,
              ),
              const Text(
                "Already a member?",
                style: TextStyle(color: Colors.black),
              ),
              TextButton(
                  onPressed: () {
                    context.go(LogInScreen.id);
                  },
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                        color: AppColors.appPrimaryGreen,
                        fontSize: 16),
                  )),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, left: 25, right: 25),
                child: Row(
                  children: [
                    SizedBox(
                      width:
                          (MediaQuery.of(context).size.width -
                                  75) /
                              2,
                      child: const _FirstNameTextFormField(),
                    ),
                    const SizedBox(width: 25),
                    SizedBox(
                      width:
                          (MediaQuery.of(context).size.width -
                                  75) /
                              2,
                      child: const _LastNameTextFormField(),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.only(
                    top: 20, left: 25, right: 25),
                child: _EmailTextFormField(),
              ),
              const SizedBox(
                height: 25,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: _PasswordTextFormField(),
              ),
              const SizedBox(
                height: 25,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: _ConfirmPasswordTextFormField(),
              ),
            ],
          ),
          const SizedBox(
            height: 100,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            child: TextButton(
                onPressed: () {
                  context
                      .read<SignUpBloc>()
                      .add(const SignUpSubmitted());
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.appPrimaryGreen),
                child: const Text("Next")),
          ),
        ],
      );
  }
}

class _FirstNameTextFormField extends StatelessWidget {
  const _FirstNameTextFormField();

  @override
  Widget build(BuildContext context) {
    SignUpStatus status = context.select((SignUpBloc bloc) => bloc.state.status);
    String? error = context.select((SignUpBloc bloc) => bloc.state.firstName.error?.getDescription("First name"));
    return TextFormField(
      autofocus: true,
      onChanged: (value) {
        context.read<SignUpBloc>().add(SignUpFirstNameChanged(value));
      },
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        errorText: status == SignUpStatus.failure ? error : null,
        labelText: "First Name",
        border: const OutlineInputBorder(),
        errorStyle:  const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _LastNameTextFormField extends StatelessWidget {
  const _LastNameTextFormField();

  @override
  Widget build(BuildContext context) {
    SignUpStatus status = context.select((SignUpBloc bloc) => bloc.state.status);
    String? error = context.select((SignUpBloc bloc) => bloc.state.lastName.error?.getDescription("Last name"));
    return TextFormField(
      onChanged: (value) {
        context.read<SignUpBloc>().add(SignUpLastNameChanged(value));
      },
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        errorText: status == SignUpStatus.failure ? error : null,
        labelText: "Last Name",
        border: const OutlineInputBorder(),
        errorStyle:  const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _ConfirmPasswordTextFormField extends StatelessWidget {
  const _ConfirmPasswordTextFormField();

  @override
  Widget build(BuildContext context) {
    SignUpStatus status = context.select((SignUpBloc bloc) => bloc.state.status);
    String? error = context.select((SignUpBloc bloc) => bloc.state.confirmPassword.error?.getDescription());
    return TextFormField(
      onChanged: (value) {
        context.read<SignUpBloc>().add(SignUpConfirmPasswordChanged(value));
      },
      obscureText: true,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        errorText: status == SignUpStatus.failure ? error : null,
        labelText: "Confirm Password",
        border: const OutlineInputBorder(),
        errorStyle:  const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _PasswordTextFormField extends StatelessWidget {
  const _PasswordTextFormField();

  @override
  Widget build(BuildContext context) {
    SignUpStatus status = context.select((SignUpBloc bloc) => bloc.state.status);
    String? error = context.select((SignUpBloc bloc) => bloc.state.password.error?.getDescription());
    return TextFormField(
      onChanged: (value) {
        context.read<SignUpBloc>().add(SignUpPasswordChanged(value));
      },
      obscureText: true,
      style: const TextStyle(color: Colors.black),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        errorText: status == SignUpStatus.failure ? error : null,
        labelText: "Password",
        border: const OutlineInputBorder(),
        errorStyle:  const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _EmailTextFormField extends StatelessWidget {
  const _EmailTextFormField();

  @override
  Widget build(BuildContext context) {
    SignUpStatus status = context.select((SignUpBloc bloc) => bloc.state.status);
    String? error = context.select((SignUpBloc bloc) => bloc.state.email.error?.getDescription());
    return TextFormField(
      onChanged: (value) {
        context.read<SignUpBloc>().add(SignUpEmailChanged(value));
      },
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        errorText: status == SignUpStatus.failure ? error : null,
        labelText: "Email",
        border:  const OutlineInputBorder(),
        errorStyle:  const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var status = context.select((SignUpBloc bloc) => bloc.state.status);
    return Visibility(
        visible: status == SignUpStatus.loading,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()),
        ));
  }
}
