import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/screens/AddAppointmentScreenStep1.dart';
import 'package:kivicare_flutter/patient/screens/AddAppointmentScreenStep3.dart';
import 'package:kivicare_flutter/patient/screens/PatientAppointment.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientAppointmentFragment extends StatefulWidget {
  @override
  _PatientAppointmentFragmentState createState() => _PatientAppointmentFragmentState();
}

class _PatientAppointmentFragmentState extends State<PatientAppointmentFragment> {
  List<String> pStatus = [];
  int selectIndex = -1;

  DateTime current = DateTime.now();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
    pStatus.add(translate("lblAll"));
    pStatus.add(translate("lblLatest"));
    pStatus.add(translate('lblCompleted'));
    pStatus.add(translate('lblCancelled'));
    pStatus.add(translate('lblPast'));
    selectIndex = 0;
    await getConfiguration().catchError(log);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didUpdateWidget(covariant PatientAppointmentFragment oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget body() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HorizontalList(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: pStatus.length,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
                margin: EdgeInsets.only(left: 0, right: 8, top: 4, bottom: 4),
                decoration: BoxDecoration(
                  gradient: selectIndex == index
                      ? LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.5)],
                    tileMode: TileMode.mirror,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomLeft,
                  )
                      : LinearGradient(colors: [Theme.of(context).cardColor, Theme.of(context).cardColor]),
                  borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),
                  border: Border.all(color: appPrimaryColor, width: 0.5),
                ),
                child: FittedBox(
                  child: Text(
                    pStatus[index],
                    style: primaryTextStyle(size: 14, color: selectIndex == index ? white : Theme.of(context).iconTheme.color),
                    textAlign: TextAlign.center,
                  ),
                ),
              ).onTap(
                    () {
                  selectIndex = index;
                  if (index == 0) {
                    appStore.setStatus('all');
                  } else if (index == 1) {
                    appStore.setStatus('-1');
                  } else if (index == 2) {
                    appStore.setStatus('3');
                  } else if (index == 3) {
                    appStore.setStatus('0');
                  } else if (index == 4) {
                    appStore.setStatus('past');
                  }
                  setState(() {});
                },
              );
            },
          ),
          PatientAppointment().paddingAll(16),
          70.height
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: AddFloatingButton(
          onTap: () {
            appStore.setBookedFromDashboard(false);
            isProEnabled() ? AddAppointmentScreenStep3().launch(context, pageRouteAnimation: PageRouteAnimation.Scale) : AddAppointmentScreenStep1().launch(context, pageRouteAnimation: PageRouteAnimation.Scale);
          },
        ),
        body: body(),
      ),
    );
  }
}
