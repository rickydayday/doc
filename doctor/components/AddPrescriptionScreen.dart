import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/components/SelectionWithSearchWidget.dart';
import 'package:kivicare_flutter/main/model/PrescriptionModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class AddPrescriptionScreen extends StatefulWidget {
  final String? text;
  final String? name;
  final int? id;
  final int? pID;
  PrescriptionData? prescriptionData;

  AddPrescriptionScreen({this.text, this.name, this.id, this.pID, this.prescriptionData});

  @override
  _AddPrescriptionScreenState createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  AsyncMemoizer<PrescriptionModel> _memorizer = AsyncMemoizer();
  var formKey = GlobalKey<FormState>();

  TextEditingController prescriptionNameCont = TextEditingController();
  TextEditingController prescriptionFrequencyCont = TextEditingController();
  TextEditingController prescriptionDurationCont = TextEditingController();
  TextEditingController prescriptionInstructionCont = TextEditingController();

  FocusNode prescriptionNameFocus = FocusNode();
  FocusNode prescriptionFrequencyFocus = FocusNode();
  FocusNode prescriptionDurationFocus = FocusNode();
  FocusNode prescriptionInstructionFocus = FocusNode();

  List<String> pName = [];
  List<String> pFrequency = [];

  bool isLoading = false;
  bool isUpdate = false;

  PrescriptionData? prescriptionData;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    isUpdate = widget.prescriptionData != null;
    if (isUpdate) {
      prescriptionData = widget.prescriptionData;
      prescriptionNameCont.text = prescriptionData!.name!;
      prescriptionFrequencyCont.text = prescriptionData!.frequency!;
      prescriptionDurationCont.text = prescriptionData!.duration!;
      prescriptionInstructionCont.text = prescriptionData!.instruction!;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  savePrescriptionDetails() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading = true;
      setState(() {});
      Map request = {
        "encounter_id": widget.id,
        "name": prescriptionNameCont.text.validate(),
        "frequency": prescriptionFrequencyCont.text.validate(),
        "duration": prescriptionDurationCont.text.validate(),
        "instruction": prescriptionInstructionCont.text.validate(),
      };

      savePrescriptionData(request).then((value) {
        isLoading = false;
        setState(() {});
        successToast(translate('lblPrescriptionAdded'));
        finish(context);
      }).catchError((e) {
        isLoading = false;
        setState(() {});
        errorToast(e.toString());
      });
    }
  }

  updatePrescriptionDetails() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading = true;
      setState(() {});
      Map request = {
        "id": widget.pID.validate(),
        "encounter_id": widget.id.validate(),
        "name": prescriptionNameCont.text.validate(),
        "frequency": prescriptionFrequencyCont.text.validate(),
        "duration": prescriptionDurationCont.text.validate(),
        "instruction": prescriptionInstructionCont.text.validate(),
      };
      savePrescriptionData(request).then((value) {
        isLoading = false;
        setState(() {});
        successToast(translate('lblUpdatedSuccessfully'));
        finish(context);
      }).catchError((e) {
        isLoading = false;
        setState(() {});
        errorToast(e.toString());
        //
      });
    }
  }

  deletePrescriptionDetails() {
    Map request = {
      "id": prescriptionData!.id,
    };
    deletePrescriptionData(request).then((value) {
      isLoading = false;
      setState(() {});
      successToast(translate('lblPrescriptionDeleted'));
      finish(context);
    }).catchError((e) {
      isLoading = false;
      setState(() {});
      errorToast(e.toString());
    });
  }

  @override
  void dispose() {
    prescriptionNameCont.dispose();
    prescriptionFrequencyCont.dispose();
    prescriptionDurationCont.dispose();
    prescriptionInstructionCont.dispose();
    prescriptionNameFocus.dispose();
    prescriptionFrequencyFocus.dispose();
    prescriptionDurationFocus.dispose();
    prescriptionInstructionFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return FutureBuilder<PrescriptionModel>(
        future: _memorizer.runOnce(() => getPrescriptionResponse("")),
        builder: (context, snap) {
          if (snap.hasData) {
            if (pName.isEmpty) {
              snap.data!.prescriptionData!.forEach((element) {
                pName.add(element.name.capitalizeFirstLetter());
              });
            }

            if (pFrequency.isEmpty) {
              snap.data!.prescriptionData!.forEach((element) {
                pFrequency.add(element.frequency.capitalizeFirstLetter());
              });
            }
            return Form(
              key: formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                shrinkWrap: true,
                children: [
                  Text(translate('lblAddPrescription'), style: boldTextStyle(size: 16)),
                  16.height,
                  Column(
                    children: [
                      AppTextField(
                        controller: prescriptionNameCont,
                        focus: this.prescriptionNameFocus,
                        nextFocus: prescriptionFrequencyFocus,
                        textFieldType: TextFieldType.OTHER,
                        validator: (s) {
                          if (s!.trim().isEmpty) return translate("lblPrescriptionRequired");
                          return null;
                        },
                        decoration: textInputStyle(context: context, label: 'lblName'),
                        readOnly: true,
                        onTap: () async {
                          String? name = await showModalBottomSheet(
                            context: context,
                            isDismissible: true,
                            enableDrag: true,
                            isScrollControlled: true,
                            builder: (context) {
                              return SelectionWithSearchWidget(searchList: pName, name: translate('lblPrescription'));
                            },
                          );
                          if (name == null) {
                            prescriptionNameCont.clear();
                          } else {
                            prescriptionNameCont.text = name;
                          }
                        },
                      ),
                      16.height,
                      AppTextField(
                        controller: prescriptionFrequencyCont,
                        focus: prescriptionFrequencyFocus,
                        nextFocus: prescriptionDurationFocus,
                        textFieldType: TextFieldType.OTHER,
                        decoration: textInputStyle(context: context, label: 'lblFrequency'),
                        readOnly: true,
                        validator: (s) {
                          if (s!.trim().isEmpty) return translate('lblPrescriptionFrequencyIsRequired');
                          return null;
                        },
                        onTap: () async {
                          String? name = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            enableDrag: true,
                            isDismissible: true,
                            builder: (context) {
                              return SelectionWithSearchWidget(searchList: pFrequency, name: translate('lblFrequency'));
                            },
                          );
                          if (name == null) {
                            prescriptionFrequencyCont.clear();
                          } else {
                            prescriptionFrequencyCont.text = name;
                          }
                        },
                      ),
                    ],
                  ),
                  16.height,
                  AppTextField(
                    controller: prescriptionDurationCont,
                    focus: prescriptionDurationFocus,
                    nextFocus: prescriptionInstructionFocus,
                    textFieldType: TextFieldType.OTHER,
                    keyboardType: TextInputType.number,
                    validator: (s) {
                      if (s!.trim().isEmpty) return translate('lblPrescriptionDurationIsRequired');
                      return null;
                    },
                    suffix: Text(translate('lblDays'), style: primaryTextStyle()),
                    decoration: textInputStyle(context: context, label: 'lblDurationInDays'),
                  ),
                  16.height,
                  AppTextField(
                    controller: prescriptionInstructionCont,
                    focus: prescriptionInstructionFocus,
                    minLines: 5,
                    maxLines: 10,
                    textInputAction: TextInputAction.done,
                    textFieldType: TextFieldType.OTHER,
                    decoration: textInputStyle(context: context, label: 'lblInstruction'),
                  ),
                ],
              ),
            );
          }
          return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(
          context,
          name: !isUpdate ? translate('lblAddNewPrescription') : translate('lblEditPrescriptionDetail'),
          actions: !isUpdate
              ? []
              : [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      bool? res = await showConfirmDialog(context, translate('lblAreYouSure'), buttonColor: primaryColor);
                      if (res ?? false) {
                        deletePrescriptionDetails();
                      }
                    },
                  ),
                ],
        ),
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            isUpdate ? updatePrescriptionDetails() : savePrescriptionDetails();
          },
          child: Icon(Icons.done, color: Colors.white),
        ),
      ),
    );
  }
}
