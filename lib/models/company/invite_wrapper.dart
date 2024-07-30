import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/invites/invites_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';

class InviteWrapper {
  final InvitesModel invite;
  final String id;

  InviteWrapper({required this.invite, required this.id});

  Future<InvitesWrapperWithCompany?> toInvitesModelWithCompany() async {
    try {
      DocumentSnapshot companySnapshot = await invite.invitedTo.get();
      if (companySnapshot.exists) {
        Map<String, dynamic>? data =
        companySnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          CompanyModel company = CompanyModel.fromJson(data);
          return InvitesWrapperWithCompany(isAdmin: invite.isAdmin, email: invite.email, company: company, created: invite.created, id: id);
        }
      }
      return null;
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>()
          .recordError(exception, stacktrace);
      return null;
    }
  }
}

class InvitesWrapperWithCompany {
  bool isAdmin;
  String email;
  CompanyModel company;
  DateTime created;
  String id;

  InvitesWrapperWithCompany({required this.isAdmin, required this.email, required this.company, required this.created, required this.id});
}