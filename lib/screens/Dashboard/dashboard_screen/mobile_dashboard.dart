import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/app_bar.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/invite_wrapper.dart';
import 'package:agro_k/models/company/user_notification_model.dart';
import 'package:agro_k/models/user/user_with_companies_model.dart';
import 'package:agro_k/screens/Auth/create_company_screen/view/create_company_screen.dart';
import 'package:agro_k/screens/Auth/log_in/view/log_in_screen.dart';
import 'package:agro_k/screens/CompanyTab/mobile_company_profile_screen.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/screens/Dashboard/notification_list_screen.dart';
import 'package:agro_k/screens/NewSample/dashboard_home_tab.dart';
import 'package:agro_k/screens/Profile/members_screen.dart';
import 'package:agro_k/screens/Profile/mobile_user_profile_screen.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class MobileDashboard extends StatefulWidget {
  const MobileDashboard({Key? key}) : super(key: key);

  @override
  State<MobileDashboard> createState() => MobileDashboardState();
}

class MobileDashboardState extends State<MobileDashboard> {
  List<Widget>? _widgetOptions;
  List<UserNotificationModel>? notifications;
  int _selectedIndex = 0;
  bool isLoading = false;
  ProfileService profileService = getIt.get();
  AuthService authService = getIt.get();
  SampleService sampleService = getIt.get();
  UserState userState = getIt.get();
  List<InvitesWrapperWithCompany>? invites;

  @override
  Widget build(BuildContext context) {
    UserWithCompaniesModel? userWithCompaniesModel = userState.userData;
    if (userWithCompaniesModel == null) {
      context.goNamed(LogInScreen.id);
      return Container(
        color: AppColors.pageBackground,
      );
    }
    CompanyModel? currentCompany = userState.currentCompanyData;
    _widgetOptions = <Widget?>[
      DashboardHomeTabWidget(
        user: userWithCompaniesModel.user,
        company: currentCompany,
      ),
      MobileUserProfileScreen(
        user: userWithCompaniesModel.user,
        company: currentCompany,
        invites: invites ?? [],
      ),
      userState.isCompanyAdmin() && currentCompany != null
          ? MobileCompanyProfileScreen(
              user: userWithCompaniesModel.user,
              company: currentCompany,
            )
          : null,
      userState.isCompanyAdmin() && currentCompany != null
          ? MembersScreen(
              user: userWithCompaniesModel.user,
              company: currentCompany,
            )
          : null,
    ].where((element) => element != null).map<Widget>((e) => e!).toList();
    if (_selectedIndex >= _widgetOptions!.length) {
      _selectedIndex = 0;
    }
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 9,
          unselectedFontSize: 9,
          items: <BottomNavigationBarItem?>[
            BottomNavigationBarItem(
              icon: Image.asset("images/iconHome.png", width: 24, height: 24, color: _selectedIndex == 0 ? AppColors.appPrimaryGreen : null,),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: (invites?.length ?? 0) > 0
                  ? Stack(
                      children: <Widget>[
                        const Icon(Icons.add, size: 32),
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              invites!.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    )
                  : Image.asset("images/iconProfile.png", width: 24, height: 24, color: _selectedIndex == 1 ? AppColors.appPrimaryGreen : null,),
              label: 'Profile',
            ),
            userState.isCompanyAdmin() && currentCompany != null
                ? BottomNavigationBarItem(
                    icon: Image.asset("images/iconCompany.png", width: 24, height: 24, color: _selectedIndex == 2 ? AppColors.appPrimaryGreen : null,),
                    label: 'Company',
                  )
                : null,
            userState.isCompanyAdmin() && currentCompany != null
                ? BottomNavigationBarItem(
                    icon: Image.asset("images/iconMembers.png", width: 24, height: 24, color: _selectedIndex == 3 ? AppColors.appPrimaryGreen : null,),
                    label: 'Members',
                  )
                : null,
          ]
              .where((element) => element != null)
              .map<BottomNavigationBarItem>((e) => e!)
              .toList(),
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.appPrimaryGreen,
          unselectedItemColor: AppColors.grayTextColor,
          unselectedLabelStyle: const TextStyle(color: AppColors.grayTextColor),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: _onItemTapped),
      backgroundColor: AppColors.pageBackground,
      appBar: createPhoneAppBar(
          toolbarHeight,
          () {
            context.pushNamed(NotificationListScreen.id);
          },
          notifications?.length ?? 0,
          userWithCompaniesModel,
          currentCompany,
          (companySelected) async {
            await userState.updateCurrentCompany(companySelected.id);
            await _getData();
          },
          () {
            debugPrint("called function");
            context.goNamed(CreateCompanyScreen.id,
                extra: const CreateCompanyScreenArguments(
                    prevScreen: DashboardScreen.id));
          }),
      body: _widgetOptions!.elementAt(_selectedIndex),
    );
  }

  @override
  void initState() {
    super.initState();

    _getData();
    authService.updateLastConnection();
  }

  Future _getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      profileService.listenToUserChanges().listen((user) {
        if (mounted) {
          setState(() {
            notifications = user?.notifications;
          });
        }
      });
      authService
          .getUserCompanyInvites(userState.userData!.user.email)
          .listen((event) async {
        var invites = await event;
        setState(() {
          this.invites = invites;
        });
      });
    } on FirebaseException catch (e) {
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            _getData();
          },
          "Go back",
          () {
            Navigator.pop(context);
            context.tryPop();
          },
          "Error",
          e.message ?? "Unknown error.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
