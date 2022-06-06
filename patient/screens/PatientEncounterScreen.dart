import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/doctor/screens/EncounterDashboardScreen.dart';
import 'package:kivicare_flutter/main/model/PatientEncounterListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/screens/PatientEncounterDashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientEncounterScreen extends StatefulWidget {
  @override
  _PatientEncounterScreenState createState() => _PatientEncounterScreenState();
}

class _PatientEncounterScreenState extends State<PatientEncounterScreen> {
  int page = 1;

  bool isLoading = false;
  bool isList = false;
  bool isLastPage = false;
  bool isReady = false;

  List<PatientEncounterData> patientEncounterList = [];

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: translate('lblEncounters'), elevation: 0),
        body: body(),
      ),
    );
  }

  Widget body() {
    return Container(
      padding: EdgeInsets.all(8),
      child: NotificationListener(
        onNotification: (dynamic n) {
          if (!isLastPage && isReady) {
            if (n is ScrollEndNotification) {
              page++;
              isReady = false;

              setState(() {});
            }
          }
          return !isLastPage;
        },
        child: FutureBuilder<PatientEncounterListModel>(
          future: getPatientEncounterList(getIntAsync(USER_ID), page: page),
          builder: (_, snap) {
            if (snap.hasData) {
              if (page == 1) patientEncounterList.clear();

              patientEncounterList.addAll(snap.data!.patientEncounterData!);
              isReady = true;

              isLastPage = snap.data!.total.validate().toInt() <= patientEncounterList.length;

              if (patientEncounterList.isNotEmpty) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(translate('lblPatientsEncounter') + ' (${snap.data!.total})', style: primaryTextStyle()),
                      16.height,
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: patientEncounterList.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          var data = patientEncounterList[index];
                          DateTime tempDate = DateFormat(CONVERT_DATE).parse(data.encounter_date.validate());
                          return Container(
                            decoration: boxDecorationWithShadow(
                                blurRadius: 0,
                                spreadRadius: 0,
                                borderRadius: BorderRadius.circular(defaultRadius),
                                backgroundColor: Theme.of(context).cardColor,
                                border: Border.all(color: viewLineColor)),
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.only(top: 8, bottom: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 60,
                                  child: Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(text: tempDate.day.toString(), style: boldTextStyle(size: 22)),
                                            WidgetSpan(
                                              child: Transform.translate(
                                                offset: const Offset(2, -10),
                                                child: Text(getDayOfMonthSuffix(tempDate.day.validate()).toString(), textScaleFactor: 0.7, style: boldTextStyle(size: 14)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Text(tempDate.month.getMonthName().toString(), textAlign: TextAlign.center, style: secondaryTextStyle(size: 14)),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 60,
                                  child: VerticalDivider(color: Colors.grey.withOpacity(0.5), width: 25, thickness: 1, indent: 4, endIndent: 1),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(data.clinic_name.validate(), style: secondaryTextStyle()),
                                        menuOption(data: data),
                                      ],
                                    ),
                                    5.height,
                                    Row(
                                      children: [
                                        Text(translate('lblDoctor') + ': ', style: boldTextStyle()),
                                        4.width,
                                        Text(data.doctor_name.validate(), style: primaryTextStyle(color: primaryColor)),
                                      ],
                                    ),
                                    5.height,
                                    Row(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(translate('lblDescription') + ': ', style: boldTextStyle()),
                                            4.width,
                                            Text(data.description.validate().isNotEmpty?data.description.validate().trim():'not found', style: primaryTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis).expand(),
                                          ],
                                        ).expand(),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: boxDecorationWithRoundedCorners(
                                              backgroundColor: getEncounterStatusColor(data.status).withOpacity(0.2), borderRadius: BorderRadius.circular(defaultRadius)),
                                          child: Text("${getEncounterStatus(data.status)}".toUpperCase(), style: boldTextStyle(size: 10, color: getEncounterStatusColor(data.status))),
                                        )
                                      ],
                                    ),
                                  ],
                                ).expand(),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return noDataWidget(text: translate('lblNoEncounterFound'));
              }
            }
            return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
          },
        ),
      ),
    );
  }

  Widget menuOption({PatientEncounterData? data}) {
    return PopupMenuButton(
      onSelected: (dynamic value) async {
        if (value == 0) {
          if (isPatient()) {
            PatientEncounterDashboardScreen(id: data!.id.toInt()).launch(context);
          } else {
            EncounterDashboardScreen(id: data!.id, name: data.patient_name).launch(context);
          }
        } else if (value == 1) {
          bool res = await (showConfirmDialog(context, translate('lblDeleteRecordConfirmation') + " ${data!.clinic_name.validate()}?", buttonColor: primaryColor));
          if (res) {
            isLoading = true;
            setState(() {});
            Map request = {"patient_id": data.id};

            deletePatientData(request).then((value) {
              successToast(translate('lblAllRecordsFor') + " ${data.clinic_name.validate()} " + translate('lblAreDeleted'));
            }).catchError((e) {
              errorToast(e.toString());
            }).whenComplete(() {
              isLoading = false;
              setState(() {});
            });
          }
        }
      },
      child: Icon(Icons.more_vert_outlined, size: 20),
      itemBuilder: (BuildContext context) {
        List<PopupMenuItem> list = [];

        list.add(
          PopupMenuItem(
            value: 0,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(FontAwesomeIcons.gaugeHigh, size: 16).withWidth(20),
                6.width,
                Text(translate('lblDashboard'), style: primaryTextStyle(size: 14)),
              ],
            ),
          ),
        );
        list.add(
          PopupMenuItem(
            value: 1,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(FontAwesomeIcons.trash, size: 16).withWidth(20),
                6.width,
                Text(translate('lblDelete'), style: primaryTextStyle(size: 14)),
              ],
            ),
          ),
        );
        return list;
      },
    );
  }
}
