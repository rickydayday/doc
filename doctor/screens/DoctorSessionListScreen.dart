import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/AddSessionScreen.dart';
import 'package:kivicare_flutter/main/model/DoctorScheduleModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorSessionListScreen extends StatefulWidget {
  @override
  _DoctorSessionListScreenState createState() => _DoctorSessionListScreenState();
}

class _DoctorSessionListScreenState extends State<DoctorSessionListScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    setDynamicStatusBarColor();
  }

  Widget body() {
    return Container(
      child: FutureBuilder<DoctorSessionModel>(
        future: getDoctorSessionData(clinicData: isProEnabled() ? getIntAsync(USER_CLINIC) : getIntAsync(USER_CLINIC)),
        builder: (_, snap) {
          if (snap.hasData) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate('lblDoctorSessions') + ' (${snap.data!.sessionData!.length.validate()})', style: boldTextStyle()),
                  16.height,
                  ListView.builder(
                    itemCount: snap.data!.sessionData!.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      SessionData data = snap.data!.sessionData![index];
                      String morningStart = '-';
                      String morningEnd = '-';
                      String eveningStart = '-';
                      String eveningEnd = '-';

                      if (data.s_one_start_time!.hH!.isNotEmpty) {
                        morningStart = '${data.s_one_start_time!.hH.validate(value: '00')}:${data.s_one_start_time!.mm.validate(value: '00')}';
                      }
                      if (data.s_one_start_time!.hH!.isNotEmpty) {
                        morningEnd = '${data.s_one_end_time!.hH.validate(value: '00')}:${data.s_one_end_time!.mm.validate(value: '00')}';
                      }
                      if (data.s_two_start_time!.hH!.isNotEmpty) {
                        eveningStart = '${data.s_two_start_time!.hH.validate(value: '00')}:${data.s_two_start_time!.mm.validate(value: '00')}';
                      }
                      if (data.s_two_start_time!.hH!.isNotEmpty) {
                        eveningEnd = '${data.s_two_end_time!.hH.validate(value: '00')}:${data.s_two_end_time!.mm.validate(value: '00')}';
                      }

                      return GestureDetector(
                        onTap: () async {
                          bool? res = await AddSessionsScreen(sessionData: data).launch(context);
                          if (res ?? false) {
                            setState(() {});
                          }
                        },
                        child: Container(
                          decoration: boxDecorationWithShadow(
                            blurRadius: 0,
                            spreadRadius: 0,
                            borderRadius: BorderRadius.circular(defaultRadius),
                            border: Border.all(color: context.dividerColor),
                            backgroundColor: Theme.of(context).cardColor,
                          ),
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(data.doctors.validate(), style: boldTextStyle(color: primaryColor, size: 18)).expand(),
                                  Text('${data.clinic_name.validate()}', style: boldTextStyle(size: 16)),
                                ],
                              ),
                              4.height,
                              Text('${data.specialties.validate()}', style: secondaryTextStyle()),
                              4.height,
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(translate('lblMorningSession') + ':', style: primaryTextStyle(size: 14)),
                                      Text(translate('lblEveningSession') + ':', style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.width,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("$morningStart to $morningEnd", style: boldTextStyle(size: 14)),
                                      eveningStart == "-" ? Text('--', style: boldTextStyle()) : Text("$eveningStart to $eveningEnd ", style: boldTextStyle(size: 14)),
                                    ],
                                  ),
                                ],
                              ),
                              4.height,
                              Wrap(
                                runSpacing: 4,
                                spacing: 4,
                                children: List.generate(
                                  data.days!.length,
                                  (index) => Chip(
                                    backgroundColor: selectedColor,
                                    label: Text(
                                      data.days![index],
                                      style: primaryTextStyle(color: appPrimaryColor, size: 12),
                                    ),
                                  ),
                                ),
                              ),
                              4.height,
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            );
          }
          return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: translate('lblDoctorSessions')),
        body: body(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () async {
            bool? res = await AddSessionsScreen().launch(context);
            if (res ?? false) {
              setState(() {});
            }
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
