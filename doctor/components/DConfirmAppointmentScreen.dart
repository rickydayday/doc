import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';

class DConfirmAppointmentScreen extends StatefulWidget {
  final int? appointmentId;

  DConfirmAppointmentScreen({this.appointmentId});

  @override
  _DConfirmAppointmentScreenState createState() => _DConfirmAppointmentScreenState();
}

class _DConfirmAppointmentScreenState extends State<DConfirmAppointmentScreen> {
  bool isLoading = false;
  bool mIsConfirmed = false;
  DateTime? date;
  Map<String, dynamic> request = {};

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await getDate().then((value) {
      date = value;
    }).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
    setState(() {});
    await getConfiguration().catchError(log);
    getDoctor();
  }

  Future<DateTime> getDate() async {
    return DateTime.parse(appointmentAppStore.selectedAppointmentDate.getFormattedDate(CONVERT_DATE));
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
      "appointment_start_time": "${appointmentAppStore.mSelectedTime.validate()}",
      "visit_type": appointmentAppStore.selectedService.validate(),
      "doctor_id": "${appointmentAppStore.mDoctorSelected?.iD.validate()}",
      "description": " ${appointmentAppStore.mDescription.validate()}",
      "patient_id": appointmentAppStore.mPatientId.validate(),
      "status": appointmentAppStore.mStatusSelected.validate(),
    };

    if (isProEnabled()) {
      request.putIfAbsent("clinic_id", () => "${appointmentAppStore.mClinicSelected!.clinic_id}");
    } else {
      request.putIfAbsent("clinic_id", () => getIntAsync(USER_CLINIC));
    }

    addAppointmentData(request).then((value) async {
      mIsConfirmed = true;
      setState(() {});
      await 500.milliseconds.delay;

      finish(context);
      finish(context);
      finish(context, true);
      LiveStream().emit(APP_UPDATE, true);
      LiveStream().emit(UPDATE, true);
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
      "patient_id": appointmentAppStore.mPatientId,
      "status": appointmentAppStore.mStatusSelected,
    };

    if (isProEnabled()) {
      request.putIfAbsent("clinic_id", () => "${appointmentAppStore.mClinicSelected!.clinic_id}");
    } else {
      request.putIfAbsent("clinic_id", () => getIntAsync(USER_CLINIC));
    }

    addAppointmentData(request).then((value) async {
      mIsConfirmed = true;
      await 500.milliseconds.delay;

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
            "Dr.${getStringAsync(FIRST_NAME)}, ${translate("lblAppointmentConfirmation")}",
            style: primaryTextStyle(size: 20),
            textAlign: TextAlign.center,
          ),
          16.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.calendarCheck, size: 16),
              6.width,
              Text(
                '${date?.weekday.validate().getFullWeekDay()}, ${date?.month.validate().getMonthName()} ${date?.day.validate()}, ${date?.year.validate().getFullWeekDay()}',
                style: boldTextStyle(size: 16),
              ).expand(),
            ],
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${appointmentAppStore.mSelectedTime}", style: boldTextStyle(size: 20), textAlign: TextAlign.end).expand(flex: 3),
              VerticalDivider(color: viewLineColor, thickness: 1).withHeight(20).expand(),
              Text("${appointmentAppStore.mPatientSelected}", style: boldTextStyle(size: 20)).expand(flex: 3),
            ],
          ),
          16.height,
          Text(
            '${appointmentAppStore.mDescription}',
            style: primaryTextStyle(),
            textAlign: TextAlign.center,
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
          16.height,
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
