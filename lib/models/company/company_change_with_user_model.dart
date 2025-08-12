import 'package:agro_k/models/user/company_change_model.dart';
import 'package:agro_k/models/user/user_model.dart';

class CompanyChangeWithUserModel {
  UserModel? user;
  CompanyChangeModel companyChangeModel;

  CompanyChangeWithUserModel({required this.companyChangeModel, required this.user});
}
