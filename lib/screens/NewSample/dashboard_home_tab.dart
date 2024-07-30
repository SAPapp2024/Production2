import 'package:agro_k/components/company_card.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/screens/CompanyTab/purchase_barcodes_screen.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'company_samples_screen.dart';
import 'new_sample_screen.dart';

class DashboardHomeTabWidget extends StatelessWidget {
  final UserModel user;
  final CompanyModel? company;

  const DashboardHomeTabWidget(
      {Key? key, required this.user, required this.company})
      : super(key: key);

  Widget companyCard(BuildContext context, CompanyModel company) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 8, right: 8, top: 20),
      child: CompanyCard(
        company: company,
        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 40),
        showRemainingBarcodesCount: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
                user.isSuperAdmin ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text("Super Admin Account",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold, fontSize: 24)),
                ) : company == null ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Text("Guest Account",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold, fontSize: 22)),
                      SizedBox(height: 16,),
                      Text("""In order to submit samples on your account you will need to

      1. Create a Company - you can create a company by selecting ‘Create Company’ in the drop down in the top right corner.

      2. Wait to be invited to a Company - share your email with the company owner you are waiting to be associated with. You can join from your profile section once you are invited.""",
                          style: TextStyle(
                              color: AppColors.black1,
                              fontWeight: FontWeight.normal, fontSize: 16)),
                    ],
                  ),
                ) : companyCard(context, company!),
            const SizedBox(height: 24,),
            SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: PrimaryButton(
                  onPressed: company != null ? () {
                    context.pushNamed(CompanySamplesScreen.id);
                  } : null,
                  actionType: PrimaryButtonActionType.positive,
                  type: PrimaryButtonType.outlined,
                  title:
                    "Sample management",
                )),
            const SizedBox(height: 12.0,),
            SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: PrimaryButton(
                  type: PrimaryButtonType.filled,
                  actionType: PrimaryButtonActionType.positive,
                  onPressed: company != null ? () {
                    if (company!.availableBarcodesCount == 0) {
                      showTwoButtonAlertDialog(context, "Buy Barcodes", () {
                        Navigator.pop(context);
                        context.goNamed(PurchaseBarcodesScreen.id);
                      }, "Cancel", () {
                        Navigator.pop(context);
                      }, "Error",
                          "This company doesn’t have any barcodes available. You have to buy barcodes before collecting new samples.");
                    } else {
                      context.pushNamed(NewSampleScreen.id, extra: {'populateFields': false});
                    }
                  } : null,
                  title:
                  "Collect samples",
                )),
            const SizedBox(height: 24.0,),
          ],
        ),
      ),
    );
  }
}
