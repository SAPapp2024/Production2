import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart' hide Environment;
import 'package:uuid/uuid.dart';

@injectable
class MembersService {
  Future<Set<List<dynamic>>> getMembersOfCompanym(
      {required CompanyModel company}) async {
    try {
      List<UserModel> activeCompanyMembers = [];
      List<String> invitedCompanyMembers = [];
      for (var i = 0; i < company.users.length; i++) {
        DocumentReference<Map<String, dynamic>> userReference =
            company.users[i] as DocumentReference<Map<String, dynamic>>;
        var userSnapshot = await userReference.get();
        if (userSnapshot.exists) {
          Map<String, dynamic>? data = userSnapshot.data();
          if (data != null) {
            UserModel companyMember = UserModel.fromJson(data);
            activeCompanyMembers.add(companyMember);
          }
        }
      }

      //get the email for each member in the company that has been invited
      var invitedValue = company.invitedUsers?.values.toList();

      if (invitedValue != null) {
        for (var i = 0; i < invitedValue.length; i++) {
          var userEmail = invitedValue[i].invitedEmail;
          invitedCompanyMembers.add(userEmail);
        }
      }

      return {activeCompanyMembers, invitedCompanyMembers};
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

  Future<Set<List<dynamic>>> getMembersOfCompany({required UserModel user, required CompanyModel company}) async {
    try {
      List<UserModel> activeCompanyMembers = [];
      List<String> invitedCompanyMembers = [];
      //Get the company data
      var companyReference =
      FirebaseFirestore.instance.collection("companies").doc(company.id);
      var companySnapshot = await companyReference.get();
      if (companySnapshot.exists) {
        Map<String, dynamic>? data = companySnapshot.data();
        if (data != null) {
          CompanyModel company = CompanyModel.fromJson(data);

          //get the data for each member in the company that has an account
          for (var i = 0; i < company.users.length; i++) {
            DocumentReference<Map<String, dynamic>> userReference =
                company.users[i] as DocumentReference<Map<String, dynamic>>;
            var userSnapshot = await userReference.get();
            if (userSnapshot.exists) {
              Map<String, dynamic>? data = userSnapshot.data();
              if (data != null) {
                UserModel companyMember = UserModel.fromJson(data);
                activeCompanyMembers.add(companyMember);
              }
            }
          }

          //get the email for each member in the company that has been invited
          var invitedValue = company.invitedUsers?.values.toList();

          if (invitedValue != null) {
            for (var i = 0; i < invitedValue.length; i++) {
              var userEmail = invitedValue[i].invitedEmail;
              invitedCompanyMembers.add(userEmail);
            }
          }
        }
      }
      return {activeCompanyMembers, invitedCompanyMembers};
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

  Future<void> inviteMembersToCompany(
      String invitedEmail, CompanyModel company, Environment environment) async {
    try {
      var uuid = const Uuid().v4();
      DocumentReference inviteReference =
          FirebaseFirestore.instance.collection("invites").doc(uuid);
      var timestamp = DateTime.now();
      DocumentReference companyReference =
          FirebaseFirestore.instance.collection("companies").doc(company.id);

      var repeatedInviteDocs = await FirebaseFirestore.instance.collection("invites").where("email", isEqualTo: invitedEmail).where("invitedTo", isEqualTo: companyReference).get();

      if (repeatedInviteDocs.size > 0) {
        throw Exception("This user has already been invited");
      }

      var batch = FirebaseFirestore.instance.batch();
      var inviteData = {
        'email': invitedEmail,
        'invitedTo': companyReference,
        'isAdmin': false,
        'created': timestamp,
      };

      batch.set(inviteReference, inviteData);

      var invitedUser = {
        'invitedEmail': invitedEmail,
        'invitesReference': inviteReference,
        'created': timestamp
      };

      batch.update(companyReference, {'invitedUsers.$uuid': invitedUser});
      await batch.commit();

      await _sendEmailInvite(invitedEmail, company.name, environment);
      debugPrint("4");
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<void> _sendEmailInvite(String invitedEmail, String companyName, Environment environment) async {
    String testFlight;
    debugPrint(environment.name);
    switch (environment) {
      case Environment.qa:
        testFlight = "https://testflight.apple.com/join/CpCItaRt";
        break;
      case Environment.prod:
        testFlight = "https://apps.apple.com/app/Sap-Analysis/id1624143700";
        break;
    }

    var mailData = {
      'to': invitedEmail,
      'message': {
        "subject": "$companyName Invite: Sap Application",
        "html":
            """<p>$companyName Admin has invited you to their company at SAP application.</p><p>Please install the SAP App and Sign up with this email address where you received the invite.</p><p><a href="https://play.google.com/store/apps/details?id=com.agrok.SapAnalysis">Google Play Store</a></p>
      <p><a href=$testFlight>App Store</a></p>"""
      },
    };

    await FirebaseFirestore.instance.collection("mail").doc().set(mailData);
  }

}
