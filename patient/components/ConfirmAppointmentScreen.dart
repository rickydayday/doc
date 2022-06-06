import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/screens/WebViewPaymentScreen.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';


// ignore: must_be_immutable
class ConfirmAppointmentScreen extends StatefulWidget {
  Map<String, dynamic>? request;
  final int? appointmentId;

  ConfirmAppointmentScreen({this.request, this.appointmentId});

  @override
  _ConfirmAppointmentScreenState createState() => _ConfirmAppointmentScreenState();
}

class _ConfirmAppointmentScreenState extends State<ConfirmAppointmentScreen> {
  bool isLoading = false;
  bool mIsConfirmed = false;
  bool isUpdate = false;
  late DateTime date = DateTime.now();
  Map<String, dynamic> request = {};

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    date = DateTime.parse(appointmentAppStore.selectedAppointmentDate.getFormattedDate(CONVERT_DATE));
    await getConfiguration().catchError(log);
    getDoctor();
  }

  saveData() async {
    isLoading = true;
    setState(() {});
    if (isDoctor()) {
      appointmentAppStore.setSelectedDoctor(listAppStore.doctorList.firstWhereOrNull((element) => element!.iD == getIntAsync(USER_ID)));
    }

    request = {
      "id": "",
      "appointment_start_date": "${appointmentAppStore.selectedAppointmentDate.getFormattedDate(CONVERT_DATE)}",
      "appointment_start_time": "${appointmentAppStore.mSelectedTime}",
      "visit_type": appointmentAppStore.selectedService,
      "doctor_id": "${appointmentAppStore.mDoctorSelected!.iD}",
      "description": " ${appointmentAppStore.mDescription}",
    };
    request.putIfAbsent("patient_id", () => getIntAsync(USER_ID));
    request.putIfAbsent("status", () => 1);

    if (isProEnabled()) {
      request.putIfAbsent("clinic_id", () => "${appointmentAppStore.mClinicSelected!.clinic_id}");
    } else {
      request.putIfAbsent("clinic_id", () => "${getIntAsync(USER_CLINIC)}");
    }

    addAppointmentData(request).then((value) async {
      if (appStore.isBookedFromDashboard) {
        void test() {
          finish(context, true);
        }

        value.woocommerce_redirect != null ?await WebViewPaymentScreen(checkoutUrl: value.woocommerce_redirect.validate()).launch(context) : test();
      } else {
        void test() {
          finish(context);
          finish(context);
          finish(context);
          if (isProEnabled()) {
            finish(context);
          }
          finish(context, true);
          LiveStream().emit(APP_UPDATE, true);
        }

        if (isUpdate) {
          finish(context);
          finish(context);
          LiveStream().emit(APP_UPDATE, true);
        } else {
          finish(context);
          finish(context);
          if (isProEnabled()) {
            finish(context);
          }
          finish(context);
          LiveStream().emit(APP_UPDATE, true);
        }

        value.woocommerce_redirect != null ? WebViewPaymentScreen(checkoutUrl: value.woocommerce_redirect.validate()).launch(context) : test();
      }
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  updateData() async {
    isLoading = true;
    setState(() {});
    request = {
      "id": widget.appointmentId,
      "appointment_start_date": "${appointmentAppStore.selectedAppointmentDate.getFormattedDate(CONVERT_DATE)}",
      "appointment_start_time": "${appointmentAppStore.mSelectedTime}",
      "visit_type": appointmentAppStore.selectedService,
      "doctor_id": "${appointmentAppStore.mDoctorSelected!.iD}",
      "description": " ${appointmentAppStore.mDescription}",
    };
    request.putIfAbsent("patient_id", () => getIntAsync(USER_ID));
    request.putIfAbsent("status", () => 1);

    if (isProEnabled()) {
      request.putIfAbsent("clinic_id", () => "${appointmentAppStore.mClinicSelected!.clinic_id}");
    } else {
      request.putIfAbsent("clinic_id", () => getIntAsync(USER_CLINIC));
    }

    await Future.delayed(Duration(milliseconds: 500));
    mIsConfirmed = true;
    isLoading = false;
    setState(() {});
    await Future.delayed(Duration(milliseconds: 600));
    addAppointmentData(request).then((value) async {
      finish(context);
      finish(context);
      finish(context, true);
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

  Widget confirmedAppointment() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset('images/appointment_confirmation.json', height: 180, width: 180),
        30.height,
        Text(translate('lblAppointmentIsConfirmed'), style: primaryTextStyle(size: 24), textAlign: TextAlign.center),
        20.height,
        Align(
          alignment: Alignment.bottomCenter,
          child: Text(translate('lblThanksForBooking'), style: secondaryTextStyle()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.clear).onTap(
              () {
                finish(context, false);
              },
            ),
          ),
          8.height,
          Image.asset("images/icons/confirm_appointment.png", height: 50, width: 50),
          32.height,
          Text(
            "${getStringAsync(FIRST_NAME)}, ${translate("lblAppointmentConfirmation")}",
            style: primaryTextStyle(),
            textAlign: TextAlign.center,
          ),
          16.height,
          isProEnabled() ? Text('Clinic: ${appointmentAppStore.mClinicSelected?.clinic_name.validate()} ', style: primaryTextStyle()) : Offstage(),
          16.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.calendarCheck, size: 16),
              6.width,
              Text(
                '${date.weekday.validate().getFullWeekDay()}, ${date.month.validate().getMonthName()} ${date.day.validate()}, ${date.year.validate()}',
                style: boldTextStyle(size: 14),
              ),
            ],
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${appointmentAppStore.mSelectedTime}", style: boldTextStyle(size: 18)).expand(),
              VerticalDivider(color: viewLineColor, thickness: 1).withHeight(20),
              Text('Dr. ${getStringAsync(FIRST_NAME)}', style: boldTextStyle(size: 18)).visible(getStringAsync(USER_ROLE) == UserRoleDoctor),
              Text('Dr. ${appointmentAppStore.mDoctorSelected?.display_name?.validate()}',maxLines: 2, style: boldTextStyle(size: 24)).visible(getStringAsync(USER_ROLE) != UserRoleDoctor).expand(),
            ],
          ),
          16.height,
          Text('${appointmentAppStore.mDescription}', style: primaryTextStyle(), textAlign: TextAlign.center, maxLines: 10, overflow: TextOverflow.ellipsis),
          30.height,
          Align(
            alignment: Alignment.bottomCenter,
            child: AppButton(
              text: translate('lblConfirmAppointment'),
              textStyle: boldTextStyle(color: Colors.white),
              onTap: () {
                widget.appointmentId == null ? saveData() : updateData();
              },
            ).withWidth(context.width()),
          ).visible(!isLoading, defaultWidget: setLoader()),
        ],
      ).visible(!mIsConfirmed, defaultWidget: confirmedAppointment()),
    );
  }
}
