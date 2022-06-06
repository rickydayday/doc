import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/AppointmentListWidget.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/model/PatientEncounterModel.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientAppointment extends StatefulWidget {
  @override
  _PatientAppointmentState createState() => _PatientAppointmentState();
}

class _PatientAppointmentState extends State<PatientAppointment> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    LiveStream().on(DELETE, (value) {
      if (value == true) {
        setState(() {});
      }
    });
    LiveStream().on(UPDATE, (isUpdate) {
      if (isUpdate as bool) {
        setState(() {});
      }
    });
    LiveStream().on(APP_UPDATE, (isUpdate) {
      if (isUpdate as bool) {
        setState(() {});
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(DELETE);
    LiveStream().dispose(UPDATE);
    LiveStream().dispose(APP_UPDATE);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => FutureBuilder<PatientEncounterModel>(
        future: getPatientAppointmentList(patientId: getIntAsync(USER_ID), status: appStore.mStatus),
        builder: (_, snap) {
          if (snap.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translate('lblTodaySAppointments') + ' (${snap.data!.upcomingAppointmentData!.length})', style: boldTextStyle(size: 16)),
                8.height,
                AppointmentListWidget(upcomingAppointment: snap.data!.upcomingAppointmentData).visible(snap.data!.upcomingAppointmentData != null, defaultWidget: noDataWidget()),
              ],
            ).visible(snap.connectionState != ConnectionState.waiting, defaultWidget: setLoader().center());
          }
          return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
        },
      ),
    );
  }
}
