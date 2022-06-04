import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/components/DConfirmAppointmentScreen.dart';
import 'package:kivicare_flutter/doctor/components/SelectionWithSearchWidget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/model/PatientListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorAddAppointmentStep2Screen extends StatefulWidget {
  final UpcomingAppointment? updatedData;

  DoctorAddAppointmentStep2Screen({this.updatedData});

  @override
  _DoctorAddAppointmentStep2ScreenState createState() => _DoctorAddAppointmentStep2ScreenState();
}

class _DoctorAddAppointmentStep2ScreenState extends State<DoctorAddAppointmentStep2Screen> {
  var formKey = GlobalKey<FormState>();
  AsyncMemoizer<PatientListModel> _memorizer = AsyncMemoizer();

  List<String> statusList = ['${translate("lblBooked")}', '${translate("lblCheckOut")}', '${translate("lblCheckIn")}', '${translate("lblCancelled")}'];
  List<String?> pName = [];
  List<PatientData> list = [];

  bool isLoading = false;
  bool isUpdate = false;

  String? statusCont = translate("lblBooked");

  TextEditingController descriptionCont = TextEditingController();
  TextEditingController patientNameCont = TextEditingController();
  TextEditingController patientIdCont = TextEditingController();

  Map<String, dynamic> request = {};

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
    int? id = statusCont!.getStatus();
    appointmentAppStore.setStatusSelected(id);
    isUpdate = widget.updatedData != null;
    if (isUpdate) {
      appointmentAppStore.setSelectedDoctor(listAppStore.doctorList.firstWhereOrNull((element) => element!.iD == widget.updatedData!.doctor_id.toInt()));
      appointmentAppStore.setSelectedPatient(widget.updatedData!.patient_name);
      appointmentAppStore.setSelectedPatientId(widget.updatedData!.patient_id.toInt());
      patientNameCont.text = widget.updatedData!.patient_name!;
      patientIdCont.text = widget.updatedData!.patient_id!;
      descriptionCont.text = widget.updatedData!.description.validate();
    }
  }

  @override
  void dispose() {
    descriptionCont.dispose();
    patientNameCont.dispose();
    patientIdCont.dispose();
    super.dispose();
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: Column(
          children: [
            AbsorbPointer(
              absorbing: isUpdate,
              child: Column(
                children: [
                  FutureBuilder<PatientListModel>(
                    future: _memorizer.runOnce(() => getPatientList()),
                    builder: (_, snap) {
                      if (snap.hasData) {
                        pName.clear();

                        snap.data!.patientData!.forEach((element) {
                          pName.add(element.display_name);
                        });
                        return AppTextField(
                          controller: patientNameCont,
                          textFieldType: TextFieldType.OTHER,
                          validator: (s) {
                            if (s!.trim().isEmpty) return translate('lblPatientNameIsRequired');
                            return null;
                          },
                          decoration: textInputStyle(context: context, label: 'lblPatientName', isMandatory: true),
                          readOnly: true,
                          onTap: () async {
                            String? name = await showModalBottomSheet(
                              context: context,
                              isDismissible: true,
                              enableDrag: true,
                              isScrollControlled: true,
                              builder: (context) {
                                return SelectionWithSearchWidget(searchList: pName, name: translate('lblPatientName'));
                              },
                            );
                            if (name == null) {
                              patientNameCont.clear();
                            } else {
                              list = snap.data!.patientData!.where((element) {
                                return element.display_name == name;
                              }).toList();
                              appointmentAppStore.setSelectedPatient(name);
                              patientNameCont.text = name;
                              patientIdCont.text = list[0].iD.toString();

                              appointmentAppStore.setSelectedPatientId(patientIdCont.text.toInt());
                            }
                          },
                        );
                      }

                      return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
                    },
                  ),
                  16.height,
                  DropdownButtonFormField(
                    decoration: textInputStyle(context: context, label: 'lblStatus', isMandatory: true),
                    isExpanded: true,
                    dropdownColor: Theme.of(context).cardColor,
                    value: statusCont,
                    onChanged: (dynamic value) {
                      statusCont = value;
                      int? id = statusCont!.getStatus();
                      appointmentAppStore.setStatusSelected(id);
                      setState(() {});
                    },
                    items: statusList
                        .map(
                          (data) => DropdownMenuItem(
                            value: data,
                            child: Text("$data", style: primaryTextStyle()),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            16.height,
            AppTextField(
              maxLines: 10,
              minLines: 5,
              controller: descriptionCont,
              textAlign: TextAlign.start,
              textFieldType: TextFieldType.ADDRESS,
              decoration: textInputStyle(context: context, label: 'lblDescription'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: translate('lblStep2')),
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.done, color: textPrimaryWhiteColor),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              appointmentAppStore.setDescription(descriptionCont.text.trim());
              hideKeyboard(context);
              await showInDialog(
                context,
                barrierDismissible: false,
                backgroundColor: Theme.of(context).cardColor,
                // ignore: deprecated_member_use
                child: isUpdate ? DConfirmAppointmentScreen(appointmentId: widget.updatedData?.id.toInt()) : DConfirmAppointmentScreen(),
              );
            }
          },
        ),
      ),
    );
  }
}
