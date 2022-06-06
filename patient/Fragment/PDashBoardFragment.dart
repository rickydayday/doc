import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/doctor/components/DashBoardCountWidget.dart';
import 'package:kivicare_flutter/main/components/AppointmentWidget.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/model/PatientDashboardModel.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/components/DoctorDashboardWidget.dart';
import 'package:kivicare_flutter/patient/components/NewsDashboardWidget.dart';
import 'package:kivicare_flutter/patient/components/NewsListWidget.dart';
import 'package:kivicare_flutter/patient/model/NewsModel.dart';
import 'package:kivicare_flutter/patient/screens/DoctorListScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import 'PatientUpcomingAppointmentFragment.dart';

class PDashBoardFragment extends StatefulWidget {
  @override
  _PDashBoardFragmentState createState() => _PDashBoardFragmentState();
}

class _PDashBoardFragmentState extends State<PDashBoardFragment> {
  TextEditingController searchCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    searchCont.dispose();
    super.dispose();
  }

  Widget patientTotalDataComponent({required List<UpcomingAppointment> upcomingAppointment}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(translate('lblUpcomingAppointments'), style: boldTextStyle(size: 20)).expand(),
            Text(translate('lblViewAll'), style: secondaryTextStyle()).onTap(() {
              PatientUpcomingAppointmentFragment().launch(context);
            }).visible(upcomingAppointment.length >= 2),
          ],
        ),
        16.height,
        Wrap(
          children: upcomingAppointment
              .map((UpcomingAppointment data) {
                return AppointmentWidget(upcomingData: data);
              })
              .take(2)
              .toList(),
        ).visible(upcomingAppointment.isNotEmpty, defaultWidget: noAppointmentDataWidget(text: translate('lblNoUpcomingAppointments'))),
      ],
    );
  }

  Widget patientSymptomsComponent({required List<Service> service}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translate('lblClinicServices'), style: boldTextStyle(size: 20)),
                4.height,
                Text(translate('lblFindOurBestServices'), style: secondaryTextStyle()),
                16.height,
              ],
            ).expand(),
          ],
        ).paddingSymmetric(horizontal: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
              direction: Axis.horizontal,
              spacing: 16,
              runSpacing: 16,
              children: service.map((data) {
                String image = getServicesImages()[service.indexOf(data) % getServicesImages().length];
                return Container(
                  width: 70,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        padding: EdgeInsets.all(8),
                        decoration: boxDecorationWithShadow(
                          boxShape: BoxShape.circle,
                        ),
                        child: Image.asset(image),
                      ),
                      12.height,
                      Text(
                        '${data.name.validate()}',
                        textAlign: TextAlign.center,
                        style: primaryTextStyle(size: 12),
                        softWrap: true,
                        textWidthBasis: TextWidthBasis.longestLine,
                        textScaleFactor: 1,
                      ),
                    ],
                  ),
                );
              }).toList()),
        ),
      ],
    );
  }

  Widget topDoctorComponent({required List<DoctorList> doctorList}) {
    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translate('lblTopDoctors'), style: boldTextStyle(size: 20)),
                4.height,
                Text(translate('lblFindTheBestDoctors'), style: secondaryTextStyle()),
                8.height,
              ],
            ).expand(),
            Text(translate('lblViewAll'), style: secondaryTextStyle()).onTap(() {
              DoctorListScreen().launch(context);
            }).visible(doctorList.length >= 2),
          ],
        ),
        Wrap(
          runSpacing: 8,
          spacing: 16,
          children: doctorList
              .map((e) {
                String maleImage = "images/doctorAvatars/doctor2.png";
                String femaleImage = "images/doctorAvatars/doctor1.png";
                String image = e.gender!.toLowerCase() == "male" ? maleImage : femaleImage;
                return DoctorDashboardWidget(image: image, data: e);
              })
              .take(2)
              .toList(),
        ),
      ],
    );
  }

  Widget newsComponent({required List<NewsData> newsData}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translate('lblExpertsHealthTipsAndAdvice'), style: boldTextStyle(size: 20)),
                1.height,
                Text(translate('lblArticlesByHighlyQualifiedDoctors'), style: secondaryTextStyle()),
              ],
            ).expand(),
            Text(translate('lblViewAll'), style: boldTextStyle()).onTap(() {
              NewsListWidget(newsData: newsData).launch(context);
            }).visible(newsData.length >= 2),
          ],
        ),
        20.height,
        Wrap(
          runSpacing: 16,
          children: newsData
              .map((e) {
                return NewsDashboardWidget(newsData: e, index: newsData.indexOf(e));
              })
              .take(3)
              .toList(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatientDashboardModel>(
      future: getPatientDashBoard(),
      builder: (context, snap) {
        if (snap.hasData) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(
              8
            ),
            child: Column(
              children: [
               Wrap(
                 spacing: 16,
                 runSpacing: 16,
                 children: [
                   DashBoardCountWidget(
                     title: translate('lblTotalUpcoming'),
                     color1: Color(0x8CE3482F),
                     color2: Color(0x8CE3712F),
                     subTitle: translate('lblTotalTodayAppointments'),
                     count: snap.data!.upcoming_appointment_total.validate(),
                     icon: FontAwesomeIcons.userInjured,
                   ),
                   DashBoardCountWidget(
                     title: translate('lblTotalAppointment'),
                     color1: Color(0x8C38C17E),
                     color2: Color(0x8C38C1A2),
                     subTitle: translate('lblTotalVisitedAppointment'),
                     count: snap.data!.total_appointment.validate(),
                     icon: FontAwesomeIcons.calendarCheck,
                   ),
                 ],
               ),
                16.height,
                patientTotalDataComponent(upcomingAppointment: snap.data!.upcoming_appointment!).paddingAll(8),
                patientSymptomsComponent(service: snap.data!.serviceList!).paddingSymmetric(vertical: 8),
                topDoctorComponent(doctorList: snap.data!.doctor.validate()).paddingAll(8),
                newsComponent(newsData: snap.data!.news!).paddingAll(8),
              ],
            ),
          );
        }
        return snapWidgetHelper(snap);
      },
    );
  }
}
