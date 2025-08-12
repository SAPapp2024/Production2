import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/user/user_with_companies_model.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget createWebAppBar(
    double toolbarHeight,
    int pageIndex,
    Function dashboardPressed,
    Function reportsPressed,
    Function membersPressed,
    Function profilePressed,
    bool showMembersButton,
    Function logOutCallback,
    UserWithCompaniesModel userWithCompaniesModel,
    CompanyModel? farm,
    Future<void> Function(CompanyModel) onNewCompanySelected,
    void Function() onCreateCompanySelected,
    int inviteCount) {
  return AppBar(
    toolbarHeight: toolbarHeight,
    backgroundColor: AppColors.appPrimaryGreen,
    leadingWidth: 0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/logo.png',
              width: 166 / 4.0,
              height: 317 / 4.0,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: pageIndex == 0
                          ? Colors.black.withOpacity(0.1)
                          : Colors.transparent,
                      alignment: Alignment.centerLeft),
                  onPressed: () {
                    pageIndex = 0;
                    dashboardPressed(pageIndex);
                  },
                  child: const Text(
                    "Dashboard",
                  ),
                )),
            Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: pageIndex == 1
                          ? Colors.black.withOpacity(0.1)
                          : Colors.transparent,
                      alignment: Alignment.centerLeft),
                  onPressed: () {
                    pageIndex = 1;
                    reportsPressed(pageIndex);
                  },
                  child: const Text(
                    "Reports",
                  ),
                )),
          ],
        ),
        companiesDropDown(userWithCompaniesModel, farm, onNewCompanySelected,
            onCreateCompanySelected),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            showMembersButton
                ? Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: IconButton(
                      icon: const Icon(Icons.group),
                      iconSize: 35,
                      color: Colors.white,
                      onPressed: () {
                        pageIndex = 2;
                        membersPressed(pageIndex);
                      },
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: inviteCount > 0
                    ? Stack(
                        children: <Widget>[
                          const Icon(Icons.person),
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
                                inviteCount.toString(),
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
                    : const Icon(Icons.person),
                iconSize: 35,
                color: Colors.white,
                onPressed: () {
                  pageIndex = 3;
                  profilePressed(pageIndex);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextButton(
                  onPressed: () {
                    logOutCallback();
                  },
                  child: const Text(
                    "Log Out",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ],
        )
      ],
    ),
  );
}

Widget companiesDropDown(
    UserWithCompaniesModel userWithCompaniesModel,
    CompanyModel? farm,
    Future<void> Function(CompanyModel) onNewCompanySelected,
    void Function() onCreateCompanySelected) {
  const textStyle =
      TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500);
  if (userWithCompaniesModel.user.isSuperAdmin) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: kIsWeb ? 0 : 1,
          child: Text(
            "Super Admin",
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
      ],
    );
  } else {
    return MobileCompaniesPopup(
        textStyle: textStyle,
        userWithCompaniesModel: userWithCompaniesModel,
        farm: farm,
        onNewCompanySelected: onNewCompanySelected,
        onCreateCompanySelected: onCreateCompanySelected);
  }
}

class MobileCompaniesPopup extends StatefulWidget {
  const MobileCompaniesPopup({
    super.key,
    required this.textStyle,
    required this.userWithCompaniesModel,
    required this.farm,
    required this.onNewCompanySelected,
    required this.onCreateCompanySelected,
  });

  final TextStyle textStyle;
  final UserWithCompaniesModel userWithCompaniesModel;
  final CompanyModel? farm;
  final Future<void> Function(CompanyModel) onNewCompanySelected;
  final void Function() onCreateCompanySelected;

  @override
  State<MobileCompaniesPopup> createState() => _MobileCompaniesPopupState();
}

class _MobileCompaniesPopupState extends State<MobileCompaniesPopup> {
  final GlobalKey _key = GlobalKey();
  bool isMenuOpened = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) {
        setState(() {
          isMenuOpened = true;
        });
      },
      child: PopupMenuButton<DropDownMenuCompanyItem>(
        key: _key,
        onCanceled: () {
          setState(() {
            isMenuOpened = false;
          });
        },
        shape: const ArrowedRoundedRectangleBorder(
            arrowHeight: 20, arrowWidth: 23, borderRadius: 10),
        offset: const Offset(0, kToolbarHeight * 3 / 4),
        padding: const EdgeInsets.all(8),
        // child: ConstrainedBox(
        //   constraints: const BoxConstraints(minWidth: 100),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!kIsWeb)
              Image.asset(
                'images/logo.png',
                width: 166 / 4.0,
                height: 317 / 4.0,
              ),
              // Spacer(),
              Flexible(
                flex: kIsWeb ? 0 : 1,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        flex: 0,
                        child: Text(
                            widget.userWithCompaniesModel.companies.isNotEmpty &&
                                    widget.farm != null
                                ? widget.farm!.name
                                    .setEllipsisOnOverflow(kIsWeb ? 30 : 15)
                                : "Guest",
                            overflow: TextOverflow.ellipsis,
                            style: widget.textStyle),
                      ),
                      const SizedBox(
                        width: kIsWeb ? 8 : 4,
                      ),
                      Icon(isMenuOpened
                          ? Icons.keyboard_arrow_up_outlined
                          : Icons.keyboard_arrow_down_outlined),
                    ],
                  ),
                ),
              ),
              // Spacer(),
            ],
          )),
        ),
        // ),
        itemBuilder: (context) {
          return [
            ...(widget.userWithCompaniesModel.companies.isNotEmpty &&
                    widget.farm != null
                ? widget.userWithCompaniesModel.companies
                    .map((e) => DropDownMenuCompanyItem(e.farm))
                    .toList()
                : <DropDownMenuCompanyItem>[]),
            DropDownMenuCompanyItem(null)
          ]
              .map(
                (e) => PopupMenuItem(
                  value: e,
                  padding: e.farm != null && e.farm!.id == widget.farm?.id
                      ? const EdgeInsets.symmetric(horizontal: 4, vertical: 0)
                      : null,
                  enabled: e.farm == null || e.farm!.id != widget.farm?.id,
                  child: Container(
                    decoration: e.farm != null && e.farm!.id == widget.farm?.id
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: AppColors.appPrimaryGreen)
                        : null,
                    padding: e.farm != null && e.farm!.id == widget.farm?.id
                        ? const EdgeInsets.all(8)
                        : null,
                    width: double.infinity,
                    child: Text(
                      e.farm == null ? "Create Company" : e.farm!.name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: e.farm == null
                              ? AppColors.appPrimaryGreen
                              : e.farm!.id == widget.farm?.id
                                  ? Colors.white
                                  : AppColors.subtitleGray),
                    ),
                  ),
                ),
              )
              .toList();
        },
        onSelected: (DropDownMenuCompanyItem dropDownMenuCompanyItem) {
          setState(() {
            isMenuOpened = false;
          });
          if (dropDownMenuCompanyItem.farm != null) {
            widget.onNewCompanySelected(dropDownMenuCompanyItem.farm!);
          } else {
            widget.onCreateCompanySelected();
          }
        },
      ),
    );
  }
}

class DropDownMenuCompanyItem {
  CompanyModel? farm;

  DropDownMenuCompanyItem(this.farm);
}

PreferredSizeWidget createPhoneAppBar(
    double toolbarHeight,
    void Function() notificationIconCallback,
    int notificationCount,
    UserWithCompaniesModel userWithCompaniesModel,
    CompanyModel? farm,
    Future<void> Function(CompanyModel) onNewCompanySelected,
    void Function() onCreateCompanySelected) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: AppColors.appPrimaryGreen,
    toolbarHeight: toolbarHeight,
    centerTitle: false,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: companiesDropDown(userWithCompaniesModel, farm,
              onNewCompanySelected, onCreateCompanySelected),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _notificationIcon(notificationIconCallback, notificationCount),
          ],
        ),
      ],
    ),
  );
}

Widget _notificationIcon(
    void Function() notificationIconCallback, int notificationCount) {
  return InkWell(
    onTap: notificationIconCallback,
    child: Center(
      child: SizedBox(
        width: 35,
        height: 35,
        child: Stack(
          children: [
            Image.asset(
              "images/iconNotification.png",
              width: 24,
              height: 24,
            ),
            if (notificationCount > 0)
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.topRight,
                margin: const EdgeInsets.only(top: 12, left: 2),
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xffc32c37),
                      border: Border.all(color: Colors.white, width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Center(
                      child: Text(
                        notificationCount.toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

Widget tabBar(int pageIndex) {
  if (pageIndex == 0) {
    return const TabBar(indicatorColor: Colors.white, tabs: [
      Tab(
        text: "Completed",
      ),
      Tab(text: "Status"),
    ]);
  } else if (pageIndex == 1) {
    return Container();
  } else {
    return const TabBar(indicatorColor: Colors.white, tabs: [
      Tab(
        text: "Collected",
      ),
      Tab(text: "Pending"),
    ]);
  }
}

class ArrowedRoundedRectangleBorder extends ShapeBorder {
  final double arrowWidth;
  final double arrowHeight;
  final double borderRadius;

  const ArrowedRoundedRectangleBorder({
    this.arrowWidth = 10.0,
    this.arrowHeight = 5.0,
    this.borderRadius = 8.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect.deflate(arrowHeight),
        textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(
      rect.topLeft,
      rect.bottomRight,
    );
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final dxCenter = rect.center.dx * 2 - arrowWidth * 3 / 2;

    final path = Path()
      ..addRRect(rRect)
      ..moveTo(dxCenter - arrowWidth / 2, rect.top)
      ..lineTo(dxCenter, rect.top - arrowHeight)
      ..lineTo(dxCenter + arrowWidth / 2, rect.top)
      ..close();

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
