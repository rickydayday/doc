import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/doctor/screens/AddReportScreen.dart';
import 'package:kivicare_flutter/main/model/ReportModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientReportScreen extends StatefulWidget {
  final int? patientId;

  PatientReportScreen({this.patientId});

  @override
  _PatientReportScreenState createState() => _PatientReportScreenState();
}

class _PatientReportScreenState extends State<PatientReportScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;
  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
  }

  void deleteReportData(String? id) {
    isLoading = true;
    setState(() {});
    Map<String, dynamic> res = {"report_id": "$id"};
    deleteReport(res).then((value) {
      toast('Deleted');
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: translate("lblPatientReport")),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(translate('lblMedicalReport'), style: boldTextStyle(size: 18)).expand(),
                Text(translate('lblNewMedicalReport'), style: secondaryTextStyle(size: 14)).onTap(
                  () async {
                    bool? res = await AddReportScreen(patientId: widget.patientId).launch(context);
                    if (res ?? false) {
                      setState(() {});
                    }
                  },
                )
              ],
            ).paddingAll(8),
            FutureBuilder<ReportModel>(
              future: getReportData(patientId: widget.patientId),
              builder: (_, snap) {
                if (snap.hasData) {
                  return Container(
                    child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snap.data!.reportData!.length,
                      itemBuilder: (context, index) {
                        ReportData data = snap.data!.reportData![index];
                        DateTime tempDate = new DateFormat(CONVERT_DATE).parse(data.date!);

                        return Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: boxDecorationWithShadow(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            border: Border.all(color: context.dividerColor),
                            spreadRadius: 0,
                            blurRadius: 0,
                            backgroundColor: context.scaffoldBackgroundColor,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(text: tempDate.day.toString(), style: boldTextStyle(size: 18)),
                                          WidgetSpan(
                                            child: Transform.translate(
                                              offset: const Offset(2, -10),
                                              child: Text(getDayOfMonthSuffix(tempDate.day).toString(), textScaleFactor: 0.7, style: boldTextStyle(size: 14)),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Text(tempDate.month.getMonthName()!, textAlign: TextAlign.center, style: secondaryTextStyle(size: 14)),
                                  ],
                                ),
                              ),
                              VerticalDivider(color: viewLineColor, width: 25, thickness: 1, indent: 1, endIndent: 1).withHeight(50),
                              Text('${data.name}', style: boldTextStyle(size: 18)).expand(),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red.withOpacity(0.8)),
                                    onPressed: () async {
                                      bool? res = await showConfirmDialog(context, translate('lblAreYouSure'));
                                      if (res ?? false) {
                                        deleteReportData(data.id);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_red_eye, color: primaryColor),
                                    onPressed: () {
                                      launchUrl("${data.upload_report_url}", enableJavaScript: false, statusBarBrightness:  Brightness.dark);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
                if (snap.connectionState == ConnectionState.waiting) return setLoader();
                return snapWidgetHelper(snap);
              },
            ),
          ],
        ).paddingAll(8),
      ),
    );
  }
}
