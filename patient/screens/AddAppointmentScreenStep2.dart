import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/AppoitmentSlots.dart';
import 'package:kivicare_flutter/main/components/AppoitnmentDateSelection.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/model/ServiceModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/patient/components/ConfirmAppointmentScreen.dart';
import 'package:kivicare_flutter/patient/components/SelectedClinicWidget.dart';
import 'package:kivicare_flutter/patient/components/SelectedDoctorWidget.dart';
import 'package:kivicare_flutter/patient/screens/MultiSelect.dart';
import 'package:nb_utils/nb_utils.dart';

class AddAppointmentScreenStep2 extends StatefulWidget {
  final int? id;
  final UpcomingAppointment? data;

  AddAppointmentScreenStep2({this.id, this.data});

  @override
  _AddAppointmentScreenStep2State createState() => _AddAppointmentScreenStep2State();
}

class _AddAppointmentScreenStep2State extends State<AddAppointmentScreenStep2> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController descriptionCont = TextEditingController();
  TextEditingController servicesCont = TextEditingController();

  Map<String, dynamic> request = {};

  List<ServiceData> selectedServicesList = [];

  UpcomingAppointment? upcomingAppointment;

  bool isLoading = false;
  bool isUpdate = false;

  List<String?> ids = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
    multiSelectStore.clearList();
    isUpdate = widget.data != null;
    upcomingAppointment = widget.data;
    if (isUpdate) {
      if (widget.data != null) {
        getDoctor();
        getClinc();
        appointmentAppStore.setSelectedDoctor(listAppStore.doctorList.firstWhereOrNull(
          (element) => element!.iD == upcomingAppointment!.doctor_id.toInt(),
        ));

        appointmentAppStore.setSelectedClinic(listAppStore.clinicItemList.firstWhereOrNull(
          (element) => element!.clinic_id == upcomingAppointment!.clinic_id,
        ));

        if (upcomingAppointment!.visit_type!.isNotEmpty) {
          upcomingAppointment!.visit_type!.forEach((element) {
            multiSelectStore.selectedService.add(ServiceData(id: element.id, name: element.service_name, service_id: element.service_id));
          });

          servicesCont.text = "${multiSelectStore.selectedService.length} " + translate('lblServicesSelected');
        }
      }
      descriptionCont.text=upcomingAppointment!.description.validate();
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setDynamicStatusBarColor();
    if (!appStore.isBookedFromDashboard) {
      appointmentAppStore.setSelectedDoctor(null);
    }
    appointmentAppStore.setDescription(null);
    appointmentAppStore.setSelectedPatient(null);
    appointmentAppStore.setSelectedTime(null);
    appointmentAppStore.setSelectedPatientId(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: translate('lblConfirmAppointment')),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AbsorbPointer(
                  absorbing: isUpdate,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isProEnabled()
                          ? Text(translate('lblStep3Of3'), style: primaryTextStyle(size: 14, color: primaryColor))
                          : Text(
                              translate('lblStep2Of2'),
                              style: primaryTextStyle(size: 14, color: primaryColor),
                            ),
                      4.height,
                      Text(translate('lblSelectDateTime').toUpperCase(), style: boldTextStyle(size: 20)),
                      isProEnabled() ? SelectedClinicWidget() : Offstage(),
                      SelectedDoctorWidget(),
                      16.height,
                      AppTextField(
                        controller: servicesCont,
                        textFieldType: TextFieldType.MULTILINE,
                        decoration: textInputStyle(context: context, label: 'lblSelectServices', isMandatory: true),
                        validator: (v) {
                          if (v!.trim().isEmpty) return translate('lblServicesIsRequired');
                          return null;
                        },
                        readOnly: true,
                        onTap: () async {
                          if (!isUpdate) {
                            if (multiSelectStore.selectedService.validate().isNotEmpty) {
                              multiSelectStore.selectedService.forEach((element) {
                                ids.add(element.id);
                              });
                            }
                          } else {
                            ids.clear();
                            if (multiSelectStore.selectedService.validate().isNotEmpty) {
                              multiSelectStore.selectedService.forEach((element) {
                                ids.add(element.service_id);
                              });
                            }
                          }

                          bool? res = await MultiSelectWidget(selectedServicesId: ids).launch(context);
                          if (res ?? false) {
                            List<int> temp = [];

                            multiSelectStore.selectedService.forEach((element) {
                              temp.add(element.id.toInt());
                            });

                            appointmentAppStore.addSelectedService(temp);
                            if (multiSelectStore.selectedService.length > 0) {
                              servicesCont.text = "${multiSelectStore.selectedService.length} " + translate('lblServicesSelected');
                            }
                            setState(() {});
                          }
                        },
                      ),
                      Observer(
                        builder: (_) {
                          return Wrap(
                            spacing: 8,
                            children: List.generate(
                              multiSelectStore.selectedService.length,
                              (index) {
                                ServiceData data = multiSelectStore.selectedService[index];
                                return Chip(
                                  label: Text('${data.name}', style: primaryTextStyle()),
                                  backgroundColor: Theme.of(context).cardColor,
                                  deleteIcon: Icon(Icons.clear),
                                  deleteIconColor: Colors.red,
                                  onDeleted: () {
                                    multiSelectStore.removeItem(data);
                                    if (multiSelectStore.selectedService.length > 0) {
                                      servicesCont.text = "${multiSelectStore.selectedService.length} " + translate('lblServicesSelected');
                                    } else {
                                      servicesCont.clear();
                                    }
                                    setState(() {});
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(defaultRadius),
                                      side: BorderSide(
                                        color: viewLineColor,
                                      )),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ).paddingAll(16),
                ),
                isUpdate
                    ? AppointmentDateSelection(
                        appointmentDate: upcomingAppointment!.appointment_start_date!.getFormattedDate(CONVERT_DATE),
                      )
                    : AppointmentDateSelection(),
                16.height,
                isUpdate
                    ? AppointmentSlots(
                        doctorId: upcomingAppointment!.doctor_id.toInt(),
                        appointmentTime: DateFormat(DATE_FORMAT).parse(upcomingAppointment!.appointment_start_time!).getFormattedDate(FORMAT_12_HOUR),
                      ).paddingSymmetric(horizontal: 16)
                    : AppointmentSlots().paddingSymmetric(horizontal: 16),
                AbsorbPointer(
                  absorbing: isUpdate,
                  child: AppTextField(
                    maxLines: 15,
                    minLines: 5,
                    controller: descriptionCont,
                    textFieldType: TextFieldType.MULTILINE,
                    decoration: textInputStyle(context: context, label: 'lblDescription').copyWith(
                      alignLabelWithHint: true,
                    ),
                  ).paddingSymmetric(horizontal: 16),
                ),
                70.height,
              ],
            ),
          ).visible(!isLoading, defaultWidget: setLoader()),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: primaryColor,
          label: Text(translate('lblBook'), style: primaryTextStyle(color: textPrimaryWhiteColor)),
          icon: Icon(Icons.save_outlined, color: textPrimaryWhiteColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
          onPressed: () async {
            // saveData();
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              hideKeyboard(context);
              appointmentAppStore.setDescription(descriptionCont.text);
              bool? res = await showInDialog(
                context,
                barrierDismissible: false,
                backgroundColor: Theme.of(context).cardColor,
                builder: (context){
                  return ConfirmAppointmentScreen(request: request);
                },
              );
              if (res ?? false) {}
              isLoading = false;
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
