import 'package:async/async.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/model/TelemedModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';


class TelemedScreen extends StatefulWidget {
  @override
  _TelemedScreenState createState() => _TelemedScreenState();
}

class _TelemedScreenState extends State<TelemedScreen> {
  var formKey = GlobalKey<FormState>();
  AsyncMemoizer<TelemedModel> _memorizer = AsyncMemoizer();

  TextEditingController mAPIKeyCont = TextEditingController();
  TextEditingController mAPISecretCont = TextEditingController();

  FocusNode mAPIKeyFocus = FocusNode();
  FocusNode mAPISecretFocus = FocusNode();

  bool mIsTelemedOn = false;
  bool isLoading = false;
  bool isFirst = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
  }

  saveTelemedData() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading = true;
      setState(() {});
      Map<String, dynamic> request = {
        "enableTeleMed": mIsTelemedOn,
        "api_key": "${mAPIKeyCont.text}",
        "api_secret": "${mAPISecretCont.text}",
      };
      addTelemedServices(request).then((value) {
        toast(translate('lblTelemedServicesUpdated'));

        finish(context);
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    mAPIKeyCont.dispose();
    mAPISecretCont.dispose();
    setDynamicStatusBarColor();
    super.dispose();
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: FutureBuilder<TelemedModel>(
        future: _memorizer.runOnce(() => getTelemedServices()),
        builder: (_, snap) {
          if (snap.hasData) {
            if (isFirst) {
              mIsTelemedOn = snap.data!.telemedData!.enableTeleMed.validate(value: false);
              mAPIKeyCont.text = snap.data!.telemedData!.api_key.validate();
              mAPISecretCont.text = snap.data!.telemedData!.api_secret.validate();
              isFirst = false;
            }
            return Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate('lblZoomConfiguration'), style: boldTextStyle(size: 18, color: primaryColor)),
                  16.height,
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(translate('lblTelemed') + ' ${mIsTelemedOn ? translate('lblOn') : translate('lblOff')}', style: primaryTextStyle()),
                    value: mIsTelemedOn,
                    selected: mIsTelemedOn,
                    inactiveTrackColor: Colors.grey.shade300,
                    activeColor: primaryColor,
                    onChanged: (v) {
                      mIsTelemedOn = v;
                      setState(() {});
                    },
                  ),
                  16.height,
                  AppTextField(
                    controller: mAPIKeyCont,
                    textFieldType: TextFieldType.OTHER,
                    decoration: textInputStyle(context: context, label: 'lblAPIKey', isMandatory: true),
                    validator: (v) {
                      if (v!.trim().isEmpty) return translate('lblAPIKeyCannotBeEmpty');
                      return null;
                    },
                  ),
                  16.height,
                  AppTextField(
                    controller: mAPISecretCont,
                    textFieldType: TextFieldType.OTHER,
                    decoration: textInputStyle(context: context, label: 'lblAPISecret', isMandatory: true),
                    validator: (v) {
                      if (v!.trim().isEmpty) return translate('lblAPISecretCannotBeEmpty');
                      return null;
                    },
                  ),
                  16.height,
                  zoomConfigurationGuide()
                ],
              ),
            );
          }
          return snapWidgetHelper(snap);
        },
      ),
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
                              // ignore: deprecated_member_use
                              launchUrl("https://marketplace.zoom.us/", enableJavaScript: false, statusBarBrightness:  Brightness.dark);
                            },
                        ),
                      ],
                    ).expand(),
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
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: translate('lblTelemed')),
        body: body().visible(!isLoading, defaultWidget: setLoader().center()),
        floatingActionButton: AddFloatingButton(
          icon: Icons.done,
          onTap: () {
            saveTelemedData();
          },
        ).visible(!isLoading),
      ),
    );
  }
}
