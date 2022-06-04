
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/doctor/components/DashBoardCountWidget.dart';
import 'package:kivicare_flutter/doctor/components/WeeklyChartComponent.dart';
import 'package:kivicare_flutter/main/components/AppointmentListWidget.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  List<DashBoardCountWidget> dashboardCount = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {}

  @override
  void didUpdateWidget(covariant DashboardFragment oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DoctorDashboardModel>(
      future: getDoctorDashBoard(),
      builder: (_, snap) {
        if (snap.hasData) {
          return ListView(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 60),
            shrinkWrap: true,
            children: [
              8.height,
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  DashBoardCountWidget(
                    title: translate('lblTotalPatient'),
                    color1: Color(0x8CEF7663),
                    color2: Color(0x8CE2A17C),
                    subTitle: translate('lblTotalVisitedPatients'),
                    count: snap.data!.total_patient.validate(),
                    icon: FontAwesomeIcons.userInjured,
                  ),
                  DashBoardCountWidget(
                    title: translate('lblTotalAppointment'),
                    color1: Color(0x8C77EAB2),
                    color2: Color(0x8C58CDB2),
                    subTitle: translate('lblTotalVisitedAppointment'),
                    count: snap.data!.total_appointment.validate(),
                    icon: FontAwesomeIcons.calendarCheck,
                  ),
                  DashBoardCountWidget(
                    title: translate('lblTodayAppointments'),
                    color1: Color(0x8C77EAB2),
                    color2: Color(0x8C58CDB2),
                    subTitle: translate('lblTotalTodayAppointments'),
                    count: snap.data!.upcoming_appointment_total.validate(),
                    icon: FontAwesomeIcons.calendarCheck,
                  ),
                  DashBoardCountWidget(
                    title: translate('lblTotalServices'),
                    color1: Color(0x8C77EAB2),
                    color2: Color(0x8C58CDB2),
                    subTitle: translate('lblTotalServices'),
                    count: snap.data!.total_service.validate(),
                    icon: FontAwesomeIcons.moneyCheckAlt,
                  ),
                ],
              ),
              16.height,
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate('lblWeeklyAppointments').toUpperCase(), style: secondaryTextStyle(size: 10)).paddingSymmetric(horizontal: 8),
                  Text(translate('lblWeeklyTotalAppointments'), style: boldTextStyle()).paddingAll(8),
                  16.height,
                  snap.data!.weekly_appointment!.isNotEmpty
                      ? Container(
                          height: 350,
                          child: WeeklyChartComponent(weeklyAppointment: snap.data!.weekly_appointment).withWidth(context.width()),
                        )
                      : Container(
                          height: 350,
                          child: WeeklyChartComponent(weeklyAppointment: emptyGraphList).withWidth(context.width()),
                        ),
                ],
              ),
              8.height,
              Text(translate('lblTodaySAppointments'), style: boldTextStyle()).paddingAll(8),
              AppointmentListWidget(upcomingAppointment: snap.data!.upcoming_appointment).paddingSymmetric(horizontal: 8),
              noDataWidget(text: translate('lblNoAppointmentForToday')).visible(snap.data!.upcoming_appointment!.isEmpty),
            ],
          );
        }
        return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
      },
    );
  }
}
