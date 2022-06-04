import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GenderModel.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/model/StaticDataModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/receiptionist/components/MultiSelectSpecialization.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class ProfileBasicInformation extends StatefulWidget {
  final GetDoctorDetailModel? getDoctorDetail;
  void Function(bool isChanged)? onSave;

  ProfileBasicInformation({this.getDoctorDetail, this.onSave});

  @override
  _ProfileBasicInformationState createState() => _ProfileBasicInformationState();
}

class _ProfileBasicInformationState extends State<ProfileBasicInformation> {
  var formKey = GlobalKey<FormState>();

  GetDoctorDetailModel? getDoctorDetail;
  StaticData? staticData;
  GetDoctorDetailModel? data;

  List<GenderModel> genderList = [];
  List<int> selectedItems = [];
  final List<DropdownMenuItem> items = [];
  List<Specialty> temp = [];

  bool isSelected = false;
  bool isLoading = false;

  var picked = DateTime.now();

  int selectedGender = -1;

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController dOBCont = TextEditingController();
  String? genderValue;
  TextEditingController addressCont = TextEditingController();
  TextEditingController cityCont = TextEditingController();
  TextEditingController stateCont = TextEditingController();
  TextEditingController countryCont = TextEditingController();
  TextEditingController postalCodeCont = TextEditingController();
  TextEditingController experienceCont = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode dOBFocus = FocusNode();
  FocusNode genderFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode stateFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode postalCodeFocus = FocusNode();
  FocusNode experienceCodeFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
    data = widget.getDoctorDetail;
  }

  init() async {
    multiSelectStore.clearStaticList();
    genderList.add(GenderModel(name: translate('lblMale'), icon: FontAwesomeIcons.male, value: "male"));
    genderList.add(GenderModel(name: translate('lblFemale'), icon: FontAwesomeIcons.female, value: "female"));
    genderList.add(GenderModel(name: translate('lblOther'), icon: FontAwesomeIcons.female, value: "other"));
    getDoctorDetail = widget.getDoctorDetail;
    getDoctorDetails();
  }

  void getDoctorDetails() {
    firstNameCont.text = getDoctorDetail!.first_name.validate();
    lastNameCont.text = getDoctorDetail!.last_name.validate();
    emailCont.text = getDoctorDetail!.user_email.validate();
    contactNumberCont.text = getDoctorDetail!.mobile_number.validate();
    dOBCont.text = getDoctorDetail!.dob.validate().getFormattedDate(BIRTH_DATE_FORMAT);
    picked = DateTime.parse(getDoctorDetail!.dob!);
    selectedGender = getDoctorDetail!.gender == 'male' ? 0 : 1;
    genderValue = getDoctorDetail!.gender;
    addressCont.text = getDoctorDetail!.address.validate();
    cityCont.text = getDoctorDetail!.city.validate();
    stateCont.text = getDoctorDetail!.state.validate();
    countryCont.text = getDoctorDetail!.country.validate();
    postalCodeCont.text = getDoctorDetail!.postal_code.validate();
    experienceCont.text = getDoctorDetail!.no_of_experience.validate();
    getDoctorDetail!.specialties!.forEach((element) {
      multiSelectStore.selectedStaticData.add(StaticData(id: element.id, label: element.label));
      temp.add(Specialty(id: element.id, label: element.label));
    });
  }

  saveDetails() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      saveBasicInformationData();
    }
  }

  saveBasicInformationData() async {
    hideKeyboard(context);
    Map<String, dynamic> request = {
      "ID": "${getIntAsync(USER_ID)}",
      "user_email": "${emailCont.text}",
      "user_login": "${data!.user_login}",
      "first_name": "${firstNameCont.text}",
      "last_name": "${lastNameCont.text}",
      "gender": "$genderValue",
      "dob": "${picked.toString().getFormattedDate(CONVERT_DATE)}",
      "address": "${addressCont.text}",
      "city": "${cityCont.text}",
      "country": "${countryCont.text}",
      "postal_code": "${postalCodeCont.text}",
      "mobile_number": "${contactNumberCont.text}",
      "state": "${stateCont.text}",
      "no_of_experience": "${experienceCont.text}",
      "profile_image": image != null ? File(image!.path) : null,
      "specialties": jsonEncode(getDoctorDetail!.specialties),
    };
    editProfileAppStore.addData(request);
    toast(translate('lblInformationSaved'));
    widget.onSave!.call(true);
  }

  Future<void> dateBottomSheet(context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext e) {
        return Container(
          height: 245,
          color: appStore.isDarkModeOn ? Colors.black : Colors.white,
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(translate('lblCancel'), style: boldTextStyle()).onTap(() {
                      finish(context);
                      setState(() {});
                    }),
                    Text(translate('lblDone'), style: boldTextStyle()).onTap(() {
                      if (DateTime.now().year - picked.year < 18) {
                        toast(
                          translate('lblMinimumAgeRequired') + translate('lblCurrentAgeIs') + ' ${DateTime.now().year - picked.year}',
                          bgColor: errorBackGroundColor,
                          textColor: errorTextColor,
                        );
                      } else {
                        finish(context);
                        dOBCont.text = picked.getFormattedDate(BIRTH_DATE_FORMAT).toString();
                      }
                    })
                  ],
                ).paddingOnly(top: 8, left: 8, right: 8, bottom: 8),
              ),
              Container(
                height: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: primaryTextStyle(size: 20),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    minimumDate: DateTime(1900, 1, 1),
                    minuteInterval: 1,
                    initialDateTime: picked,
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (DateTime dateTime) {
                      picked = dateTime;
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage() async {
    image = (await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100)) as PickedFile?;
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    emailCont.dispose();
    passwordCont.dispose();
    firstNameCont.dispose();
    lastNameCont.dispose();
    contactNumberCont.dispose();
    dOBCont.dispose();
    addressCont.dispose();
    cityCont.dispose();
    stateCont.dispose();
    countryCont.dispose();
    postalCodeCont.dispose();
    experienceCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 90),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    height: 100,
                    width: 100,
                    margin: EdgeInsets.all(12),
                    decoration: boxDecorationWithShadow(backgroundColor: context.cardColor,borderRadius: radius(defaultRadius), boxShape: BoxShape.rectangle),
                    child: image != null
                        ? Image.file(File(image!.path), height: 90, width: 90, fit: BoxFit.cover, alignment: Alignment.center)
                        : appStore.profileImage.validate().isNotEmpty
                            ? cachedImage(appStore.profileImage, height: 90, width: 90, fit: BoxFit.cover, alignment: Alignment.center)
                            : Icon(Icons.person_outline_rounded).paddingAll(16),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 0,
                    child: Container(padding: EdgeInsets.all(4), decoration: boxDecorationWithShadow(boxShape: BoxShape.circle,backgroundColor: context.cardColor,blurRadius: 0),
                        child: Icon(Icons.edit_outlined, size: 16, color: context.iconColor),),
                  ),
                ],
              ),
              16.height,
              Row(
                children: [
                  AppTextField(
                    controller: firstNameCont,
                    focus: firstNameFocus,
                    nextFocus: lastNameFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: textInputStyle(context: context, label: 'lblFirstName'),
                    scrollPadding: EdgeInsets.all(0),
                  ).expand(),
                  10.width,
                  AppTextField(
                    controller: lastNameCont,
                    focus: lastNameFocus,
                    nextFocus: emailFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: textInputStyle(context: context, label: 'lblLastName'),
                  ).expand(),
                ],
              ),
              16.height,
              (getStringAsync(USER_EMAIL) == receptionistEmail || getStringAsync(USER_EMAIL) == doctorEmail || getStringAsync(USER_EMAIL) == patientEmail)
                  ? AppTextField(
                      controller: emailCont,
                      focus: emailFocus,
                      nextFocus: contactNumberFocus,
                      textFieldType: TextFieldType.EMAIL,
                      readOnly: true,
                      onTap: () {
                        errorToast(translate('lblDemoEmailCannotBeChanged'));
                      },
                      decoration: textInputStyle(context: context, label: 'lblEmail'),
                    )
                  : AppTextField(
                      controller: emailCont,
                      focus: emailFocus,
                      nextFocus: contactNumberFocus,
                      textFieldType: TextFieldType.EMAIL,
                      decoration: textInputStyle(context: context, label: 'lblEmail'),
                    ),
              16.height,
              AppTextField(
                controller: contactNumberCont,
                focus: contactNumberFocus,
                nextFocus: dOBFocus,
                textFieldType: TextFieldType.PHONE,
                decoration: textInputStyle(context: context, label: 'lblContactNumber'),
              ),
              16.height,
              AppTextField(
                controller: dOBCont,
                focus: dOBFocus,
                nextFocus: addressFocus,
                readOnly: true,
                validator: (s) {
                  if (s!.trim().isEmpty) return translate('lblContactNumberIsRequired');
                  return null;
                },
                decoration: textInputStyle(context: context, label: 'lblDOB', isMandatory: true),
                onTap: () {
                  dateBottomSheet(context);
                  if (dOBCont.text.isNotEmpty) {
                    FocusScope.of(context).requestFocus(addressFocus);
                  }
                },
                textFieldType: TextFieldType.OTHER,
              ),
              16.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate('lblGender1'), style: primaryTextStyle(size: 12)).paddingLeft(8),
                  6.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      genderList.length,
                      (index) {
                        return Container(
                          width: 90,
                          padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                          decoration: boxDecorationWithRoundedCorners(
                           borderRadius: radius(defaultRadius),
                            backgroundColor: selectedGender == index
                                ? appStore.isDarkModeOn
                                    ? cardSelectedColor
                                    : selectedColor
                                : Theme.of(context).cardColor,
                          ),
                          child: Column(
                            children: [
                              FaIcon(
                                genderList[index].icon,
                                color: selectedGender == index ? Colors.white : Colors.grey,
                              ),
                              2.height,
                              FittedBox(child: Text(genderList[index].name!, style: primaryTextStyle(size: 14, color: primaryColor)))
                            ],
                          ).center(),
                        ).onTap(() {
                          if (selectedGender == index) {
                            selectedGender = -1;
                          } else {
                            genderValue = genderList[index].value;
                            selectedGender = index;
                          }
                          setState(() {});
                        }, borderRadius: BorderRadius.circular(defaultRadius)).paddingRight(16);
                      },
                    ),
                  ),
                ],
              ),
              16.height,
              Container(
                padding: EdgeInsets.fromLTRB(8, 8, 16, 8),
                width: context.width(),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: viewLineColor,
                    ),
                    borderRadius: BorderRadius.circular(defaultRadius)),
                child: Observer(
                  builder: (_) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translate('lblSpecialization'), style: primaryTextStyle()),
                        16.height,
                        Wrap(
                          spacing: 8,
                          children: List.generate(
                            multiSelectStore.selectedStaticData.length,
                            (index) {
                              StaticData data = multiSelectStore.selectedStaticData[index]!;
                              return Chip(
                                label: Text('${data.label}', style: primaryTextStyle()),
                                backgroundColor: Theme.of(context).cardColor,
                                deleteIcon: Icon(Icons.clear),
                                deleteIconColor: Colors.red,
                                onDeleted: () {
                                  multiSelectStore.removeStaticItem(data);
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(defaultRadius),
                                    side: BorderSide(
                                      color: viewLineColor,
                                    )),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ).onTap(
                () async {
                  List<String?> ids = [];
                  if (multiSelectStore.selectedStaticData.validate().isNotEmpty) {
                    multiSelectStore.selectedStaticData.forEach((element) {
                      ids.add(element!.id);
                    });
                  }

                  bool? res = await MultiSelectSpecialization(selectedServicesId: ids).launch(context);
                  if (res ?? false) {
                    multiSelectStore.selectedStaticData.forEach((element) {
                      temp.add(Specialty(id: element!.id, label: element.label));
                    });
                    setState(() {});
                  }
                },
              ),
              16.height,
              AppTextField(
                controller: addressCont,
                focus: addressFocus,
                nextFocus: cityFocus,
                textFieldType: TextFieldType.ADDRESS,
                decoration: textInputStyle(context: context, label: 'lblAddress').copyWith(alignLabelWithHint: true),
                minLines: 4,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
              ),
              16.height,
              AppTextField(
                controller: cityCont,
                focus: cityFocus,
                nextFocus: stateFocus,
                textFieldType: TextFieldType.OTHER,
                decoration: textInputStyle(context: context, label: 'lblCity'),
              ),
              16.height,
              AppTextField(
                controller: stateCont,
                focus: stateFocus,
                nextFocus: countryFocus,
                textFieldType: TextFieldType.OTHER,
                decoration: textInputStyle(context: context, label: 'lblState'),
              ),
              16.height,
              AppTextField(
                controller: countryCont,
                focus: countryFocus,
                nextFocus: postalCodeFocus,
                textFieldType: TextFieldType.OTHER,
                decoration: textInputStyle(context: context, label: 'lblCountry'),
              ),
              16.height,
              AppTextField(
                controller: postalCodeCont,
                focus: postalCodeFocus,
                textFieldType: TextFieldType.OTHER,
                decoration: textInputStyle(context: context, label: 'lblPostalCode'),
              ),
              16.height,
              AppTextField(
                controller: experienceCont,
                focus: experienceCodeFocus,
                textFieldType: TextFieldType.OTHER,
                keyboardType: TextInputType.number,
                decoration: textInputStyle(context: context, label: 'lblExperience'),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: primaryColor,
          label: Text(translate('lblSaveAndContinue'), style: primaryTextStyle(color: Colors.white)),
          icon: Icon(Icons.arrow_forward, color: textPrimaryWhiteColor),
          onPressed: () {
            saveDetails();
          },
        ),
        body: body(),
      ),
    );
  }
}
