import 'package:agro_k/models/company/company_change_with_user_model.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SeeCompanyChangesScreenArguments {
  final List<CompanyChangeWithUserModel> companyChanges;

  const SeeCompanyChangesScreenArguments({required this.companyChanges});
}

class SeeCompanyChangesScreen extends StatefulWidget {
  static const id = "/see_company_changes";
  final List<CompanyChangeWithUserModel> companyChanges;

  const SeeCompanyChangesScreen({Key? key, required this.companyChanges})
      : super(key: key);

  @override
  State<SeeCompanyChangesScreen> createState() =>
      _SeeCompanyChangesScreenState();
}

class _SeeCompanyChangesScreenState extends State<SeeCompanyChangesScreen> {
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
        title: const Text("Company changes"),
      ),
      backgroundColor: AppColors.pageBackground,
      body: widget.companyChanges.isNotEmpty
          ? ListView.builder(
              itemCount: widget.companyChanges.length,
              itemBuilder: (BuildContext context, int index) {
                CompanyChangeWithUserModel companyChange =
                    widget.companyChanges[index];
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 500,
                      child: Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text("Change made by:",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.black1,
                                            fontWeight: FontWeight.w600)),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(companyChange.user != null
                                            ? "${companyChange.user!.firstName} ${capitalizeLastWord(companyChange.user!.lastName ?? "")}"
                                            : "N/A"),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      const Text("Change date:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.black1,
                                              fontWeight: FontWeight.w600)),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(DateFormat.yMd().format(
                                              companyChange.companyChangeModel
                                                  .changeDate)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 12.0),
                                  child: Text("Company changes",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: AppColors.black1,
                                          fontWeight: FontWeight.w700)),
                                ),
                                showChangeIfExists(
                                    "Phone",
                                    companyChange
                                        .companyChangeModel.oldState.phone
                                        ?.getFullPhoneNumber(),
                                    companyChange
                                        .companyChangeModel.newState.phone
                                        ?.getFullPhoneNumber()),
                                showChangeIfExists(
                                    "Alternate Phone",
                                    companyChange.companyChangeModel.oldState
                                        .alternatePhone
                                        ?.getFullPhoneNumber(),
                                    companyChange.companyChangeModel.newState
                                        .alternatePhone
                                        ?.getFullPhoneNumber()),
                                showChangeIfExists(
                                    "Address",
                                    companyChange
                                        .companyChangeModel.oldState.address,
                                    companyChange
                                        .companyChangeModel.newState.address),
                                showChangeIfExists(
                                    "City",
                                    capitalizeLastWord(companyChange
                                            .companyChangeModel.oldState.city ??
                                        ""),
                                    capitalizeLastWord(companyChange
                                            .companyChangeModel.newState.city ??
                                        "")),
                                showChangeIfExists(
                                    "Name",
                                    companyChange
                                        .companyChangeModel.oldState.name
                                        .toString(),
                                    companyChange
                                        .companyChangeModel.newState.name
                                        .toString()),
                                showChangeIfExists(
                                    "Zipcode",
                                    companyChange
                                        .companyChangeModel.oldState.zipcode,
                                    companyChange
                                        .companyChangeModel.newState.zipcode),
                                showChangeIfExists(
                                    "Company Admin",
                                    companyChange.companyChangeModel.oldState
                                        .companyAdminUserInfo?.fullName,
                                    companyChange.companyChangeModel.newState
                                        .companyAdminUserInfo?.fullName),
                              ],
                            ),
                          )),
                    ),
                  ),
                );
              })
          : Container(),
    );
  }

  Widget showChangeIfExists(String title, String? oldValue, String? newValue) {
    if (oldValue == newValue) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$title:",
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black1,
                    fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(
                    child: Text(
                  oldValue ?? "No value",
                  textAlign: TextAlign.center,
                )),
                const Icon(Icons.arrow_right_alt_outlined),
                Expanded(
                    child: Text(newValue ?? "No value",
                        textAlign: TextAlign.center))
              ],
            )
          ],
        ),
      );
    }
  }

  Widget showPhotoChangeIfExists(
      String title, String? oldValue, String? newValue) {
    if (oldValue == newValue) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$title:",
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black1,
                    fontWeight: FontWeight.w600)),
            Row(
              children: [
                oldValue != null
                    ? Image.asset(oldValue)
                    : Expanded(
                        child: Text(
                        oldValue ?? "No Photo",
                        textAlign: TextAlign.center,
                      )),
                const Icon(Icons.arrow_right_alt_outlined),
                newValue != null
                    ? Image.asset(newValue)
                    : Expanded(
                        child: Text(
                        newValue ?? "No Photo",
                        textAlign: TextAlign.center,
                      )),
              ],
            )
          ],
        ),
      );
    }
  }
}
