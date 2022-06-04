import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/ResponseModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class GoogleCalendarConfigurationScreen extends StatefulWidget {
  @override
  _GoogleCalendarConfigurationScreenState createState() => _GoogleCalendarConfigurationScreenState();
}

class _GoogleCalendarConfigurationScreenState extends State<GoogleCalendarConfigurationScreen> {
  bool isLoading = false;

  String? userName = "";
  String? photoUrl = "";
  String? userEmail = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
    isLoading = true;
    await getConfiguration().catchError(log).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setDynamicStatusBarColor();
    super.dispose();
  }

  Widget body() {
    bool isCalenderOn() {
      if (appStore.userDoctorGoogleCal == ON) {
        return true;
      } else
        return false;
    }

    return Observer(
      builder: (_) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            cachedImage(photoUrl.validate(), height: 150, width: 150).cornerRadiusWithClipRRect(80).visible(photoUrl!.isNotEmpty),
            16.height,
            Text(userName.validate(value: ""), style: boldTextStyle(size: 24)).visible(userName!.isNotEmpty),
            16.height,
            Text(userEmail.validate(value: ''), style: secondaryTextStyle()).visible(userEmail!.isNotEmpty),
            16.height,
            !isCalenderOn()
                ? AppButton(
                    color: context.scaffoldBackgroundColor,
                    elevation: 4,
                    textStyle: primaryTextStyle(color: Colors.white),
                    child: TextIcon(
                      spacing: 16,
                      prefix: GoogleLogoWidget(size: 20),
                      text: translate('lblConnectWithGoogle'),
                      onTap: null,
                    ),
                    onTap: () async {
                      await authService.signInWithGoogle().then((user) async {
                        //
                        Map<String, dynamic> request = {
                          'code': await user.getIdToken().then((value) => value),
                        };

                        await connectGoogleCalendar(request: request).then((value) async {
                          ResponseModel data = value;
                          userName = user.displayName;
                          photoUrl = user.photoURL;
                          userEmail = user.email;
                          setState(() {});
                          toast(data.message);

                          appStore.setUserDoctorGoogleCal(ON);
                        }).catchError((e) {
                          successToast(e.toString());
                        });
                      }).catchError((e) {
                        toast(e.toString());
                      });
                    },
                  )
                : AppButton(
                    color: context.primaryColor,
                    elevation: 4,
                    textStyle: primaryTextStyle(color: Colors.white),
                    text: translate('lblDisconnect'),
                    onTap: () async {
                      showConfirmDialogCustom(
                        context,
                        onAccept: (c) {
                          disconnectGoogleCalendar().then((value) {
                            appStore.setUserDoctorGoogleCal(OFF);
                            userName = "";
                            photoUrl = "";
                            userEmail = "";
                            toast(value.message.validate());
                          }).catchError((e) {
                            errorToast(e.toString());
                          });
                        },
                        title: translate('lblAreYouSureYouWantToDisconnect'),
                        dialogType: DialogType.CONFIRMATION,
                        positiveText: translate('lblYes'),
                      );
                    },
                  ),
          ],
        ).paddingAll(8);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appAppBar(context, name: translate("lblGoogleCalendarConfiguration")),
      body: body().visible(!isLoading, defaultWidget: setLoader()),
    );
  }
}
