import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/Fragments/PrescriptionFragment.dart';
import 'package:kivicare_flutter/doctor/Fragments/ProfileDetailFragment.dart';
import 'package:kivicare_flutter/doctor/components/AddPrescriptionScreen.dart';
import 'package:kivicare_flutter/main/components/EncounterListWidget.dart';
import 'package:kivicare_flutter/main/model/EncounterDashboardModel.dart';
import 'package:kivicare_flutter/main/model/LoginResponseModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';


class EncounterDashboardScreen extends StatefulWidget {
  final String? id;
  final String? name;

  EncounterDashboardScreen({this.id, this.name});

  @override
  _EncounterDashboardScreenState createState() => _EncounterDashboardScreenState();
}

class _EncounterDashboardScreenState extends State<EncounterDashboardScreen> with SingleTickerProviderStateMixin {
  TabController? tabController;

  EncounterDashboardModel? encounterDashboardModel;

  List<EnocunterModule>? encounterModuleList;
  List<PrescriptionModule>? prescriptionModuleList;
  List<Tab> tabData = [];
  List<Widget> tabWidgets = [];

  String? paymentStatus;

  int tabBarLength = 0;
  int currentIndex = 0;
  int? encounterId;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
    getEncounterDetailsDashBoard(widget.id.toInt()).then((value) async {
      await getConfiguration().catchError(log);
      if (isProEnabled()) {
        tabData.clear();
        tabWidgets.clear();
        encounterDashboardModel = value;
        paymentStatus=value.payment_status;
        setState(() { });
        tabBarLength = 1;

        tabData.add(Tab(
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            child: Text("${translate("lblEncounterDetails")}".toUpperCase()),
          ),
        ));
        tabWidgets.add(ProfileDetailFragment(encounterId: value.id.toInt(), patientEncounterDetailData: value, isStatusBack: true));

        if (value.enocunter_modules!.isNotEmpty) {
          value.enocunter_modules!.forEach((element) {
            if (element.status.toInt() == 1) {
              tabBarLength = tabBarLength + 1;

              setState(() {});
            }

            if (element.status.toInt() == 1) {
              tabData.add(
                Tab(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                    child: Text("${element.label.validate()}".toUpperCase()),
                  ),
                ),
              );

              tabWidgets.add(EncounterListWidget(id: value.id.toInt(), encounterType: element.name.validate(), paymentStatus: value.payment_status));
            }
          });
        }

        if (value.prescription_module!.isNotEmpty) {
          value.prescription_module!.forEach((element) {
            if (element.status.toInt() == 1) {
              tabBarLength = tabBarLength + 1;
            }
            if (element.status.toInt() == 1) {
              tabData.add(
                Tab(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                    child: Text("${element.label}".toUpperCase()),
                  ),
                ),
              );
              tabWidgets.add(PrescriptionFragment(id: value.id.toInt()));
            }
          });
        }
      } else {
        tabBarLength = 5;
        setState(() {});
        tabData.add(Tab(
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            child: Text(translate("lblEncounterDetails").toUpperCase()),
          ),
        ));
        tabWidgets.add(ProfileDetailFragment(encounterId: value.id.toInt(), patientEncounterDetailData: value, isStatusBack: true));
        tabData.add(
          Tab(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Text(translate("lblProblems").toUpperCase()),
            ),
          ),
        );
        tabWidgets.add(EncounterListWidget(id: value.id.toInt(), encounterType: PROBLEM, paymentStatus: value.payment_status));
        tabData.add(
          Tab(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Text(translate("lblObservation").toUpperCase()),
            ),
          ),
        );
        tabWidgets.add(EncounterListWidget(id: value.id.toInt(), encounterType: OBSERVATION, paymentStatus: value.payment_status));
        tabData.add(
          Tab(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Text(translate("lblNotes").toUpperCase()),
            ),
          ),
        );
        tabWidgets.add(EncounterListWidget(id: value.id.toInt(), encounterType: NOTE, paymentStatus: value.payment_status));
        tabData.add(
          Tab(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Text(translate("lblPrescription").toUpperCase()),
            ),
          ),
        );
        tabWidgets.add(PrescriptionFragment(id: value.id.toInt()));
      }

      tabController = TabController(length: tabBarLength, vsync: this);
      tabController?.addListener(() {
        currentIndex = tabController!.index.validate();
        setState(() {});
      });

      setState(() {});
    }).catchError((e) {
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    setDynamicStatusBarColor();
    tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: tabBarLength,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: appPrimaryColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_outlined, color: textPrimaryWhiteColor),
              onPressed: () {
                finish(context);
              },
            ),
            title: Text(translate('lblEncounterDashboard'), style: boldTextStyle(color: textPrimaryWhiteColor, size: 16)),
            bottom: tabData.isNotEmpty
                ? TabBar(
                    controller: tabController,
                    physics: BouncingScrollPhysics(),
                    labelColor: appPrimaryColor,
                    unselectedLabelColor: Colors.white,
                    automaticIndicatorColorAdjustment: true,
                    onTap: (i) {
                      currentIndex = i;
                      setState(() {});
                    },
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                      color: Colors.white,
                    ),
                    tabs: tabData,
                  )
                : null,
          ),
          body: tabWidgets.isNotEmpty
              ? TabBarView(
                  controller: tabController,
                  children: tabWidgets,
                )
              : setLoader(),
          floatingActionButton: !isPatient() && paymentStatus.validate()!='paid'
              ? FloatingActionButton(
                  backgroundColor: primaryColor,
                  onPressed: () async {
                    bool? res = await AddPrescriptionScreen(id: widget.id.toInt().validate()).launch(context);
                    if (res ?? false) {
                      setState(() {});
                    }
                  },
                  child: Icon(Icons.add, color: Colors.white),
                ).visible(currentIndex == 4)
              : 0.height,
        ),
      ),
    );
  }
}
