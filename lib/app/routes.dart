import 'package:agro_k/app/app.dart';
import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/sample_with_user_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/models/user/user_with_companies_model.dart';
import 'package:agro_k/screens/Auth/confirm_account/view/confirm_account_screen.dart';
import 'package:agro_k/screens/Auth/create_company_screen/view/create_company_screen.dart';
import 'package:agro_k/screens/Auth/custom_auth/view/custom_auth_screen.dart';
import 'package:agro_k/screens/Auth/log_in/view/log_in_screen.dart';
import 'package:agro_k/screens/Auth/reset_password/view/reset_password_screen.dart';
import 'package:agro_k/screens/Auth/sign_up/view/sign_up_screen.dart';
import 'package:agro_k/screens/Auth/use_desktop_or_app_screen.dart';
import 'package:agro_k/screens/CompanyTab/purchase_barcodes_screen.dart';
import 'package:agro_k/screens/Dashboard/companies_management_screen.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/screens/Dashboard/manage_barcodes_screen.dart';
import 'package:agro_k/screens/Dashboard/manage_crops_screen.dart';
import 'package:agro_k/screens/Dashboard/manage_growers_screen.dart';
import 'package:agro_k/screens/Dashboard/notification_list_screen.dart';
import 'package:agro_k/screens/Dashboard/see_company_changes_screen.dart';
import 'package:agro_k/screens/Dashboard/see_company_users_screen.dart';
import 'package:agro_k/screens/Dashboard/see_report_screen.dart';
import 'package:agro_k/screens/Dashboard/see_sample_changes_screen.dart';
import 'package:agro_k/screens/Dashboard/see_user_changes_screen.dart';
import 'package:agro_k/screens/Dashboard/user_management_screen.dart';
import 'package:agro_k/screens/NewSample/company_samples_screen.dart';
import 'package:agro_k/screens/NewSample/new_sample_screen.dart';
import 'package:agro_k/screens/NewSample/sample_submitted_screen.dart';
import 'package:agro_k/screens/edit_company_profile_screen.dart';
import 'package:agro_k/screens/edit_user_password_screen.dart';
import 'package:agro_k/screens/edit_user_profile_screen.dart';
import 'package:agro_k/screens/no_permissions_screen.dart';
import 'package:agro_k/screens/page_not_found_screen.dart';
import 'package:agro_k/utilities/sample_sorting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_html/html.dart' as html;
import 'package:agro_k/components/purchasing_web_view_imports.dart';

bool isCustomAuthActionUri(Uri? uri) {
  if (uri != null && uri.pathSegments.contains('auth')) {
    String? oobCode = uri.queryParameters['oobCode'];
    String? actionType = uri.queryParameters['mode'];
    if (oobCode != null && actionType != null) {
      return true;
    }
  }
  return false;
}

GoRouter? router;

GoRouter getRouter() {
  if (router != null) {
    return router!;
  }
  final navigationKey = NavigationService.instance.navigationKey!;
  return GoRouter(
      navigatorKey: navigationKey,
      routes: [
        GoRoute(
          name: LogInScreen.id,
          path: LogInScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            return LogInScreen.withBloc();
          },
        ),
        GoRoute(
          name: SignUpScreen.id,
          path: SignUpScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            return SignUpScreen.withBloc();
          },
        ),
        GoRoute(
          name: ResetPasswordScreen.id,
          path: ResetPasswordScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            return ResetPasswordScreen.withBloc();
          },
        ),
        GoRoute(
          name: DashboardScreen.id,
          path: DashboardScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            return const DashboardScreen();
          },
        ),
        GoRoute(
          name: UseDesktopOrAppScreen.id,
          path: UseDesktopOrAppScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            return const UseDesktopOrAppScreen();
          },
        ),
        GoRoute(
          name: NotificationListScreen.id,
          path: NotificationListScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            return const NotificationListScreen();
          },
        ),
        GoRoute(
            name: SeeCompanyUsersScreen.id,
            path: SeeCompanyUsersScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              var extra = state.extra as SeeCompanyUsersScreenArguments;
              return SeeCompanyUsersScreen(user: extra.user, farm: extra.farm);
            },
            redirect: (BuildContext context, GoRouterState state) {
              if (state.extra == null ||
                  state.extra! is! SeeCompanyUsersScreenArguments) {
                return DashboardScreen.id;
              }
              return null;
            }),
        GoRoute(
            name: SampleSubmittedScreen.id,
            path: SampleSubmittedScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              var extra = state.extra as SampleSubmittedScreenArguments;
              return SampleSubmittedScreen(
                farm: extra.farm,
                uuid: extra.uuid,
                automaticallyImplyLeading: extra.automaticallyImplyLeading,
                showNewLabelButton: extra.showNewLabelButton,
                fromWebDashboard: extra.fromWebDashboard,
              );
            },
            redirect: (BuildContext context, GoRouterState state) {
              if (state.extra == null ||
                  state.extra! is! SampleSubmittedScreenArguments) {
                return DashboardScreen.id;
              }
              return null;
            }),
        GoRoute(
            name: CompanySamplesScreen.id,
            path: CompanySamplesScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              UserState userState = getIt.get();
              UserWithCompaniesModel userWithCompaniesModel =
                  userState.userData!;
              CompanyModel currentCompany = userState.currentCompanyData!;
              return CompanySamplesScreen(
                user: userWithCompaniesModel.user,
                farm: currentCompany,
              );
            },
            redirect: (context, state) {
              UserState userState = getIt.get();
              CompanyModel? currentCompany = userState.currentCompanyData;
              if (currentCompany == null) {
                return DashboardScreen.id;
              }
              return null;
            }),
        GoRoute(
          name: EditUserProfileScreen.id,
          path: EditUserProfileScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            UserState userState = getIt.get();
            UserWithCompaniesModel userWithCompaniesModel = userState.userData!;
            return EditUserProfileScreen(
              user: userWithCompaniesModel.user,
            );
          },
        ),
        GoRoute(
          name: EditCompanyProfileScreen.id,
          path: EditCompanyProfileScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            UserState userState = getIt.get();
            CompanyModel? currentCompany = userState.currentCompanyData;
            if (currentCompany == null) {
              return const NoPermissionsScreen();
            }
            return EditCompanyProfileScreen(
              company: currentCompany,
            );
          },
        ),
        GoRoute(
          name: EditUserPasswordScreen.id,
          path: EditUserPasswordScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            UserState userState = getIt.get();
            UserWithCompaniesModel userWithCompaniesModel = userState.userData!;
            return EditUserPasswordScreen(
              user: userWithCompaniesModel.user,
            );
          },
        ),
        GoRoute(
            name: PurchaseBarcodesScreen.id,
            path: PurchaseBarcodesScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              UserState userState = getIt.get();
              UserWithCompaniesModel userWithCompaniesModel =
                  userState.userData!;
              CompanyModel currentCompany = userState.currentCompanyData!;
              return PurchaseBarcodesScreen(
                user: userWithCompaniesModel.user,
                farm: currentCompany,
              );
            },
            redirect: (context, state) {
              return null;
              UserState userState = getIt.get();
              CompanyModel? currentCompany = userState.currentCompanyData;
              if (currentCompany == null ||
                  !(userState.isCompanyAdmin())) {
                return DashboardScreen.id;
              }
              return null;
            }),
        GoRoute(
            name: PurchasingWebView.id,
            path: PurchasingWebView.id,
            builder: (BuildContext context, GoRouterState state) {
              //know if device is android or ios
              final extra = state.extra as PurchasingWebViewArguments;
                return PurchasingWebView(
                  address: extra.address,
                  zipcode: extra.zipcode,
                  amount: extra.amount,
                  email: extra.email,
                  companyId: extra.companyId,
                  isAdmin: extra.isAdmin,
                  cardToken: extra.cardToken,
                  saveCard: extra.saveCard,
                );
            },
            redirect: (context, state) {
              return null;
              if (!kIsWeb) {
                return DashboardScreen.id;
              }
              if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                if (state.uri.queryParameters["token"] != null) {
                  return null;
                } else {
                  return DashboardScreen.id;
                }
              } else {
                //coming from purchase barcodes screen
                if (state.extra is PurchasingWebViewArguments) {
                  return null;
                } else {
                  return DashboardScreen.id;
                }
              }
            }),
        GoRoute(
          name: ManageCropsScreen.id,
          path: ManageCropsScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            UserState userState = getIt.get();
            UserModel? userData = userState.userData?.user;
            bool isSuperAdmin = userData?.isSuperAdmin ?? false;
            if (isSuperAdmin) {
              return const ManageCropsScreen();
            } else {
              return const NoPermissionsScreen();
            }
          },
        ),
        GoRoute(
          name: ManageUsersScreen.id,
          path: ManageUsersScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            UserState userState = getIt.get();
            UserModel? userData = userState.userData?.user;
            bool isSuperAdmin = userData?.isSuperAdmin ?? false;
            if (isSuperAdmin) {
              return ManageUsersScreen(
                highlightedUserId:
                    state.uri.queryParameters["highlightedUserId"],
              );
            } else {
              return const NoPermissionsScreen();
            }
          },
        ),
        GoRoute(
          name: ManageBarcodesScreen.id,
          path: ManageBarcodesScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            UserState userState = getIt.get();
            UserModel? userData = userState.userData?.user;
            bool isSuperAdmin = userData?.isSuperAdmin ?? false;
            CompanyModel? currentCompany = userState.currentCompanyData;
            CompanyModel? farmSelectedBySuperAdmin;
            BarcodeSortFilterWrapper? initialSort;
            if (state.extra is ManageBarcodesScreenArguments) {
              ManageBarcodesScreenArguments arguments =
                  state.extra as ManageBarcodesScreenArguments;
              farmSelectedBySuperAdmin = arguments.farm;
              initialSort = arguments.initialSort;
            }
            if (isSuperAdmin || currentCompany != null) {
              return ManageBarcodesScreen(
                user: userData!,
                farm: currentCompany ?? farmSelectedBySuperAdmin,
                initialSort: initialSort,
              );
            } else {
              return const NoPermissionsScreen();
            }
          },
        ),
        GoRoute(
            name: ManageGrowersScreen.id,
            path: ManageGrowersScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              UserState userState = getIt.get();
              UserModel? userData = userState.userData?.user;
              CompanyModel? currentCompany = userState.currentCompanyData;
              CompanyModel? farmSelectedBySuperAdmin;
              if (state.extra is ManageGrowersScreenArguments) {
                farmSelectedBySuperAdmin =
                    (state.extra as ManageGrowersScreenArguments).farm;
              }
              if (currentCompany != null || farmSelectedBySuperAdmin != null) {
                return ManageGrowersScreen(
                  user: userData!,
                  farm: currentCompany ?? farmSelectedBySuperAdmin!,
                );
              } else {
                return const NoPermissionsScreen();
              }
            },
            redirect: (BuildContext context, GoRouterState state) {
              UserState userState = getIt.get();
              CompanyModel? currentCompany = userState.currentCompanyData;
              if (currentCompany == null &&
                  (state.extra == null ||
                      state.extra! is! ManageGrowersScreenArguments)) {
                return DashboardScreen.id;
              }
              return null;
            }),
        GoRoute(
            name: SeeSampleChangesScreen.id,
            path: SeeSampleChangesScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              var extra = state.extra as SeeSampleChangesScreenArguments;
              return SeeSampleChangesScreen(
                sampleChanges: extra.sampleChanges,
              );
            },
            redirect: (BuildContext context, GoRouterState state) {
              if (state.extra == null ||
                  state.extra! is! SeeSampleChangesScreenArguments) {
                return DashboardScreen.id;
              }
              return null;
            }),
        GoRoute(
            name: SeeCompanyChangesScreen.id,
            path: SeeCompanyChangesScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              var extra = state.extra as SeeCompanyChangesScreenArguments;
              return SeeCompanyChangesScreen(
                companyChanges: extra.companyChanges,
              );
            },
            redirect: (BuildContext context, GoRouterState state) {
              if (state.extra == null ||
                  state.extra! is! SeeCompanyChangesScreenArguments) {
                return DashboardScreen.id;
              }
              return null;
            }),
        GoRoute(
            name: SeeUserChangesScreen.id,
            path: SeeUserChangesScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              var extra = state.extra as SeeUserChangesScreenArguments;
              return SeeUserChangesScreen(
                userChanges: extra.userChanges,
              );
            },
            redirect: (BuildContext context, GoRouterState state) {
              if (state.extra == null ||
                  state.extra! is! SeeUserChangesScreenArguments) {
                return DashboardScreen.id;
              }
              return null;
            }),
        GoRoute(
            name: ConfirmAccountScreen.id,
            path: ConfirmAccountScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              var extra = state.extra as ConfirmAccountScreenArguments?;
              return ConfirmAccountScreen.withBloc(
                emailPhone: extra?.emailPhone,
              );
            },
            redirect: (BuildContext context, GoRouterState state) {
              if (state.extra == null ||
                  state.extra! is! ConfirmAccountScreenArguments) {
                debugPrint("Redirecting to dashboard");
                return DashboardScreen.id;
              }
              debugPrint("Not redirecting to dashboard");
              return null;
            }),
        GoRoute(
          name: CustomAuthActionScreen.id,
          path: CustomAuthActionScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            String oobCode = state.uri.queryParameters["oobCode"]!;
            String actionType = state.uri.queryParameters["mode"]!;
            return CustomAuthActionScreen.withBloc(
              oobCode: oobCode,
              actionType: actionType,
            );
          },
        ),
        GoRoute(
            name: CreateCompanyScreen.id,
            path: CreateCompanyScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              var extra = state.extra as CreateCompanyScreenArguments;
              return CreateCompanyScreen.withBloc(
                uid: extra.uid,
                prevScreen: extra.prevScreen,
              );
            },
            redirect: (BuildContext context, GoRouterState state) {
              if (state.extra == null ||
                  state.extra! is! CreateCompanyScreenArguments) {
                return DashboardScreen.id;
              }
              return null;
            }),
        GoRoute(
            name: SeeReportScreen.id,
            path: SeeReportScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              var extra = state.extra as SeeReportScreenArguments;
              return SeeReportScreen(
                adminInfo: extra.adminInfo,
                sampleWithUser: extra.sampleWithUser,
              );
            },
            redirect: (BuildContext context, GoRouterState state) {
              if (state.extra == null ||
                  state.extra! is! SeeReportScreenArguments) {
                return DashboardScreen.id;
              }
              return null;
            }),
        GoRoute(
            name: NewSampleScreen.id,
            path: NewSampleScreen.id,
            builder: (BuildContext context, GoRouterState state) {
              var extra = state.extra as Map<String, dynamic>?;
              UserState userState = getIt.get();
              UserWithCompaniesModel userWithCompaniesModel =
                  userState.userData!;
              SampleWithUserModel? existingSampleToEdit =
                  extra?["existingSampleToEdit"];
              CompanyModel? sampleCompany = extra?["sampleCompany"];
              CompanyModel? currentCompany = userState.currentCompanyData;
              bool populateFields = extra?["populateFields"] ?? true;
              if (currentCompany != null) {
                return NewSampleScreen(
                  user: userWithCompaniesModel.user,
                  farm: currentCompany,
                  populateFields: populateFields,
                );
              } else {
                return NewSampleScreen(
                  existingSampleToEdit: existingSampleToEdit,
                  user: userWithCompaniesModel.user,
                  farm: sampleCompany!,
                );
              }
            },
            redirect: (context, state) {
              var extra = state.extra as Map<String, dynamic>?;
              UserState userState = getIt.get();
              CompanyModel? currentCompany = userState.currentCompanyData;
              SampleWithUserModel? existingSampleToEdit =
                  extra?["existingSampleToEdit"];
              CompanyModel? sampleCompany = extra?["sampleCompany"];
              debugPrint(
                  "existingSampleToEdit = $existingSampleToEdit // sampleCompany = $sampleCompany // $extra");
              if (currentCompany == null &&
                  (existingSampleToEdit == null || sampleCompany == null)) {
                return DashboardScreen.id;
              }
              return null;
            }),
        GoRoute(
          name: CompaniesManagementScreen.id,
          path: CompaniesManagementScreen.id,
          builder: (BuildContext context, GoRouterState state) {
            UserState userState = getIt.get();
            UserModel? userData = userState.userData?.user;
            bool isSuperAdmin = userData?.isSuperAdmin ?? false;
            if (isSuperAdmin) {
              return CompaniesManagementScreen(
                highlightedCompanyId:
                    state.uri.queryParameters["highlightedCompanyId"],
              );
            } else {
              return const NoPermissionsScreen();
            }
          },
        )
      ],
      errorBuilder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          html.window.location.href = "https://agro-k.com/showme404";
        });
        return const SizedBox.shrink();
      },
      redirect: (context, state) async {
        if (getRouter().routeInformationParser.configuration.findMatch(state.matchedLocation).isEmpty) {
          return null;
        }
        debugPrint("print uri: ${state.uri}");
        UserState userState = getIt.get();
        User? user = userState.user;
        bool isUserVerified = user?.emailVerified ?? false;
        List<String> routesNotNeedAuthentication = [
          LogInScreen.id,
          SignUpScreen.id,
          ResetPasswordScreen.id
        ];
        if (state.matchedLocation == PurchasingWebView.id) {
          return null;
        }
        if (user != null && state.matchedLocation == ConfirmAccountScreen.id) {
          //These routes have their own redirect function
          return null;
        }
        String? oobCode = state.uri.queryParameters["oobCode"];
        String? actionType = state.uri.queryParameters["mode"];
        if (state.matchedLocation == CustomAuthActionScreen.id) {
          await FirebaseAuth.instance.signOut();
          await userState.getUserDataFirstTime();
          if (oobCode != null && actionType != null) {
            return null;
          } else {
            return LogInScreen.id;
          }
        }
        if (kIsWeb &&
            ![
              ...routesNotNeedAuthentication,
              ConfirmAccountScreen.id,
              CustomAuthActionScreen.id
            ].contains(state.matchedLocation) &&
            user != null) {
          String userAgent =
              html.window.navigator.userAgent.toString().toLowerCase();
          if (userAgent.contains("android") || userAgent.contains("iphone")) {
            return UseDesktopOrAppScreen.id;
          }
        }
        if (!routesNotNeedAuthentication.contains(state.matchedLocation) &&
            user == null) {
          return LogInScreen.id;
        }
        if (isUserVerified &&
            routesNotNeedAuthentication.contains(state.matchedLocation)) {
          return DashboardScreen.id;
        }
        if (isUserVerified && state.matchedLocation == "/") {
          return DashboardScreen.id;
        }
        return null;
      },
      initialLocation: DashboardScreen.id);
}

class ConfirmAccountScreenArguments {
  final String emailPhone;

  const ConfirmAccountScreenArguments({required this.emailPhone});
}

class ReportScreenArguments {
  final String productName;

  const ReportScreenArguments({required this.productName});
}
