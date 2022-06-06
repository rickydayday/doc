import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/SettingFragment.dart';
import 'package:kivicare_flutter/main/components/TopNameWidget.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:kivicare_flutter/patient/Fragment/FeedListFragment.dart';
import 'package:kivicare_flutter/patient/Fragment/PDashBoardFragment.dart';
import 'package:kivicare_flutter/patient/Fragment/PatientAppointmentFragment.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientDashBoardScreen extends StatefulWidget {
  @override
  _PatientDashBoardScreenState createState() => _PatientDashBoardScreenState();
}

class _PatientDashBoardScreenState extends State<PatientDashBoardScreen> {
  int currentIndex = 0;
  final List<Widget> _children = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    getDoctor();
    getPatient();
    getSpecialization();
    _children.add(PDashBoardFragment());
    _children.add(PatientAppointmentFragment());
    _children.add(FeedListFragment());
    _children.add(SettingFragment());
    await Future.delayed(Duration(milliseconds: 400));

    window.onPlatformBrightnessChanged = () {
      if (getIntAsync(THEME_MODE_INDEX) == ThemeModeSystem) {
        appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.light);
      }
    };
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            TopNameWidget().visible(currentIndex != 3),
            Container(
              margin: EdgeInsets.only(top: currentIndex != 3 ? 70 : 0),
              child: _children[currentIndex],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) {
            currentIndex = i;
            setState(() {});
          },
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Theme.of(context).iconTheme.color,
          backgroundColor: Theme.of(context).cardColor,
          mouseCursor: MouseCursor.uncontrolled,
          elevation: 12,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Image.asset('images/icons/dashboard.png', height: 25, width: 25, color: appStore.isDarkModeOn ? Colors.white : Colors.black),
              ),
              activeIcon: Container(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                decoration: boxDecorationWithShadow(backgroundColor: appStore.isDarkModeOn ? cardSelectedColor : selectedColor),
                child: Image.asset('images/icons/dashboard.png', height: 25, width: 25, color: primaryColor),
              ).cornerRadiusWithClipRRect(10),
              label: translate('lblPatientDashboard'),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Image.asset('images/icons/appoitnment.png', height: 25, width: 25, color: appStore.isDarkModeOn ? Colors.white : Colors.black),
              ),
              activeIcon: Container(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                decoration: boxDecorationWithShadow(backgroundColor: appStore.isDarkModeOn ? cardSelectedColor : selectedColor),
                child: Image.asset('images/icons/appoitnment.png', height: 25, width: 25, color: primaryColor),
              ).cornerRadiusWithClipRRect(10),
              label: translate('lblAppointments'),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                child: SvgPicture.asset('images/icons/feed.svg', height: 25, width: 25, color: appStore.isDarkModeOn ? Colors.white : Colors.black),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: boxDecorationWithShadow(backgroundColor: appStore.isDarkModeOn ? cardSelectedColor : selectedColor),
                child: SvgPicture.asset('images/icons/feed.svg', height: 25, width: 25, color: primaryColor),
              ).cornerRadiusWithClipRRect(10),
              label: translate('lblFeedsAndArticles'),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                child: Image.asset('images/icons/moreitems.png', height: 25, width: 25, color: appStore.isDarkModeOn ? Colors.white : Colors.black),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: boxDecorationWithShadow(backgroundColor: appStore.isDarkModeOn ? cardSelectedColor : selectedColor),
                child: Image.asset('images/icons/moreitems.png', height: 25, width: 25, color: primaryColor),
              ).cornerRadiusWithClipRRect(10),
              label: translate('lblSettings'),
            ),
          ],
        ),
      ),
    );
  }
}
