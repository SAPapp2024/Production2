import 'dart:async';
import 'dart:io';

import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/user_notification_model.dart';
import 'package:agro_k/models/user/company_change_model.dart';
import 'package:agro_k/models/user/notification_settings_model.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/models/user/user_change_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/models/user_usage_model.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../models/company/admin_info_model.dart';

@injectable
class ProfileService {
  Future<CompanyModel?> getCompanyInDB(
      DocumentReference companyReference) async {
    try {
      DocumentReference<Map<String, dynamic>>? farmRef =
          companyReference as DocumentReference<Map<String, dynamic>>?;
      if (farmRef != null) {
        var companySnapshot = await farmRef.get();
        if (companySnapshot.exists) {
          Map<String, dynamic>? data = companySnapshot.data();
          if (data != null) {
            CompanyModel farm = CompanyModel.fromJson(data);
            return farm;
          }
        }
      }
      return null;
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<String?> updateUserProfileImage(File imageFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference userStorageRef =
        storage.ref().child("users/${FirebaseAuth.instance.currentUser?.uid}");

    return await userStorageRef.putFile(imageFile).then((snapshot) async {
      if (snapshot.state == TaskState.success) {
        return userStorageRef.getDownloadURL().then((url) async {
          var uuid = const Uuid().v4().toString();
          var changeDate = DateTime.now();
          return FirebaseFirestore.instance.runTransaction((transaction) async {
            var userFirestoreRef = FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid);
            var userData = (await transaction.get(userFirestoreRef)).data()!;
            transaction.update(userFirestoreRef, {'profileImagePath': url});
            var userChange = UserChangeModel.fromJsonAndCopy(
                changeDate: changeDate,
                id: uuid,
                userDocJson: userData,
                profileImagePath: url);
            if (userChange != null) {
              transaction.set(
                  FirebaseFirestore.instance
                      .collection("user_changes")
                      .doc(userFirestoreRef.id),
                  {
                    'changes': FieldValue.arrayUnion([userChange.toJson()])
                  },
                  SetOptions(merge: true));
            }
            return url;
          });
        });
      }
      return null;
    });
  }

  Future<void> updateUserProfileImageWeb(Uint8List imageFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference userReference =
        storage.ref().child("users/${FirebaseAuth.instance.currentUser?.uid}");

    return userReference.putData(imageFile).then((snapshot) async {
      if (snapshot.state == TaskState.success) {
        return userReference.getDownloadURL().then((url) async {
          var uuid = const Uuid().v4().toString();
          var changeDate = DateTime.now();
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            var userFirestoreRef = FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid);
            var userData = (await transaction.get(userFirestoreRef)).data()!;
            transaction.update(userFirestoreRef, {'profileImagePath': url});
            var userChange = UserChangeModel.fromJsonAndCopy(
                changeDate: changeDate,
                id: uuid,
                userDocJson: userData,
                profileImagePath: url);
            if (userChange != null) {
              transaction.set(
                  FirebaseFirestore.instance
                      .collection("user_changes")
                      .doc(userFirestoreRef.id),
                  {
                    'changes': FieldValue.arrayUnion([userChange.toJson()])
                  },
                  SetOptions(merge: true));
            }
          });
        });
      }
    });
  }

  Future updateUserProfile(
      {required String firstName,
      required String lastName,
      PhoneModel? phone,
      required String email}) async {
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      var userReference = FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var userDocData = (await transaction.get(userReference)).data()!;
        var set = {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone == null
              ? null
              : {
                  "phone": phone.phone,
                  "phoneAreaCode": phone.phoneAreaCode,
                  "phoneCountryISOName": phone.phoneCountryISOName,
                },
        };
        if (userDocData["email"] != email) {
          if (((await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: email)
                      .count()
                      .get())
                  .count ?? 0) >
              0) {
            throw EmailAlreadyInUseException();
          }
          set["email"] = email;
          set["isConfirmed"] = false;
        }
        //like we did on updateCompanyProfile, create UserChangeModel
        var userChange = UserChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: userReference,
            userDocJson: userDocData,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            email: set["email"] as String?);
        transaction.update(userReference, set);
        if (userChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("user_changes")
                  .doc(userReference.id),
              {
                'changes': FieldValue.arrayUnion([userChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future updateUserProfileWeb(
      {required String firstName,
      required String lastName,
      PhoneModel? phone,
      required NotificationSettingsModel notifSettings,
      required String email}) async {
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      var userReference = FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var userDocData = (await transaction.get(userReference)).data()!;
        var set = {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone == null
              ? null
              : {
                  "phone": phone.phone,
                  "phoneAreaCode": phone.phoneAreaCode,
                  "phoneCountryISOName": phone.phoneCountryISOName,
                },
          'notificationSettings': notifSettings.toMap(),
        };
        if (userDocData["email"] != email) {
          if (((await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: email)
                      .count()
                      .get())
                  .count ?? 0) >
              0) {
            throw EmailAlreadyInUseException();
          }
          set["email"] = email;
          set["isConfirmed"] = false;
        }
        //like we did on updateCompanyProfile, create UserChangeModel
        var userChange = UserChangeModel.fromJsonAndCopy(
            id: uuid,
            changeDate: changeDate,
            changedBy: userReference,
            userDocJson: userDocData,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            email: set["email"] as String?);
        transaction.update(userReference, set);
        if (userChange != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("user_changes")
                  .doc(userReference.id),
              {
                'changes': FieldValue.arrayUnion([userChange.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<void> deleteUserProfile(UserModel userModel) async {
    final userProfilePicturePath = userModel.profileImagePath;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(userModel.getReference(), {
        "deleted": true,
        "firstName": "Deleted",
        "lastName": "User",
        "phone": null,
        "email": "",
        "profileImagePath": null,
        "deviceTokens": [],
        "notifications": [],
      });
      transaction.delete(FirebaseFirestore.instance
          .collection("user_changes")
          .doc(userModel.id));
      for (var companyReference in userModel.companyReferences) {
        transaction.update(companyReference.companyReference, {
          "users": FieldValue.arrayRemove([userModel.getReference()])
        });
      }
    });
    if (userProfilePicturePath != null) {
      await FirebaseStorage.instance.refFromURL(userProfilePicturePath).delete();
    }
  }

  Future<void> updateNotificationSettings(
      UserModel user, String label, bool newValue) async {
    final newNotificationSettings = user.notificationSettings.toMap();
    newNotificationSettings[label] = newValue;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.id)
        .update({"notificationSettings": newNotificationSettings});
  }

  Future updateCompanyProfile(
      {required String companyName,
      required String address,
      required String city,
      required String state,
      required String zip,
      required String? country,
      PhoneModel? phone,
      PhoneModel? altPhone,
      required DocumentReference companyReference}) async {
    try {
      var uuid = const Uuid().v4().toString();
      var changeDate = DateTime.now();
      var changedBy = FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var farmDocData = (await transaction.get(companyReference)).data()!
            as Map<String, dynamic>;
        //create CompanyChangeModel with old and new data
        var companyChangeModel = CompanyChangeModel.fromJsonAndCopy(
          changeDate: changeDate,
          changedBy: changedBy,
          id: uuid,
          companyDocData: farmDocData,
          name: companyName,
          address: address,
          city: city,
          state: state,
          zipcode: zip,
          country: country,
          phone: phone == null
              ? null
              : PhoneModel(
                  phone: phone.phone,
                  phoneAreaCode: phone.phoneAreaCode,
                  phoneCountryISOName: phone.phoneCountryISOName),
          alternatePhone: altPhone == null
              ? null
              : PhoneModel(
                  phone: altPhone.phone,
                  phoneAreaCode: altPhone.phoneAreaCode,
                  phoneCountryISOName: altPhone.phoneCountryISOName,
                ),
        );
        var farmData = {
          'name': companyName,
          'address': address,
          'city': city,
          'country': country,
          'state': state,
          'zipcode': zip,
          'phone': phone == null
              ? null
              : {
                  "phone": phone.phone,
                  "phoneAreaCode": phone.phoneAreaCode,
                  "phoneCountryISOName": phone.phoneCountryISOName,
                },
          'alternatePhone': altPhone == null
              ? null
              : {
                  "phone": altPhone.phone,
                  "phoneAreaCode": altPhone.phoneAreaCode,
                  "phoneCountryISOName": altPhone.phoneCountryISOName,
                },
        };
        transaction.update(companyReference, farmData);
        if (companyChangeModel != null) {
          transaction.set(
              FirebaseFirestore.instance
                  .collection("company_changes")
                  .doc(companyReference.id),
              {
                "changes": FieldValue.arrayUnion([companyChangeModel.toJson()])
              },
              SetOptions(merge: true));
        }
      });
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future updatePassword(
      String userEmail, String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
        email: userEmail, password: currentPassword);
    await user?.reauthenticateWithCredential(cred);
    await user?.updatePassword(newPassword);
  }

  Future<AdminInfoModel?> getSuperAdminInfo() async {
    try {
      var adminInfoRef = await FirebaseFirestore.instance
          .collection('admin')
          .doc("info")
          .get();
      var data = adminInfoRef.data();
      if (data != null) {
        return AdminInfoModel.fromJson(data);
      } else {
        return null;
      }
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<int?> getUserCount() async {
    try {
      return (await FirebaseFirestore.instance.collection('users').get()).size;
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<UserUsageModel> getUserUsage() async {
    QuerySnapshot<Map<String, dynamic>> usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    int dailyUsers = 0;
    int monthlyUsers = 0;
    DateTime now = DateTime.now();
    for (var userSnapshot in usersSnapshot.docs) {
      var userData = userSnapshot.data();
      try {
        Duration timeDifference =
            userData["lastConnection"].toDate().difference(now);
        if (timeDifference.inDays == 0) {
          dailyUsers++;
          monthlyUsers++;
        } else if (timeDifference.inDays <= 30) {
          monthlyUsers++;
        }
      } catch (e) {
        debugPrint("$e");
      }
    }
    return UserUsageModel(dailyUsers, monthlyUsers);
  }

  Future clearNotifications() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({"notifications": []});
  }

  Future clearSingleNotification(
      UserNotificationModel userNotificationModel) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      "notifications": FieldValue.arrayRemove([userNotificationModel.toJson()])
    });
  }

  Future<UserModel?> getUser() async {
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var userData = userSnapshot.data();
    if (userData != null) {
      try {
        return UserModel.fromJson(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Stream<UserModel?> listenToUserChanges() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((userSnapshot) {
      var userData = userSnapshot.data();
      if (userData != null) {
        try {
          return UserModel.fromJson(userData);
        } catch (e) {
          return null;
        }
      }
      return null;
    });
  }
}
