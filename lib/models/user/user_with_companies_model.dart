import 'package:agro_k/models/user/user_company_model.dart';
import 'package:agro_k/models/user/user_model.dart';

class UserWithCompaniesModel {
  UserModel user;
  List<UserCompanyModel> companies;

  UserWithCompaniesModel({
    required this.user,
    required this.companies,
  });
}