

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GenderModel.dart';
import 'package:kivicare_flutter/main/model/GetUserDetailModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class AddPatientScreen extends StatefulWidget {
  final int? userId;

  AddPatientScreen({this.userId});

  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  GetUserDetailModel? getUserDetail;

  List<GenderModel> genderList = [];
  final List<DropdownMenuItem> items = [];
  List<String> bloodGroupList = ['A+', 'B+', 'AB+', 'O+', 'A-', 'B-', 'AB-', 'O-'];

  bool isLoading = false;
  bool isUpdate = false;

  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController dOBCont = TextEditingController();
  String? genderValue;
  String? bloodGroup;
  TextEditingController addressCont = TextEditingController();
  TextEditingController cityCont = TextEditingController();
  TextEditingController countryCont = TextEditingController();
  TextEditingController postalCodeCont = TextEditingController();
  String? userLogin = "";

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode dOBFocus = FocusNode();
  FocusNode genderFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode postalCodeFocus = FocusNode();

  DateTime? birthDate;

  @override
  void initState() {
    super.initState();
    init();
    setDynamicStatusBarColor(color: appPrimaryColor);
  }

  init() async {
    genderList.add(GenderModel(name: translate('lblMale'), value: "Male"));
    genderList.add(GenderModel(name: translate('lblFemale'), value: "Female"));
    genderList.add(GenderModel(name: translate('lblOther'), value: "Other"));
    isUpdate = widget.userId != null;
    if (isUpdate) {
      isLoading = true;
      setState(() {});
      getUserDetails(widget.userId).then((value) {
        getUserDetail = value;

        firstNameCont.text = getUserDetail!.first_name.validate();
        lastNameCont.text = getUserDetail!.last_name.validate();
        emailCont.text = getUserDetail!.user_email.validate();
        if (getUserDetail!.dob.validate().isNotEmpty) if (getUserDetail!.dob.validate().isNotEmpty) {
          dOBCont.text = getUserDetail!.dob.validate();
          birthDate = DateTime.parse(getUserDetail!.dob.validate());
        }
        contactNumberCont.text = getUserDetail!.mobile_number.validate();
        if (getUserDetail!.gender.validate().isNotEmpty) genderValue = getUserDetail!.gender.capitalizeFirstLetter().validate();
        addressCont.text = getUserDetail!.address.validate();
        cityCont.text = getUserDetail!.city.validate();
        countryCont.text = getUserDetail!.country.validate();
        postalCodeCont.text = getUserDetail!.postal_code.validate();
        if (getUserDetail!.blood_group.validate().isNotEmpty) {
          bloodGroup = getUserDetail!.blood_group.validate(value: '');
        }
        userLogin = getUserDetail!.user_login!.validate();
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }

  addNewPatientDetail() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      isLoading = true;
      setState(() {});

      Map request = {
        "first_name": firstNameCont.text.validate(),
        "last_name": lastNameCont.text.validate(),
        "user_email": emailCont.text.validate(),
        "mobile_number": contactNumberCont.text.validate(),
        "gender": genderValue.validate().toLowerCase(),
        "dob": birthDate!.getFormattedDate(CONVERT_DATE).validate(),
        "address": addressCont.text.validate(),
        "city": cityCont.text.validate(),
        "country": countryCont.text.validate(),
        "postal_code": postalCodeCont.text.validate(),
        "blood_group": bloodGroup.validate(),
      };
      addNewPatientData(request).then((value) {
        finish(context, true);
        successToast(translate('lblNewPatientAddedSuccessfully'));
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }

  updatePatientDetail() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      isLoading = true;
      setState(() {});

      Map request = {
        "ID": widget.userId,
        "first_name": firstNameCont.text.validate(),
        "last_name": lastNameCont.text.validate(),
        "user_email": emailCont.text.validate(),
        "mobile_number": contactNumberCont.text.validate(),
        "gender": genderValue.validate(),
        "dob": birthDate!.getFormattedDate(CONVERT_DATE).validate(),
        "address": addressCont.text.validate(),
        "city": cityCont.text.validate(),
        "country": countryCont.text.validate(),
        "postal_code": postalCodeCont.text.validate(),
        "blood_group": bloodGroup.validate(),
        "user_login": userLogin,
      };

      updatePatientData(request).then((value) {
        successToast(translate('lblPatientDetailUpdatedSuccessfully'));

        finish(context, true);
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }

  Future<void> dateBottomSheet(context, {DateTime? bDate}) async {
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
                      if (DateTime.now().year - birthDate!.year < 18) {
                        toast(
                          translate('lblMinimumAgeRequired') + translate('lblCurrentAgeIs') + ' ${DateTime.now().year - birthDate!.year}',
                          bgColor: errorBackGroundColor,
                          textColor: errorTextColor,
                        );
                      } else {
                        finish(context);
                        dOBCont.text = birthDate!.getFormattedDate(BIRTH_DATE_FORMAT).toString();
                      }
                    })
                  ],
                ).paddingOnly(top: 8, left: 8, right: 8, bottom: 8),
              ),
              Container(
                height: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: primaryTextStyle(size: 20))),
                  child: CupertinoDatePicker(
                    minimumDate: DateTime(1900, 1, 1),
                    minuteInterval: 1,
                    initialDateTime: bDate == null ? DateTime.now() : bDate,
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (DateTime dateTime) {
                      birthDate = dateTime;
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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    firstNameCont.dispose();
    lastNameCont.dispose();
    emailCont.dispose();
    contactNumberCont.dispose();
    dOBCont.dispose();
    addressCont.dispose();
    cityCont.dispose();
    countryCont.dispose();
    postalCodeCont.dispose();

    firstNameFocus.dispose();
    lastNameFocus.dispose();
    emailFocus.dispose();
    contactNumberFocus.dispose();
    dOBFocus.dispose();
    genderFocus.dispose();
    addressFocus.dispose();
    cityFocus.dispose();
    countryFocus.dispose();
    postalCodeFocus.dispose();

    setDynamicStatusBarColor();
    super.dispose();
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate('lblBasicInformation').toUpperCase(), style: boldTextStyle(size: 16)),
            16.height,
            Row(
              children: [
                AppTextField(
                  controller: firstNameCont,
                  nextFocus: lastNameFocus,
                  textFieldType: TextFieldType.NAME,
                  errorThisFieldRequired: translate('lblFirstNameIsRequired'),
                  decoration: textInputStyle(context: context, label: 'lblFirstName'),
                ).expand(),
                10.width,
                AppTextField(
                  controller: lastNameCont,
                  nextFocus: emailFocus,
                  errorThisFieldRequired: translate('lblLastNameIsRequired'),
                  textFieldType: TextFieldType.NAME,
                  decoration: textInputStyle(context: context, label: 'lblLastName'),
                ).expand(),
              ],
            ),
            16.height,
            AppTextField(
              controller: emailCont,
              nextFocus: contactNumberFocus,
              textFieldType: TextFieldType.EMAIL,
              errorThisFieldRequired: translate('lblEmailIsRequired'),
              decoration: textInputStyle(context: context, label: 'lblEmail'),
            ),
            16.height,
            AppTextField(
              nextFocus: dOBFocus,
              controller: contactNumberCont,
              textFieldType: TextFieldType.PHONE,
              maxLength: 10,
              buildCounter: (context, {int? currentLength, bool? isFocused, maxLength}) {
                return null;
              },
              validator: (s) {
                if (s!.trim().isEmpty) return translate('lblContactNumberIsRequired');
                return null;
              },
              decoration: textInputStyle(context: context, label: 'lblContactNumber'),
            ),
            16.height,
            AppTextField(
              controller: dOBCont,
              focus: dOBFocus,
              nextFocus: genderFocus,
              readOnly: true,
              decoration: textInputStyle(context: context, label: 'lblDOB'),
              onTap: () {
                if (dOBCont.text != '') {
                  dateBottomSheet(context, bDate: birthDate);
                } else {
                  dateBottomSheet(context);
                }
              },
              textFieldType: TextFieldType.OTHER,
            ),
            16.height,
            DropdownButtonFormField(
              value: genderValue,
              decoration: textInputStyle(context: context, label: 'lblGender'),
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              focusColor: appPrimaryColor,
              validator: (dynamic s) {
                if (s == null) return translate('lblGenderIsRequired');
                return null;
              },
              onChanged: (dynamic value) {
                genderValue = value;
              },
              items: genderList.map((gender) => DropdownMenuItem(value: gender.value, child: Text("${gender.name}", style: primaryTextStyle()))).toList(),
            ),
            16.height,
            /*     Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: viewLineColor, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration.collapsed(hintText: null),
                  hint: Text('Blood group', style: secondaryTextStyle()),
                  dropdownColor: context.cardColor,
                  value: serviceStatus!.isNotEmpty ? serviceStatus : null,
                  items: statusList.map((String data) {
                    return DropdownMenuItem<String>(
                      value: data,
                      child: Text(
                        data,
                        style: primaryTextStyle(),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) async {
                    serviceStatus = value.validate();
                    setState(() {});
                  },
                ),
              ).expand(),*/
            DropdownButtonFormField(
              value: bloodGroup,
              decoration: textInputStyle(context: context, label: 'lblBloodGroup'),
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              onChanged: (dynamic value) {
                bloodGroup = value;
              },
              items: bloodGroupList.map((bloodGroup) => DropdownMenuItem(value: bloodGroup, child: Text("$bloodGroup", style: primaryTextStyle()))).toList(),
            ),
            16.height,
            Text(translate('lblOtherInformation').toUpperCase(), style: boldTextStyle(size: 16)),
            16.height,
            AppTextField(
              controller: addressCont,
              focus: addressFocus,
              nextFocus: cityFocus,
              textFieldType: TextFieldType.ADDRESS,
              decoration: textInputStyle(context: context, label: 'lblAddress'),
              minLines: 4,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
            16.height,
            AppTextField(
              controller: cityCont,
              focus: cityFocus,
              nextFocus: countryFocus,
              textFieldType: TextFieldType.OTHER,
              decoration: textInputStyle(context: context, label: 'lblCity'),
            ),
            16.height,
            Row(
              children: [
                AppTextField(
                  controller: countryCont,
                  focus: countryFocus,
                  nextFocus: postalCodeFocus,
                  textFieldType: TextFieldType.OTHER,
                  decoration: textInputStyle(context: context, label: 'lblCountry'),
                ).expand(),
                15.width,
                AppTextField(
                  controller: postalCodeCont,
                  focus: postalCodeFocus,
                  textFieldType: TextFieldType.OTHER,
                  decoration: textInputStyle(context: context, label: 'lblPostalCode'),
                ).expand(),
              ],
            ),
            65.height,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(
          context,
          name: !isUpdate ? translate('lblAddNewPatient') : translate('lblEditPatientDetail'),
        ),
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            isUpdate ? updatePatientDetail() : addNewPatientDetail();
          },
          child: Icon(Icons.check, color: Colors.white),
        ).visible(!isLoading),
      ),
    );
  }
}
