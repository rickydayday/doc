import 'dart:core';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/DoctorAddAppointmentStep1Screen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/AppointmentWidget.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/main/utils/calender/flutter_clean_calendar.dart';
import 'package:kivicare_flutter/main/utils/date_utils.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class AppointmentFragment extends StatefulWidget {
  @override
  _AppointmentFragmentState createState() => _AppointmentFragmentState();
}

class _AppointmentFragmentState extends State<AppointmentFragment> {
  Map<DateTime, List> _events = Map<DateTime, List>();
  List<UpcomingAppointment> filterList = [];

  bool isLoading = false;
  bool isLoad = false;

  String startDate = '';
  String endDate = '';
  DateTime todayDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    startDate = DateTime(DateTime.now().year, DateTime.now().month, 1).getFormattedDate(CONVERT_DATE);
    endDate = DateTime(DateTime.now().year, DateTime.now().month, Utils.lastDayOfMonth(DateTime.now()).day).getFormattedDate(CONVERT_DATE);
    loadData();

    LiveStream().on(APP_UPDATE, (isUpdate) {
      if (isUpdate as bool) {
        setState(() {});
        loadData();
      }
    });
  }

  void loadData() {
    isLoading = true;
    setState(() {});
    getAppointmentData(startDate: startDate, endDate: endDate).then(
      (value) {
        value.appointmentData!.forEach(
          (element) {
            DateTime date = DateTime.parse(element.appointment_start_date!);
            _events.addAll(
              {
                DateTime(date.year, date.month, date.day): [
                  {'name': 'Event A', 'isDone': true, 'time': '9 - 10 AM'}
                ]
              },
            );
          },
        );
        setState(() {});
        if (DateTime.parse(startDate).month == DateTime.now().month) {
          showData(DateTime.now());
        }
      },
    ).catchError(
      (e) {
        isLoading = false;
        setState(() {});
        errorToast(e.toString());
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void showData(DateTime dateTime) {
    isLoading = true;
    setState(() {});
    filterList.clear();

    getAppointmentInCalender(todayDate: dateTime.getFormattedDate(CONVERT_DATE), page: 1).then((value) {
      filterList.addAll(value.appointmentData!);

      setState(() {});
    }).catchError(((e) {
      errorToast(e.toString());
    })).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant AppointmentFragment oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(APP_UPDATE);
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            child: Calendar(
              startOnMonday: true,
              weekDays: [
                translate("lblMon"),
                translate("lblTue"),
                translate("lblWed"),
                translate("lblThu"),
                translate("lblFri"),
                translate("lblSat"),
                translate("lblSun"),
              ],
              events: _events,
              onDateSelected: (e) => showData(e),
              onRangeSelected: (Range range) {
                startDate = range.from.getFormattedDate(CONVERT_DATE);
                endDate = range.to.getFormattedDate(CONVERT_DATE);
                loadData();
              },
              isExpandable: true,
              locale: appStore.selectedLanguage,
              isExpanded: true,
              eventColor: appSecondaryColor,
              selectedColor: primaryColor,
              todayColor: primaryColor,
            
              dayOfWeekStyle: TextStyle(color: appStore.isDarkModeOn ? Colors.white : Colors.black, fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ),
          16.height,
          Text(translate('lblTodaySAppointments'), style: boldTextStyle()),
          16.height,
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filterList.length,
            itemBuilder: (BuildContext context, int index) {
              return AppointmentWidget(upcomingData: filterList[index]);
            },
          ).visible(!isLoading, defaultWidget: setLoader()),
          16.height,
          noDataWidget(text: translate('lblNotAppointmentForThisDay')).visible(filterList.isEmpty && !isLoading).center(),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: AddFloatingButton(
          onTap: () async {
            // appointmentAppStore.setSelectedDoctor(listAppStore.doctorList.firstWhere((element) => element.iD == getIntAsync(USER_ID)));
            bool? res = await DoctorAddAppointmentStep1Screen(id: getIntAsync(USER_ID)).launch(context);
            if (res ?? false) setState(() {});
          },
        ),
        body: body(),
      ),
    );
  }
}
