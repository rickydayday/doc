import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/Fragments/AppointmentFragment.dart';
import 'package:kivicare_flutter/doctor/Fragments/DashboardFragment.dart';
import 'package:kivicare_flutter/doctor/Fragments/PatientFragment.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/SettingFragment.dart';
import 'package:kivicare_flutter/main/components/TopNameWidget.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorDashboardScreen extends StatefulWidget {
  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int currentIndex = 0;
  List<Widget> _children = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    // getDoctor();
    // getPatient();
    // getSpecialization();
    // getServices();

    _children.add(DashboardFragment());
    _children.add(AppointmentFragment());
    _children.add(PatientFragment());
    _children.add(SettingFragment());
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
              margin: EdgeInsets.only(top: 66),
              child: _children[currentIndex],
            ).visible(currentIndex != 3, defaultWidget: _children[currentIndex]),
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
                child: Image.asset('images/icons/dashboard.png', height: 25, width: 25, color: Color(0xFF4974dc)),
              ).cornerRadiusWithClipRRect(10),
              label: translate('lblDashboard'),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Image.asset('images/icons/appoitnment.png', height: 25, width: 25, color: appStore.isDarkModeOn ? Colors.white : Colors.black),
              ),
              activeIcon: Container(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                decoration: boxDecorationWithShadow(backgroundColor: appStore.isDarkModeOn ? cardSelectedColor : selectedColor),
                child: Image.asset('images/icons/appoitnment.png', height: 25, width: 25, color: Color(0xFF4974dc)),
              ).cornerRadiusWithClipRRect(10),
              label: translate('lblAppointments'),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                child: Image.asset('images/icons/patient.png', height: 25, width: 25, color: appStore.isDarkModeOn ? Colors.white : Colors.black),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: boxDecorationWithShadow(backgroundColor: appStore.isDarkModeOn ? cardSelectedColor : selectedColor),
                child: Image.asset('images/icons/patient.png', height: 25, width: 25, color: Color(0xFF4974dc)),
              ).cornerRadiusWithClipRRect(10),
              label: translate('lblPatients'),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                child: Image.asset('images/icons/moreitems.png', height: 25, width: 25, color: appStore.isDarkModeOn ? Colors.white : Colors.black),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: boxDecorationWithShadow(backgroundColor: appStore.isDarkModeOn ? cardSelectedColor : selectedColor),
                child: Image.asset('images/icons/moreitems.png', height: 25, width: 25, color: Color(0xFF4974dc)),
              ).cornerRadiusWithClipRRect(10),
              label: translate('lblSettings'),
            ),
          ],
        ),
      ),
    );
  }
}
