import 'dart:async';

import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/user/user_company_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/models/user/user_with_companies_model.dart';
import 'package:agro_k/services/Database/app_database.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@singleton
class UserState {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppDatabase _database = AppDatabase();
  final RemoteErrorLoggingService firebaseCrashlyticsService = getIt.get<RemoteErrorLoggingService>();

  UserState() {
    _auth.authStateChanges().listen((user) => listenUser(user));
  }

  User? get user => _auth.currentUser;

  StreamSubscription<Future<UserWithCompaniesModel?>>? _userStreamSubscription;

  UserWithCompaniesModel? get userData => _userObservable;
  UserWithCompaniesModel? _userObservable;

  StreamSubscription<CompanyModel?>? _currentCompanyStreamSubscription;

  CompanyModel? get currentCompanyData => _companyObservable.valueWrapper?.value;
  final BehaviorSubject<CompanyModel?> _companyObservable =
      BehaviorSubject.seeded(null);

  bool isSuperAdmin() {
    return userData?.user.isSuperAdmin ?? false;
  }

  bool isCompanyAdmin() {
    if (userData == null || currentCompanyData == null) {
      return false;
    }
    var currentCompany = userData!.companies
        .where((element) => element.farm.id == currentCompanyData!.id)
        .firstOrNull;
    return currentCompany?.isAdmin ?? false;
  }

  Future<void> updateCurrentCompany(String id) async {
    await _database.setCurrentCompany(id);
    await getCurrentCompanyFirstTime(id);
    listenToCurrentCompany(id);
  }

  Future<void> getCurrentCompanyFirstTime(String? id) async {
    var data = (await _firestore.collection("companies").doc(id).get()).data();
    if (data != null) {
      return _companyObservable.add(CompanyModel.fromJson(data));
    } else {
      return _companyObservable.add(null);
    }
  }

  void listenToCurrentCompany(String? id) {
    _currentCompanyStreamSubscription?.cancel();
    _currentCompanyStreamSubscription =
        _firestore.collection("companies").doc(id).snapshots().map((event) {
      var data = event.data();
      if (data != null) {
        return CompanyModel.fromJson(data);
      } else {
        return null;
      }
    }).listen((event) {
      _companyObservable.add(event);
    });
  }

  Future<void> getUserDataFirstTime() async {
    await firebaseCrashlyticsService.setCurrentUser(user?.uid);
    if (user != null) {
      try {
        var data =
            (await _firestore.collection("users").doc(user?.uid).get()).data();
        if (data != null) {
          var user = UserModel.fromJson(data);
          var userCompanyList = await getUserCompanies(user);
          UserWithCompaniesModel userWithCompaniesModel =
              UserWithCompaniesModel(user: user, companies: userCompanyList);
          _userObservable = userWithCompaniesModel;
          String? currentCompanyId;
          if (!user.isSuperAdmin) {
            currentCompanyId = (await _database.getCurrentCompany())?.id;
            if (userCompanyList.isNotEmpty &&
                (currentCompanyId == null ||
                    !userWithCompaniesModel.companies.any(
                        (element) => element.farm.id == currentCompanyId))) {
              currentCompanyId = userCompanyList[0].farm.id;
              await _database.setCurrentCompany(userCompanyList[0].farm.id);
            } else if (userCompanyList.isEmpty) {
              currentCompanyId = null;
            }
          }
          await getCurrentCompanyFirstTime(currentCompanyId);
          listenToCurrentCompany(currentCompanyId);
        } else {
          _userObservable = null;
        }
      } catch (exception, stacktrace) {
        getIt.get<RemoteErrorLoggingService>()
            .recordError(exception, stacktrace);
      }
    } else {
      _userObservable = null;
    }
  }

  Future<List<UserCompanyModel>> getUserCompanies(UserModel user) async {
    List<UserCompanyModel> userCompanyList = [];
    await Future.wait(user.companyReferences.map((e) async {
      try {
        dynamic farmData = (await e.companyReference.get()).data();
        if (farmData != null) {
          userCompanyList.add(UserCompanyModel(
              farm: CompanyModel.fromJson(farmData), isAdmin: e.isAdmin));
        }
      } catch (exception, stacktrace) {
        getIt.get<RemoteErrorLoggingService>()
            .recordError(exception, stacktrace);
      }
    }));
    return userCompanyList;
  }

  void listenUser(User? user) {
    _userStreamSubscription?.cancel();
    _userStreamSubscription = null;
    if (user != null) {
      _userStreamSubscription = _firestore
          .collection("users")
          .doc(user.uid)
          .snapshots()
          .map((event) async {
        if (event.data() != null) {
          var user = UserModel.fromJson(event.data()!);
          var userCompanyList = await getUserCompanies(user);
          return UserWithCompaniesModel(user: user, companies: userCompanyList);
        } else {
          return null;
        }
      }).listen((userFuture) async {
        UserWithCompaniesModel? userWithCompaniesModel = await userFuture;
        if (userWithCompaniesModel != null) {
          String? currentCompanyId;
          if (!userWithCompaniesModel.user.isSuperAdmin) {
            currentCompanyId = (await _database.getCurrentCompany())?.id;
            if (currentCompanyId == null &&
                userWithCompaniesModel.companies.isNotEmpty) {
              currentCompanyId = userWithCompaniesModel.companies[0].farm.id;
              await _database
                  .setCurrentCompany(userWithCompaniesModel.companies[0].farm.id);
            } else if (currentCompanyId != null &&
                !userWithCompaniesModel.companies
                    .any((element) => element.farm.id == currentCompanyId)) {
              currentCompanyId = null;
            }
          }
          await getCurrentCompanyFirstTime(currentCompanyId);
          listenToCurrentCompany(currentCompanyId);
        }
        _userObservable = userWithCompaniesModel;
      });
    } else {
      _userObservable = null;
    }
  }
}
