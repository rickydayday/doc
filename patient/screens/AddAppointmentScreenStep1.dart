import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/patient/components/DoctorListWidget.dart';
import 'package:kivicare_flutter/patient/screens/AddAppointmentScreenStep2.dart';
import 'package:nb_utils/nb_utils.dart';

class AddAppointmentScreenStep1 extends StatefulWidget {
  @override
  _AddAppointmentScreenStep1State createState() => _AddAppointmentScreenStep1State();
}

class _AddAppointmentScreenStep1State extends State<AddAppointmentScreenStep1> {
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
    return ListView(
      padding: EdgeInsets.all(16),
      shrinkWrap: true,
      children: [
        isProEnabled()
            ? Text(
          translate('lblStep2Of3'),
          style: primaryTextStyle(size: 14, color: primaryColor),
        )
            : Text(
          translate('lblStep1Of2'),
          style: primaryTextStyle(size: 14, color: primaryColor),
        ),
        2.height,
        Text(translate('lblChooseYourDoctor').toUpperCase(), style: boldTextStyle(size: 20)),
        16.height,
        DoctorListWidget(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
     return SafeArea(
      child: Scaffold(
          appBar: appAppBar(context, name: translate('lblAddNewAppointment')),
          body: body(),
          floatingActionButton: AddFloatingButton(
            icon: Icons.arrow_forward_outlined,
            onTap: () {
              if (appointmentAppStore.mDoctorSelected == null)
                errorToast(translate('lblSelectOneDoctor'));
              else {
                AddAppointmentScreenStep2().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
              }
            },
          )),
    );
  }
}
