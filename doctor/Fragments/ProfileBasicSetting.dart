import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';

import 'package:nb_utils/nb_utils.dart';


// ignore: must_be_immutable
class ProfileBasicSettings extends StatefulWidget {
  GetDoctorDetailModel? getDoctorDetail;
  void Function(bool isChanged)? onSave;

  ProfileBasicSettings({this.getDoctorDetail, this.onSave});

  @override
  _ProfileBasicSettingsState createState() => _ProfileBasicSettingsState();
}

class _ProfileBasicSettingsState extends State<ProfileBasicSettings> {
  var formKey = GlobalKey<FormState>();

  GetDoctorDetailModel? getDoctorDetail;

  TextEditingController fixedPriceCont = TextEditingController();
  TextEditingController toPriceCont = TextEditingController();
  TextEditingController fromPriceCont = TextEditingController();
  TextEditingController videoPriceCont = TextEditingController();
  TextEditingController mAPIKeyCont = TextEditingController();
  TextEditingController mAPISecretCont = TextEditingController();

  FocusNode fixedPriceFocus = FocusNode();
  FocusNode toPriceFocus = FocusNode();
  FocusNode fromPriceFocus = FocusNode();
  FocusNode mAPIKeyFocus = FocusNode();
  FocusNode mAPISecretFocus = FocusNode();

  int? result = 0;
  String resultName = "range";

  bool mIsTelemedOn = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    getDoctorDetail = widget.getDoctorDetail;
    if (getDoctorDetail!.price_type.validate() == "range") {
      toPriceCont.text = getDoctorDetail!.price.validate().split('-')[0];
      fromPriceCont.text = getDoctorDetail!.price.validate().split('-')[1];
      result = 0;
      setState(() {});
    } else {
      resultName = 'fixed';
      fixedPriceCont.text = getDoctorDetail!.price.validate();
      result = 1;
      setState(() {});
    }
  }

  saveBasicSettingData() async {
    Map<String, dynamic> request = {
      "price_type": "$resultName",
    };

    if (resultName == 'range') {
      fixedPriceCont.clear();
      request.putIfAbsent('minPrice', () => fromPriceCont.text);
      request.putIfAbsent('maxPrice', () => toPriceCont.text);
    } else {
      fromPriceCont.clear();
      toPriceCont.clear();
      request.putIfAbsent('price', () => fixedPriceCont.text);
    }
    editProfileAppStore.addData(request);
    toast(translate('lblInformationSaved'));
    widget.onSave!.call(true);
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          10.height,
          Row(
            children: [
              Theme(
                data: Theme.of(context).copyWith(unselectedWidgetColor: textPrimaryColor),
                child: Radio(
                  value: 0,
                  groupValue: result,
                  onChanged: (dynamic value) {
                    result = value;
                    resultName = "range";
                    setState(() {});
                  },
                ),
              ),
              Text(translate('lblRange'), style: primaryTextStyle()),
              Theme(
                data: Theme.of(context).copyWith(unselectedWidgetColor: textPrimaryColor),
                child: Radio(
                  value: 1,
                  groupValue: result,
                  onChanged: (dynamic value) {
                    result = value;

                    resultName = "fixed";
                    setState(() {});
                  },
                ),
              ),
              Text(translate('lblFixed'), style: primaryTextStyle()),
            ],
          ),
          20.height,
          Row(
            children: [
              Container(
                child: AppTextField(
                  controller: toPriceCont,
                  focus: toPriceFocus,
                  textFieldType: TextFieldType.NAME,
                  keyboardType: TextInputType.number,
                  decoration: textInputStyle(context: context, label: 'lblToPrice'),
                ).expand(),
              ),
              20.width,
              Container(
                child: AppTextField(
                  controller: fromPriceCont,
                  focus: fromPriceFocus,
                  textFieldType: TextFieldType.NAME,
                  keyboardType: TextInputType.number,
                  decoration: textInputStyle(context: context, label: 'lblFromPrice'),
                ).expand(),
              ),
            ],
          ).visible(result == 0),
          Container(
            child: AppTextField(
              controller: fixedPriceCont,
              focus: fixedPriceFocus,
              textFieldType: TextFieldType.NAME,
              keyboardType: TextInputType.number,
              decoration: textInputStyle(context: context, label: 'lblFixedPrice'),
            ),
          ).visible(result == 1),
          16.height,
        ],
      ),
    );
  }

  Widget telemed() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translate('lblZoomConfiguration'), style: boldTextStyle(size: 18, color: primaryColor)),
        16.height,
        SwitchListTile(
          title: Text(translate('lblTelemed') + ' ${mIsTelemedOn ? 'On' : 'Off'}', style: primaryTextStyle(color: mIsTelemedOn ? successTextColor : textPrimaryBlackColor)),
          value: mIsTelemedOn,
          selected: mIsTelemedOn,
          secondary: FaIcon(FontAwesomeIcons.video, size: 20),
          activeColor: successTextColor,
          onChanged: (v) {
            mIsTelemedOn = v;
            setState(() {});
          },
        ),
        Column(
          children: [
            16.height,
            AppTextField(
              controller: videoPriceCont,
              textFieldType: TextFieldType.OTHER,
              decoration: textInputStyle(context: context, text: translate('lblVideoPrice')),
              validator: (v) {
                if (v!.trim().isEmpty) return translate('lblAPIKeyCannotBeEmpty');
                return null;
              },
            ),
            16.height,
            AppTextField(
              controller: mAPIKeyCont,
              textFieldType: TextFieldType.OTHER,
              decoration: textInputStyle(context: context, text: translate('lblAPIKey')),
              validator: (v) {
                if (v!.trim().isEmpty) return translate('lblAPIKeyCannotBeEmpty');
                return null;
              },
            ),
            16.height,
            AppTextField(
              controller: mAPISecretCont,
              textFieldType: TextFieldType.OTHER,
              decoration: textInputStyle(context: context, text: translate('lblAPISecret')),
              validator: (v) {
                if (v!.trim().isEmpty) return translate('lblAPISecretCannotBeEmpty');
                return null;
              },
            ),
            16.height,
            zoomConfigurationGuide(),
          ],
        ).visible(mIsTelemedOn),
      ],
    );
  }

  Widget zoomConfigurationGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translate('lblZoomConfigurationGuide'), style: boldTextStyle(color: primaryColor, size: 18)),
        16.height,
        Container(
          decoration: BoxDecoration(border: Border.all(color: viewLineColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate('lbl1'), style: boldTextStyle()),
                  6.width,
                  createRichText(
                    list: [
                      TextSpan(text: translate('lblSignUpOrSignIn'), style: primaryTextStyle()),
                      TextSpan(
                        text: translate('lblZoomMarketPlacePortal'),
                        style: boldTextStyle(color: primaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl("https://marketplace.zoom.us/", enableJavaScript:false, statusBarBrightness:  Brightness.dark);
                          },
                      ),
                    ],
                  ),
                ],
              ).paddingAll(8),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate('lbl2'), style: boldTextStyle()),
                  6.width,
                  createRichText(list: [
                    TextSpan(text: translate('lblClickOnDevelopButton'), style: primaryTextStyle()),
                    TextSpan(
                      text: translate('lblCreateApp'),
                      style: boldTextStyle(color: primaryColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl("https://marketplace.zoom.us/develop/create", enableJavaScript: false, statusBarBrightness:  Brightness.dark);
                        },
                    ),
                  ], maxLines: 5)
                      .expand(),
                ],
              ).paddingAll(8),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate('lb13'), style: boldTextStyle()),
                  6.width,
                  Text(translate('lblChooseAppTypeToJWT'), style: primaryTextStyle()).expand(),
                ],
              ).paddingAll(8),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate('lbl4'), style: boldTextStyle()),
                  6.width,
                  Text(translate('lblMandatoryMessage'), style: primaryTextStyle()).expand(),
                ],
              ).paddingAll(8),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate('lbl5'), style: boldTextStyle()),
                  6.width,
                  Text(translate('lblCopyAndPasteAPIKey'), style: primaryTextStyle()).expand(),
                ],
              ).paddingAll(8),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    fixedPriceCont.dispose();
    toPriceCont.dispose();
    fromPriceCont.dispose();
    videoPriceCont.dispose();
    mAPIKeyCont.dispose();
    mAPISecretCont.dispose();

    fixedPriceFocus.dispose();
    toPriceFocus.dispose();
    fromPriceFocus.dispose();
    mAPIKeyFocus.dispose();
    mAPISecretFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: body(),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: primaryColor,
          label: Text(translate('lblSaveAndContinue'), style: primaryTextStyle(color: Colors.white)),
          icon: Icon(Icons.arrow_forward, color: textPrimaryWhiteColor),
          onPressed: () {
            hideKeyboard(context);
            saveBasicSettingData();
          },
        ),
      ),
    );
  }
}
