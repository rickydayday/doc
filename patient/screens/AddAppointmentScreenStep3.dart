import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/ClinicListWidget.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/patient/screens/AddAppointmentScreenStep1.dart';
import 'package:kivicare_flutter/patient/screens/AddAppointmentScreenStep2.dart';
import 'package:nb_utils/nb_utils.dart';

class AddAppointmentScreenStep3 extends StatefulWidget {
  @override
  _AddAppointmentScreenStep3State createState() => _AddAppointmentScreenStep3State();
}

class _AddAppointmentScreenStep3State extends State<AddAppointmentScreenStep3> {
  TextEditingController searchCont = TextEditingController();

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
    searchCont.dispose();
    setDynamicStatusBarColor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return ListView(
        padding: EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          Text(translate("lblStep1Of3"), style: primaryTextStyle(size: 14, color: primaryColor)),
          2.height,
          Text(translate('lblChooseYourClinic').toUpperCase(), style: boldTextStyle(size: 20)),
          16.height,
          ClinicListWidget(),
        ],
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: translate("lblAddNewAppointment")),
        body: body(),
        floatingActionButton: AddFloatingButton(
          icon: Icons.arrow_forward_outlined,
          onTap: () {
            if (appointmentAppStore.mClinicSelected == null)
              errorToast(translate("lblSelectOneClinic"));
            else {
              if (appStore.isBookedFromDashboard) {
                AddAppointmentScreenStep2().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
              } else {
                AddAppointmentScreenStep1().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
              }
            }
          },
        ),
      ),
    );
  }
}
