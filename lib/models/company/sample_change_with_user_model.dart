import 'package:agro_k/models/company/sample_change_model.dart';
import 'package:agro_k/models/user/user_model.dart';

class SampleChangeWithUserModel {
  SampleChangeModel sampleChangeModel;
  UserModel? user;

  SampleChangeWithUserModel({required this.sampleChangeModel, required this.user});
}