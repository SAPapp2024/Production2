import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/models/company/company_admin_user_info.dart';
import 'package:agro_k/models/company/company_change_with_user_model.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/invite_wrapper.dart';
import 'package:agro_k/models/company/sample_model.dart';
import 'package:agro_k/models/company/user_change_with_user_model.dart';
import 'package:agro_k/models/invites/invites_model.dart';
import 'package:agro_k/models/user/company_change_model.dart';
import 'package:agro_k/models/user/notification_settings_model.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/models/user/user_change_model.dart';
import 'package:agro_k/models/user/user_farm_references_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/models/user/user_with_companies_model.dart';
import 'package:agro_k/services/Database/app_database.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/exceptions.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/sample_sorting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@injectable
class AuthService {
  final AppDatabase database = AppDatabase();
  final SampleService sampleService = SampleService();

  Future<void> signUp(
      {required String firstName,
      required String lastName,
      required String? email,
      required PhoneModel? phone,
      required String password}) async {
    try {
      UserCredential? user;
      if (email != null) {
        user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        //Feature not approved yet...work on this later
        //TODO: - This needs work
        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber:
                phone != null ? "${phone.phoneAreaCode}${phone.phone}" : "",
            timeout: const Duration(seconds: 60),
            verificationCompleted: (AuthCredential credential) async {},
            verificationFailed: (exception) {
              debugPrint("$exception");
            },
            codeSent: (a, b) {},
            codeAutoRetrievalTimeout: (a) {});

        user = null;
      }
      //need to safe unwrap user
      await createUserInDB(
          user: user!,
          firstName: firstName,
          lastName: capitalizeLastWord(lastName),
          email: email,
          phone: phone);
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

  Stream<Future<List<InvitesWrapperWithCompany>>> getUserCompanyInvites(
      String email) {
    try {
      return FirebaseFirestore.instance
          .collection('invites')
          .snapshots()
          .map((invitesListDocs) async {
        var invitesList = invitesListDocs.docs;
        final List<InvitesWrapperWithCompany> res = [];
        for (var i = 0; i < invitesList.length; i++) {
          var values = invitesList[i];
          var data = InvitesModel.fromJson(values.data());
          if (email.toLowerCase() == data.email.toLowerCase()) {
            try {
              InvitesWrapperWithCompany? invite =
                  await InviteWrapper(invite: data, id: values.id)
                      .toInvitesModelWithCompany();
              if (invite != null) {
                res.add(invite);
              }
            } catch (exception, stacktrace) {
              getIt
                  .get<RemoteErrorLoggingService>()
                  .recordError(exception, stacktrace);
            }
          }
        }
        return res;
      });
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future _removeFromInvites(
      DocumentReference invitedTo, String inviteId) async {
    var inviteRef =
        FirebaseFirestore.instance.collection("invites").doc(inviteId);
    await inviteRef.delete();
    await invitedTo.update({'invitedUsers.$inviteId': FieldValue.delete()});
  }

  Future<void> removeMemberInvite(
      String invitedEmail, CompanyModel farm) async {
    var companyReference =
        FirebaseFirestore.instance.collection("companies").doc(farm.id);
    var inviteRef = (await FirebaseFirestore.instance
            .collection("invites")
            .where("email", isEqualTo: invitedEmail)
            .where("invitedTo", isEqualTo: companyReference)
            .get())
        .docs
        .firstOrNull;
    if (inviteRef != null) {
      String inviteId = inviteRef.reference.id;
      await _removeFromInvites(companyReference, inviteId);
    }
  }

  Future _addToCompanyMembers(
      DocumentReference invitedTo, String userId) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection("users").doc(userId);
    invitedTo.update({
      'users': FieldValue.arrayUnion([userRef])
    });
  }

  Future updateNotificationToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      var query = await FirebaseFirestore.instance
          .collection("users")
          .where('deviceTokens', arrayContains: token)
          .get();
      await Future.wait(query.docs.map((userDoc) async {
        userDoc.reference.update({
          'deviceTokens': FieldValue.arrayRemove([token])
        }); //Deleting this device token from all other users
      }));
      DocumentReference userRef =
          FirebaseFirestore.instance.collection("users").doc(userId);
      await userRef.update({
        'deviceTokens': FieldValue.arrayUnion([token])
        //Adding device token to this user
      });
    }
  }

  Future deleteNotificationToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      var query = await FirebaseFirestore.instance
          .collection("users")
          .where('deviceTokens', arrayContains: token)
          .get();
      await Future.wait(query.docs.map((userDoc) async {
        userDoc.reference.update({
          'deviceTokens': FieldValue.arrayRemove([token])
        }); //Deleting this device token from all other users
      }));
    }
  }

  Future logout() async {
    await FirebaseAuth.instance.signOut();
    await deleteNotificationToken();
    await database.deleteCurrentCompany();
  }

  //This creates company admin permission.
  Future createUserInDB(
      {required UserCredential user,
      required String firstName,
      required String lastName,
      required String? email,
      required PhoneModel? phone}) async {
    try {
      var set = {
        'id': user.user!.uid,
        'firstName': capitalize(firstName),
        'lastName': lastName,
        'phone': phone == null
            ? null
            : {
                "phone": phone.phone,
                "phoneAreaCode": phone.phoneAreaCode,
                "phoneCountryISOName": phone.phoneCountryISOName,
              },
        'email': email ?? "",
        'created': user.user!.metadata.creationTime,
        'lastConnection': user.user!.metadata.creationTime,
        'deviceTokens': [],
        'notifications': [],
        'isConfirmed': false,
        'companyReferences': [],
        'isSuperAdmin': false,
        'notificationSettings': NotificationSettingsModel(
                sampleStarted: true,
                sampleStartedEmail: true,
                sampleComplete: true,
                sampleCompleteEmail: true,
                daysSinceSampleStart: true,
                daysSinceSampleStartEmail: true,
                sampleCancelled: true,
                sampleCancelledEmail: true)
            .toMap(),
        'enabled': true
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user?.uid)
          .set(set);
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<void> respondUserCompanyInvitation(
      CompanyModel farm, String inviteId, String uid, bool accepted) async {
    DocumentReference companyReference =
        FirebaseFirestore.instance.collection("companies").doc(farm.id);
    if (accepted) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'companyReferences': FieldValue.arrayUnion([
          UserCompanyReferencesModel(
                  companyReference: companyReference,
                  isAdmin: false,
                  companyName: farm.name)
              .toJson()
        ])
      });
      await _addToCompanyMembers(companyReference, uid);
    }
    await _removeFromInvites(companyReference, inviteId);
  }

  Future<void> removeUserFromCompany(String uid, CompanyModel farmModel) async {
    var userReference = FirebaseFirestore.instance.collection("users").doc(uid);
    var companyReference =
        FirebaseFirestore.instance.collection("companies").doc(farmModel.id);
    var userDoc = await userReference.get();
    var userData = userDoc.data();
    if (userData != null) {
      var userModel = UserModel.fromJson(userData);
      var userCompanyReference = userModel.companyReferences
          .where((element) => element.companyReference == companyReference)
          .firstOrNull;
      companyReference.update({
        'users': FieldValue.arrayRemove([userReference])
      });
      userReference.update({
        'companyReferences':
            FieldValue.arrayRemove([userCompanyReference?.toJson()])
      });
    }
  }

  Future<void> assignSampleToUser(UserModel? user, SampleModel sample) async {
    var userRef = user != null
        ? FirebaseFirestore.instance.collection("users").doc(user.id)
        : null;
    await FirebaseFirestore.instance
        .collection("samples")
        .doc(sample.id)
        .update({"assignedTo": userRef});
  }

  Future<String?> createCompanyInDB(
      {String? uid,
      required String companyName,
      required String companyAddress,
      required String companyCity,
      required String companyState,
      required String companyZip,
      required String companyCountry,
      PhoneModel? companyPhone,
      PhoneModel? companyAltPhone}) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection("users").doc(uid);
      var userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? data =
            userSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          var uuid = const Uuid().v4();
          var farmData = CompanyModel(
                  id: uuid,
                  name: companyName,
                  address: companyAddress,
                  city: companyCity,
                  state: companyState,
                  zipcode: companyZip,
                  country: companyCountry,
                  phone: companyPhone == null
                      ? null
                      : PhoneModel(
                          phone: companyPhone.phone,
                          phoneAreaCode: companyPhone.phoneAreaCode,
                          phoneCountryISOName: companyPhone.phoneCountryISOName,
                        ),
                  alternatePhone: companyAltPhone == null
                      ? null
                      : PhoneModel(
                          phone: companyAltPhone.phone,
                          phoneAreaCode: companyAltPhone.phoneAreaCode,
                          phoneCountryISOName:
                              companyAltPhone.phoneCountryISOName,
                        ),
                  created: DateTime.now(),
                  users: [userRef],
                  locations: {},
                  crops: {},
                  fields: {},
                  growers: {},
                  assignableBarcodes: [],
                  barcodesPurchased: 0,
                  barcodesAssigned: 0,
                  usedBarcodesCount: 0,
                  invitedUsers: {},
                  companyAdminUserInfo: CompanyAdminUserInfo(
                      userReference: userRef,
                      email: data["email"],
                      fullName: "${data["firstName"]} ${data["lastName"]}"),
                  type: CompanyTypeConstants.ccc)
              .toJson();
          await FirebaseFirestore.instance
              .collection('companies')
              .doc(uuid)
              .set(farmData);
          DocumentReference farmRef =
              FirebaseFirestore.instance.collection("companies").doc(uuid);
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'companyReferences': FieldValue.arrayUnion([
              UserCompanyReferencesModel(
                      companyReference: farmRef,
                      isAdmin: true,
                      companyName: companyName)
                  .toJson()
            ])
          });
          return uuid;
        }
      }
      return null;
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  //use this after creating farm
  Future<UserModel?> getUserInDB() async {
    try {
      var firebaseUser = FirebaseAuth.instance.currentUser;
      var userRef = FirebaseFirestore.instance.collection('users');
      var userSnapshot = await userRef.doc(firebaseUser?.uid).get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? data = userSnapshot.data();
        if (data != null) {
          UserModel user = UserModel.fromJson(data);
          return user;
        }
      }
      return null;
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<UserModel?> getUserByID(String uid) async {
    try {
      var userRef = FirebaseFirestore.instance.collection('users');
      var userSnapshot = await userRef.doc(uid).get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? data = userSnapshot.data();
        if (data != null) {
          UserModel user = UserModel.fromJson(data);
          return user;
        }
      }
      return null;
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<List<UserModel>> getUserListFromFarm(
      DocumentReference companyReference) async {
    List<UserModel> users = [];
    var companySnapshot = await companyReference.get();
    if (companySnapshot.exists) {
      Map<String, dynamic>? data =
          companySnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        CompanyModel farm = CompanyModel.fromJson(data);
        for (var user in farm.users) {
          try {
            var userSnapshot = await user.get();
            if (userSnapshot.exists) {
              Map<String, dynamic>? data =
                  userSnapshot.data() as Map<String, dynamic>?;
              if (data != null) {
                UserModel user = UserModel.fromJson(data);
                if (user.enabled) {
                  users.add(user);
                }
              }
            }
          } catch (exception, stacktrace) {
            getIt
                .get<RemoteErrorLoggingService>()
                .recordError(exception, stacktrace);
          }
        }
      }
    }
    return users;
  }

  Future<void> setUserAsCompanyAdmin(
      UserModel currentCompanyAdmin, UserModel newCompanyAdmin, CompanyModel company) async {
    final currentCompanyAdminCompanyReferences = currentCompanyAdmin.companyReferences;
    final currentCompanyAdminCompanyToModify = currentCompanyAdminCompanyReferences
        .where((element) => element.companyReference.id == company.id)
        .firstOrNull;
    if (currentCompanyAdminCompanyToModify != null) {
      currentCompanyAdminCompanyToModify.isAdmin = false;
    }
    final newCompanyAdminCompanyReferences = newCompanyAdmin.companyReferences;
    final newCompanyAdminCompanyToModify = newCompanyAdminCompanyReferences
        .where((element) => element.companyReference.id == company.id)
        .firstOrNull;
    if (newCompanyAdminCompanyToModify != null) {
      newCompanyAdminCompanyToModify.isAdmin = true;
    }
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(FirebaseFirestore.instance
          .collection('users')
          .doc(currentCompanyAdmin.id), {
        'companyReferences': currentCompanyAdminCompanyReferences
            .map((e) => e.toJson())
            .toList()
      });
      transaction.update(FirebaseFirestore.instance
          .collection('users')
          .doc(newCompanyAdmin.id), {
        'companyReferences': newCompanyAdminCompanyReferences
            .map((e) => e.toJson())
            .toList()
      });
      final companyAdminInfo = CompanyAdminUserInfo(
          userReference: FirebaseFirestore.instance
              .collection('users')
              .doc(newCompanyAdmin.id),
          email: newCompanyAdmin.email,
          fullName: "${newCompanyAdmin.firstName} ${newCompanyAdmin.lastName}");
      transaction.update(FirebaseFirestore.instance
          .collection('companies')
          .doc(company.id), {
        'companyAdminUserInfo': companyAdminInfo
            .toJson()
      });
      company.companyAdminUserInfo = companyAdminInfo;
    });
  }

  Future<void> deleteUserFromCompany(
      UserModel userModel, CompanyModel farm) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userModel.id);
    var companyReference =
        FirebaseFirestore.instance.collection("companies").doc(farm.id);
    companyReference.update({
      "users": FieldValue.arrayRemove([userRef])
    });
  }

  Future<void> editUserFirstName(UserModel userModel, String newValue) async {
    debugPrint("is = ${userModel.id}");
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.id)
        .update({"firstName": capitalize(newValue)});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var userDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('users')
                .doc(userModel.id)))
            .data()!;
        var userChange = UserChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('users')
                .doc(userModel.id),
            userDocJson: userDocData,
            firstName: newValue);
        if (userChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("user_changes")
                  .doc(userModel.id),
              {
                'changes': FieldValue.arrayUnion([userChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editCompanyName(CompanyModel farmModel, String newValue) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(farmModel.id)
        .update({"name": newValue});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var companyDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id)))
            .data()!;
        var companyChange = CompanyChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id),
            companyDocData: companyDocData,
            name: newValue);
        if (companyChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("company_changes")
                  .doc(farmModel.id),
              {
                'changes': FieldValue.arrayUnion([companyChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editCompanyAddress(
      CompanyModel farmModel, String newValue) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(farmModel.id)
        .update({"address": newValue});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var companyDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id)))
            .data()!;
        var companyChange = CompanyChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id),
            companyDocData: companyDocData,
            address: newValue);
        if (companyChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("company_changes")
                  .doc(farmModel.id),
              {
                'changes': FieldValue.arrayUnion([companyChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editCompanyCity(CompanyModel farmModel, String newValue) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(farmModel.id)
        .update({"city": newValue});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var companyDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id)))
            .data()!;
        var companyChange = CompanyChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id),
            companyDocData: companyDocData,
            city: newValue);
        if (companyChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("company_changes")
                  .doc(farmModel.id),
              {
                'changes': FieldValue.arrayUnion([companyChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  //update type field on company
  Future<void> editCompanyType(CompanyModel farmModel, String newValue) async {
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var companyDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id)))
            .data()!;
        transaction.update(
            FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id),
            {"type": newValue});
        var companyChange = CompanyChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id),
            companyDocData: companyDocData,
            type: newValue);
        if (companyChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("company_changes")
                  .doc(farmModel.id),
              {
                'changes': FieldValue.arrayUnion([companyChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editCompanyState(CompanyModel farmModel, String newValue) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(farmModel.id)
        .update({"state": newValue});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var companyDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id)))
            .data()!;
        var companyChange = CompanyChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id),
            companyDocData: companyDocData,
            state: newValue);
        if (companyChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("company_changes")
                  .doc(farmModel.id),
              {
                'changes': FieldValue.arrayUnion([companyChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editCompanyProvince(
      CompanyModel farmModel, String newValue) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(farmModel.id)
        .update({"province": newValue});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var companyDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id)))
            .data()!;
        var companyChange = CompanyChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id),
            companyDocData: companyDocData,
            province: newValue);
        if (companyChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("company_changes")
                  .doc(farmModel.id),
              {
                'changes': FieldValue.arrayUnion([companyChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editCompanyCountry(
      CompanyModel farmModel, String newValue) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(farmModel.id)
        .update({"country": newValue});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var companyDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id)))
            .data()!;
        var companyChange = CompanyChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id),
            companyDocData: companyDocData,
            country: newValue);
        if (companyChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("company_changes")
                  .doc(farmModel.id),
              {
                'changes': FieldValue.arrayUnion([companyChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editCompanyZipcode(
      CompanyModel farmModel, String newValue) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(farmModel.id)
        .update({"zipcode": newValue});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var companyDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id)))
            .data()!;
        var companyChange = CompanyChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id),
            companyDocData: companyDocData,
            zipcode: newValue);
        if (companyChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("company_changes")
                  .doc(farmModel.id),
              {
                'changes': FieldValue.arrayUnion([companyChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editCompanyPhone(
      CompanyModel farmModel, PhoneModel newValue) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(farmModel.id)
        .update({"phone": newValue.toJson()});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var companyDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id)))
            .data()!;
        var companyChange = CompanyChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id),
            companyDocData: companyDocData,
            phone: newValue);
        if (companyChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("company_changes")
                  .doc(farmModel.id),
              {
                'changes': FieldValue.arrayUnion([companyChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editCompanyAlternativePhone(
      CompanyModel farmModel, PhoneModel newValue) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(farmModel.id)
        .update({"alternatePhone": newValue.toJson()});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var companyDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id)))
            .data()!;
        var companyChange = CompanyChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('companies')
                .doc(farmModel.id),
            companyDocData: companyDocData,
            alternatePhone: newValue);
        if (companyChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("company_changes")
                  .doc(farmModel.id),
              {
                'changes': FieldValue.arrayUnion([companyChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editUserLastName(UserModel userModel, String newValue) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.id)
        .update({"lastName": capitalizeLastWord(newValue)});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var userDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('users')
                .doc(userModel.id)))
            .data()!;
        var userChange = UserChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('users')
                .doc(userModel.id),
            userDocJson: userDocData,
            lastName: newValue);
        if (userChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("user_changes")
                  .doc(userModel.id),
              {
                'changes': FieldValue.arrayUnion([userChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editUserEmail(UserModel userModel, String newValue) async {
    if (((await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: newValue)
                .count()
                .get())
            .count ?? 0)>
        0) {
      throw EmailAlreadyInUseException();
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.id)
        .update({"email": newValue});
    var uuid = const Uuid().v4().toString();
    var changeDate = DateTime.now();
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      var userDocData = (await transaction.get(
              FirebaseFirestore.instance.collection('users').doc(userModel.id)))
          .data()!;
      var userChange = UserChangeModel.fromJsonAndCopy(
          id: uuid,
          changeDate: changeDate,
          changedBy:
              FirebaseFirestore.instance.collection('users').doc(userModel.id),
          userDocJson: userDocData,
          email: newValue);
      if (userChange != null) {
        transaction.set(
            FirebaseFirestore.instance
                .collection("user_changes")
                .doc(userModel.id),
            {
              'changes': FieldValue.arrayUnion([userChange.toJson()])
            },
            SetOptions(merge: true));
      }
    });
  }

  Future<void> editUserPhone(UserModel userModel, PhoneModel newValue) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.id)
        .update({"phone": newValue.toJson()});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var userDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('users')
                .doc(userModel.id)))
            .data()!;
        var userChange = UserChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('users')
                .doc(userModel.id),
            userDocJson: userDocData,
            phone: newValue);
        if (userChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("user_changes")
                  .doc(userModel.id),
              {
                'changes': FieldValue.arrayUnion([userChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<void> editUserEnabled(UserModel userModel, bool newValue) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.id)
        .update({"enabled": newValue});
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var userDocData = (await transaction.get(FirebaseFirestore.instance
                .collection('users')
                .doc(userModel.id)))
            .data()!;
        var userChange = UserChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: FirebaseFirestore.instance
                .collection('users')
                .doc(userModel.id),
            userDocJson: userDocData,
            enabled: newValue);
        if (userChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("user_changes")
                  .doc(userModel.id),
              {
                'changes': FieldValue.arrayUnion([userChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    }
  }

  Future<List<UserWithCompaniesModel>> getUsersFromCompany(
      CompanyModel farm) async {
    return Future.wait(farm.users.map((userRef) async {
      try {
        var userDoc = await userRef.get();
        var data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          return UserModel.fromJson(data).toUserWithCompaniesModel();
        }
      } catch (exception, stacktrace) {
        getIt
            .get<RemoteErrorLoggingService>()
            .recordError(exception, stacktrace);
      }
      return null;
    })).then((value) => value.whereNotNull().toList());
  }

  Future<List<UserModel>> searchUsers(
      bool showOnlyEnabledUsers,
      String firstName,
      String lastName,
      String email,
      String phone,
      String farmName,
      UserSortFilterWrapper sortFilter) async {
    try {
      var userRef = FirebaseFirestore.instance.collection('users');
      var users = await userRef.get();
      List<UserModel> userList = [];
      for (var userDoc in users.docs) {
        try {
          var data = userDoc.data();
          UserModel user = UserModel.fromJson(data);
          bool firstNameFilter = firstName.isEmpty ||
              (user.firstName
                      ?.toLowerCase()
                      .contains(firstName.toLowerCase()) ??
                  false);
          bool lastNameFilter = lastName.isEmpty ||
              (user.lastName?.toLowerCase().contains(lastName.toLowerCase()) ??
                  false);
          bool emailFilter = email.isEmpty ||
              (user.email.toLowerCase().contains(email.toLowerCase()));
          bool phoneFilter = phone.isEmpty ||
              (user.phone?.phone.toLowerCase().contains(phone.toLowerCase()) ??
                  false);
          bool farmFilter = farmName.isEmpty ||
              (user.companyReferences.any((element) => element.companyName
                  .toLowerCase()
                  .contains(farmName.toLowerCase())));
          bool enabledFilter = !showOnlyEnabledUsers || user.enabled;
          bool deletedFilter = !user.deleted;
          if (firstNameFilter &&
              lastNameFilter &&
              emailFilter &&
              phoneFilter &&
              farmFilter &&
              enabledFilter && deletedFilter) {
            userList.add(user);
          }
        } catch (exception, stacktrace) {
          getIt
              .get<RemoteErrorLoggingService>()
              .recordError(exception, stacktrace);
        }
      }
      sortUserList(sortFilter, userList);
      return userList;
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  void sortUserList(UserSortFilterWrapper sortFilter, List<UserModel> users) {
    if (users.isNotEmpty) {
      debugPrint("sortFilter.field: ${sortFilter.field}");
      if (sortFilter.field == UserSortFields.firstName) {
        if (sortFilter.sortType == SortType.asc) {
          users.sort((s1, s2) {
            if (s1.firstName == null) {
              return 1;
            }
            if (s2.firstName == null) {
              return -1;
            }
            return s1.firstName!
                .toLowerCase()
                .compareTo(s2.firstName!.toLowerCase());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          users.sort((s1, s2) {
            if (s1.firstName == null) {
              return 1;
            }
            if (s2.firstName == null) {
              return -1;
            }
            return -s1.firstName!
                .toLowerCase()
                .compareTo(s2.firstName!.toLowerCase());
          });
        }
      } else if (sortFilter.field == UserSortFields.lastName) {
        if (sortFilter.sortType == SortType.asc) {
          users.sort((s1, s2) {
            if (s1.lastName == null) {
              return 1;
            }
            if (s2.lastName == null) {
              return -1;
            }
            return s1.lastName!
                .toLowerCase()
                .compareTo(s2.lastName!.toLowerCase());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          users.sort((s1, s2) {
            if (s1.firstName == null) {
              return 1;
            }
            if (s2.lastName == null) {
              return -1;
            }
            return -s1.lastName!
                .toLowerCase()
                .compareTo(s2.lastName!.toLowerCase());
          });
        }
      } else if (sortFilter.field == UserSortFields.email) {
        if (sortFilter.sortType == SortType.asc) {
          users.sort((s1, s2) {
            return s1.email.toLowerCase().compareTo(s2.email.toLowerCase());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          users.sort((s1, s2) {
            return -s1.email.toLowerCase().compareTo(s2.email.toLowerCase());
          });
        }
      } else if (sortFilter.field == UserSortFields.phone) {
        if (sortFilter.sortType == SortType.asc) {
          users.sort((s1, s2) {
            if (s1.phone == null) {
              return 1;
            }
            if (s2.phone == null) {
              return -1;
            }
            return s1.phone!
                .getFullPhoneNumber()
                .compareTo(s2.phone!.getFullPhoneNumber());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          users.sort((s1, s2) {
            if (s1.phone == null) {
              return 1;
            }
            if (s2.phone == null) {
              return -1;
            }
            return -s1.phone!
                .getFullPhoneNumber()
                .compareTo(s2.phone!.getFullPhoneNumber());
          });
        }
      } else if (sortFilter.field == UserSortFields.farmName) {
        if (sortFilter.sortType == SortType.asc) {
          users.sort((s1, s2) {
            if (s1.companyReferences.firstOrNull == null) {
              return 1;
            }
            if (s2.companyReferences.firstOrNull == null) {
              return -1;
            }
            return s1.companyReferences.firstOrNull!.companyName
                .toLowerCase()
                .compareTo(s2.companyReferences.firstOrNull!.companyName
                    .toLowerCase());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          users.sort((s1, s2) {
            if (s1.companyReferences.firstOrNull == null) {
              return 1;
            }
            if (s2.companyReferences.firstOrNull == null) {
              return -1;
            }
            return -s1.companyReferences.firstOrNull!.companyName
                .toLowerCase()
                .compareTo(s2.companyReferences.firstOrNull!.companyName
                    .toLowerCase());
          });
        }
      }
    }
  }

  Future<List<CompanyModel>> searchCompanies(
      String address,
      String phone,
      String alternativePhone,
      String city,
      String state,
      String country,
      String zipcode,
      String name,
      String companyAdminEmail,
      CompanySortFilterWrapper sortFilter) async {
    try {
      var farmRef = FirebaseFirestore.instance.collection('companies');
      var farms = await farmRef.get();
      List<CompanyModel> farmList = [];
      for (var farmDoc in farms.docs) {
        try {
          var data = farmDoc.data();
          try {
            CompanyModel farm = CompanyModel.fromJson(data);
            bool addressFilter = address.isEmpty ||
                (farm.address.toLowerCase().contains(address.toLowerCase()));
            bool phoneFilter = phone.isEmpty ||
                (farm.phone
                        ?.getFullPhoneNumber()
                        .toLowerCase()
                        .contains(phone.toLowerCase()) ??
                    false);
            bool alternativePhoneFilter = alternativePhone.isEmpty ||
                (farm.alternatePhone
                        ?.getFullPhoneNumber()
                        .toLowerCase()
                        .contains(alternativePhone.toLowerCase()) ??
                    false);
            bool cityFilter = city.isEmpty ||
                (farm.city.toLowerCase().contains(city.toLowerCase()));
            bool stateFilter = state.isEmpty ||
                (farm.state.toLowerCase().contains(state.toLowerCase()));
            bool countryFilter = country.isEmpty ||
                (farm.country.toLowerCase().contains(country.toLowerCase()));
            bool zipcodeFilter = zipcode.isEmpty ||
                (farm.zipcode.toLowerCase().contains(zipcode.toLowerCase()));
            bool nameFilter = name.isEmpty ||
                (farm.name.toLowerCase().contains(name.toLowerCase()));
            bool companyAdminEmailFilter = companyAdminEmail.isEmpty ||
                (farm.companyAdminUserInfo?.email
                        .toLowerCase()
                        .contains(companyAdminEmail.toLowerCase()) ??
                    false);
            if (addressFilter &&
                phoneFilter &&
                alternativePhoneFilter &&
                cityFilter &&
                stateFilter &&
                countryFilter &&
                zipcodeFilter &&
                nameFilter &&
                companyAdminEmailFilter) {
              farmList.add(farm);
            }
          } catch (exception, stacktrace) {
            getIt
                .get<RemoteErrorLoggingService>()
                .recordError(exception, stacktrace);
          }
        } catch (exception, stacktrace) {
          getIt
              .get<RemoteErrorLoggingService>()
              .recordError(exception, stacktrace);
        }
      }
      sortCompaniesList(sortFilter, farmList);
      return farmList;
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  void sortCompaniesList(
      CompanySortFilterWrapper sortFilter, List<CompanyModel> farmList) {
    if (farmList.isNotEmpty) {
      if (sortFilter.field == CompanySortFields.name) {
        if (sortFilter.sortType == SortType.asc) {
          farmList.sort((s1, s2) {
            return s1.name.toLowerCase().compareTo(s2.name.toLowerCase());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          farmList.sort((s1, s2) {
            return -s1.name.toLowerCase().compareTo(s2.name.toLowerCase());
          });
        }
      } else if (sortFilter.field == CompanySortFields.address) {
        if (sortFilter.sortType == SortType.asc) {
          farmList.sort((s1, s2) {
            return s1.address.toLowerCase().compareTo(s2.address.toLowerCase());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          farmList.sort((s1, s2) {
            return -s1.address
                .toLowerCase()
                .compareTo(s2.address.toLowerCase());
          });
        }
      } else if (sortFilter.field == CompanySortFields.city) {
        if (sortFilter.sortType == SortType.asc) {
          farmList.sort((s1, s2) {
            return s1.city.toLowerCase().compareTo(s2.city.toLowerCase());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          farmList.sort((s1, s2) {
            return -s1.city.toLowerCase().compareTo(s2.city.toLowerCase());
          });
        }
      } else if (sortFilter.field == CompanySortFields.city) {
        if (sortFilter.sortType == SortType.asc) {
          farmList.sort((s1, s2) {
            return s1.city.toLowerCase().compareTo(s2.city.toLowerCase());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          farmList.sort((s1, s2) {
            return -s1.city.toLowerCase().compareTo(s2.city.toLowerCase());
          });
        }
      } else if (sortFilter.field == CompanySortFields.state) {
        if (sortFilter.sortType == SortType.asc) {
          farmList.sort((s1, s2) {
            return s1.state.toLowerCase().compareTo(s2.state.toLowerCase());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          farmList.sort((s1, s2) {
            return -s1.state.toLowerCase().compareTo(s2.state.toLowerCase());
          });
        }
      } else if (sortFilter.field == CompanySortFields.country) {
        if (sortFilter.sortType == SortType.asc) {
          farmList.sort((s1, s2) {
            return (s1.country ?? "")
                .toLowerCase()
                .compareTo((s2.country ?? "").toLowerCase());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          farmList.sort((s1, s2) {
            return -s1.country
                .toLowerCase()
                .compareTo(s2.country.toLowerCase());
          });
        }
      } else if (sortFilter.field == CompanySortFields.zipcode) {
        if (sortFilter.sortType == SortType.asc) {
          farmList.sort((s1, s2) {
            return s1.zipcode.toLowerCase().compareTo(s2.zipcode.toLowerCase());
          });
        } else if (sortFilter.sortType == SortType.desc) {
          farmList.sort((s1, s2) {
            return -s1.zipcode
                .toLowerCase()
                .compareTo(s2.zipcode.toLowerCase());
          });
        }
      } else if (sortFilter.field == CompanySortFields.phone) {
        if (sortFilter.sortType == SortType.asc) {
          farmList.sort((s1, s2) {
            return (s1.phone?.getFullPhoneNumber() ?? "-")
                .compareTo(s2.phone?.getFullPhoneNumber() ?? "-");
          });
        } else if (sortFilter.sortType == SortType.desc) {
          farmList.sort((s1, s2) {
            return -(s1.phone?.getFullPhoneNumber() ?? "-")
                .compareTo(s2.phone?.getFullPhoneNumber() ?? "-");
          });
        }
      } else if (sortFilter.field == CompanySortFields.alternativePhone) {
        if (sortFilter.sortType == SortType.asc) {
          farmList.sort((s1, s2) {
            return (s1.alternatePhone?.getFullPhoneNumber() ?? "-")
                .compareTo(s2.alternatePhone?.getFullPhoneNumber() ?? "-");
          });
        } else if (sortFilter.sortType == SortType.desc) {
          farmList.sort((s1, s2) {
            return -(s1.alternatePhone?.getFullPhoneNumber() ?? "-")
                .compareTo(s2.alternatePhone?.getFullPhoneNumber() ?? "-");
          });
        }
      }
    }
  }

  Future updateLastConnection() async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'lastConnection': DateTime.now()});
  }

  Future updateEmailVerifiedToTrue({required User user}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'isConfirmed': true});
  }

  //SIGN IN METHOD
  Future signIn({required String email, required String password}) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    //Get user from database and check if it's enabled
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    Map<String, dynamic>? data = userSnapshot.data();
    if (data != null) {
      UserModel user = UserModel.fromJson(data);
      if (!user.enabled) {
        throw DisabledUserException();
      }
      if (user.deleted) {
        throw DeletedUserException();
      }
      UserState userState = getIt.get();
      await userState.getUserDataFirstTime();
    }
    return userCredential;
  }

  Future<void> resetPassword({required String email}) async {
    var lastDateRequested =
        await _getLastDateRequestedResetPasswordForEmail(email: email);
    var currentTime = DateTime.now();
    if (lastDateRequested != null &&
        currentTime.difference(lastDateRequested).inMinutes < 1) {
      throw ResetPasswordTooSoonException();
    }
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    await FirebaseFirestore.instance
        .collection('resetPasswordRequests')
        .doc(email)
        .set({'lastDateRequested': currentTime});
  }

  Future<DateTime?> _getLastDateRequestedResetPasswordForEmail(
      {required String email}) async {
    var resetPasswordRequestSnapshot = await FirebaseFirestore.instance
        .collection('resetPasswordRequests')
        .doc(email)
        .get();
    return (resetPasswordRequestSnapshot.data()?["lastDateRequested"]
            as Timestamp?)
        ?.toDate();
  }

  //SIGN OUT METHOD
  Future signOut() async {
    await FirebaseAuth.instance.signOut();
    UserState userState = getIt.get();
    await userState.getUserDataFirstTime();

    debugPrint("signout");
  }

  Future<List<CompanyChangeWithUserModel>> getCompanyChanges(
      CompanyModel farm) async {
    var companyChangesDoc = await FirebaseFirestore.instance
        .collection("company_changes")
        .doc(farm.id)
        .get();
    if (!companyChangesDoc.exists) {
      return [];
    }
    return (await (Future.wait(
            (companyChangesDoc.data()!["changes"] as List<dynamic>)
                .map((e) async {
      try {
        return CompanyChangeModel.fromJson(e).toCompanyWithUserModel();
      } catch (e) {
        debugPrint("e -> $e");
        return null;
      }
    }).toList())))
        .whereNotNull()
        .toList();
  }

  Future<List<UserChangeWithUserModel>> getUserChanges(UserModel user) async {
    var userChangesDoc = await FirebaseFirestore.instance
        .collection("user_changes")
        .doc(user.id)
        .get();
    if (!userChangesDoc.exists) {
      return [];
    }
    return (await (Future.wait(
            (userChangesDoc.data()!["changes"] as List<dynamic>).map((e) async {
      try {
        return UserChangeModel.fromJson(e).toUserWithUserModel();
      } catch (e) {
        debugPrint("e -> $e");
        return null;
      }
    }).toList())))
        .whereNotNull()
        .toList();
  }
}

enum AuthErrors {
  missingEmail,
  invalidEmailFormat,
  missingPhone,
  invalidPhoneFormat,
  missingPassword,
  passwordTooShort,
  passwordTooLong
}

extension AuthErrorsExtension on AuthErrors {
  String get errorDescription {
    switch (this) {
      case AuthErrors.missingEmail:
        return "Please enter your email address";
      case AuthErrors.invalidEmailFormat:
        return "Please enter a valid email address";
      case AuthErrors.missingPhone:
        return "Please enter your phone";
      case AuthErrors.invalidPhoneFormat:
        return "Please enter a valid phone number";
      case AuthErrors.missingPassword:
        return "Please enter your password";
      case AuthErrors.passwordTooShort:
        return "Please enter a password greater than 8 characters";
      case AuthErrors.passwordTooLong:
        return "Please enter a password less than 64 characters";
    }
  }
}

class ResetPasswordTooSoonException implements Exception {}
