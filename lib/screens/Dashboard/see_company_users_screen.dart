import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/screens/Profile/members_screen.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:flutter/material.dart';

class SeeCompanyUsersScreenArguments {
  final UserModel user;
  final CompanyModel farm;

  const SeeCompanyUsersScreenArguments(
      {required this.user, required this.farm});
}

class SeeCompanyUsersScreen extends StatelessWidget {
  static const id = "/see_company_users";
  final UserModel user;
  final CompanyModel farm;
  const SeeCompanyUsersScreen(
      {Key? key, required this.user, required this.farm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              context.goBackWeb();
            },
          ),
          backgroundColor: AppColors.appPrimaryGreen,
          centerTitle: true,
          title: const Text("See Company Users"),
        ),
        backgroundColor: Colors.white,
        body: MembersScreen(user: user, company: farm));
  }
}
