import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/Fragments/ProfileBasicInformation.dart';
import 'package:kivicare_flutter/doctor/Fragments/ProfileBasicSetting.dart';
import 'package:kivicare_flutter/doctor/Fragments/ProfileQualification.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  AsyncMemoizer<GetDoctorDetailModel> _memorizer = AsyncMemoizer();

  int currentIndex = 0;

  TabController? tabController;

  TextEditingController degreeCont = TextEditingController();
  TextEditingController universityCont = TextEditingController();
  TextEditingController yearCont = TextEditingController();

  FocusNode degreeFocus = FocusNode();
  FocusNode universityFocus = FocusNode();
  FocusNode yearFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
    tabController = TabController(length: 3, vsync: this);
    tabController!.addListener(() {
      setState(() {
        currentIndex = tabController!.index;
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    degreeCont.dispose();
    universityCont.dispose();
    yearCont.dispose();

    degreeFocus.dispose();
    universityFocus.dispose();
    yearFocus.dispose();
    setDynamicStatusBarColor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: appPrimaryColor,
            title: Text(translate('lblEditProfile')),
            elevation: 4.0,
            titleSpacing: 0.0,
            shadowColor: shadowColorGlobal,
            bottom: TabBar(
                physics: NeverScrollableScrollPhysics(),
                labelColor: appPrimaryColor,
                unselectedLabelColor: Colors.white,
                onTap: (i) {
                  tabController!.index = tabController!.previousIndex;
                },
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                controller: tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  color: appStore.isDarkModeOn ? cardSelectedColor : Colors.white,
                ),
                tabs: [
                  Tab(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                      child: Text(translate('lblBasicInfo').toUpperCase(), style: primaryTextStyle()),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                      child: Text(translate('lblBasicSettings').toUpperCase(), style: primaryTextStyle()),
                    ),
                  ).visible(getStringAsync(USER_ROLE) != UserRoleReceptionist),
                  Tab(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                      child: Text(translate('lblQualification').toUpperCase(), style: primaryTextStyle()),
                    ),
                  ).visible(getStringAsync(USER_ROLE) != UserRoleReceptionist),
                ]),
          ),
          body: FutureBuilder<GetDoctorDetailModel>(
            future: _memorizer.runOnce(() => getUserProfile(getIntAsync(USER_ID))),
            builder: (_, snap) {
              if (snap.hasData) {
                return TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: [
                    ProfileBasicInformation(
                      getDoctorDetail: snap.data,
                      onSave: (bool? s) {
                        if (s ?? false) {
                          tabController!.animateTo(currentIndex + 1);
                        }
                      },
                    ),
                    ProfileBasicSettings(
                      getDoctorDetail: snap.data,
                      onSave: (bool? s) {
                        if (s ?? false) {
                          tabController!.animateTo(currentIndex + 1);
                        }
                      },
                    ),
                    ProfileQualification(getDoctorDetail: snap.data).visible(getStringAsync(USER_ROLE) != UserRoleReceptionist),
                  ],
                );
              }
              return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
            },
          ),
        ),
      ),
    );
  }
}
