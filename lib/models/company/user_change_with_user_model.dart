import 'package:agro_k/models/user/user_change_model.dart';
import 'package:agro_k/models/user/user_model.dart';

class UserChangeWithUserModel {
  UserChangeModel userChangeModel;
  UserModel? user;

  UserChangeWithUserModel({required this.userChangeModel, required this.user});
}