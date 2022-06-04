
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/doctor/screens/AddPatientScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/PatientListModel.dart';
import 'package:kivicare_flutter/main/screens/EncounterScreen.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientFragment extends StatefulWidget {
  @override
  _PatientFragmentState createState() => _PatientFragmentState();
}

class _PatientFragmentState extends State<PatientFragment> {
  TextEditingController searchCont = TextEditingController();
  bool isLoading = false;

  List<PatientData> patientDataList = [];
  List<PatientData> patientList = [];

  int page = 1;

  bool isList = false;
  bool isLastPage = false;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PatientFragment oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    searchCont.dispose();
    super.dispose();
  }

  Widget body() {
    return NotificationListener(
      onNotification: (dynamic n) {
        if (!isLastPage && isReady) {
          if (n is ScrollEndNotification) {
            page++;
            isReady = false;

            setState(() {});
          }
        }
        return !isLastPage;
      },
      child: FutureBuilder<PatientListModel>(
        future: getPatientList(page: page),
        builder: (_, snap) {
          if (snap.hasData) {
            if (page == 1) patientList.clear();
            patientList.addAll(snap.data!.patientData!);
            isReady = true;
            isLastPage = snap.data!.total.validate() <= patientList.length;
            if (patientList.isNotEmpty) {
              return Stack(
                children: [
                  Text(translate('lblPatients') + ' (${snap.data!.total.toString().validate()})', style: boldTextStyle(size: 16)),
                  ListView.builder(
                    padding: EdgeInsets.only(bottom: 60),
                    shrinkWrap: true,
                    itemCount: patientList.length,
                    itemBuilder: (BuildContext context, int index) {
                      PatientData data = patientList[index];
                      String maleImage = "images/patientAvatars/patient3.png";
                      String femaleImage = "images/patientAvatars/patient6.png";
                      String image = data.gender.validate().toLowerCase() == "male" ? maleImage : femaleImage;
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: boxDecorationWithShadow(
                          blurRadius: 0,
                          spreadRadius: 0,
                          border: Border.all(color: context.dividerColor),
                          borderRadius: BorderRadius.circular(defaultRadius),
                          backgroundColor: Theme.of(context).cardColor,
                        ),
                        child: Row(
                          children: [
                            data.profile_image == null
                                ? Image.asset(image, height: 100).paddingAll(8)
                                : cachedImage(
                                    data.profile_image.validate(),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ).cornerRadiusWithClipRRect(defaultRadius).paddingAll(8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset("images/icons/name.svg", height: 18, width: 18, color: appStore.isDarkModeOn ? Colors.white : Colors.black),
                                        6.width,
                                        Text(data.display_name.validate(), style: boldTextStyle(size: 14)),
                                      ],
                                    ).expand(),
                                    menuOption(patientData: data, image: image),
                                  ],
                                ),
                                4.height,
                                Row(
                                  children: [
                                    SvgPicture.asset("images/icons/email.svg", height: 18, width: 18, color: appStore.isDarkModeOn ? Colors.white : Colors.black),
                                    6.width,
                                    Text(data.user_email.validate(), style: secondaryTextStyle(size: 16)).expand(),
                                  ],
                                ),
                                4.height,
                                Row(
                                  children: [
                                    SvgPicture.asset("images/icons/phone.svg", height: 18, width: 18, color: appStore.isDarkModeOn ? Colors.white : Colors.black),
                                    6.width,
                                    Text(data.mobile_number.validate(), style: secondaryTextStyle(size: 16)),
                                  ],
                                ),
                                4.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset("images/icons/user.png", height: 18, width: 18, color: appStore.isDarkModeOn ? Colors.white : Colors.black),
                                        6.width,
                                        Text(data.gender.validate().isNotEmpty ? '${data.gender.validate().capitalizeFirstLetter()}' : 'NA', style: primaryTextStyle()),
                                      ],
                                    ),
                                    data.blood_group.validate().isNotEmpty
                                        ? Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: boxDecorationWithRoundedCorners(
                                              backgroundColor: greenbackGroundColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(defaultRadius),
                                            ),
                                            child: Text(data.blood_group.validate(), style: boldTextStyle(size: 12, color: greenbackGroundColor)),
                                          )
                                        : 0.height
                                  ],
                                ),
                              ],
                            ).paddingAll(4).expand()
                          ],
                        ),
                      );
                    },
                  ).paddingTop(32),
                  setLoader().visible(isSnapshotLoading(snap)).center(),
                ],
              ).paddingAll(16);
            } else {
              return noDataWidget(text: translate('lblNoPatientFound'));
            }
          }
          return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
        },
      ),
    );
  }

  Widget menuOption({PatientData? patientData, String? image}) {
    return PopupMenuButton(
      onSelected: (dynamic value) async {
        if (value == 0) {
          bool? res = await AddPatientScreen(userId: patientData!.iD).launch(context);
          if (res ?? false) setState(() {});
        } else if (value == 1) {
          EncounterScreen(patientData: patientData, image: image).launch(context);
        } else if (value == 2) {
          bool res = await (showConfirmDialog(context, translate('lblDeleteRecordConfirmation') + " ${patientData!.display_name}?", buttonColor: primaryColor));
          if (res) {
            isLoading = true;
            setState(() {});
            Map request = {"patient_id": patientData.iD};
            deletePatientData(request).then((value) {
              isLoading = false;
              setState(() {});
              successToast(translate('lblAllRecordsFor') + " ${patientData.display_name} " + translate('lblAreDeleted'));
            }).catchError((e) {
              isLoading = false;
              setState(() {});
              errorToast(e.toString());
            });
          }
        }
      },
      child: Icon(Icons.more_vert_outlined, size: 20),
      itemBuilder: (BuildContext context) {
        List<PopupMenuItem> list = [];
        list.add(
          PopupMenuItem(
            value: 0,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(FontAwesomeIcons.penAlt, size: 16).withWidth(20),
                6.width,
                Text(translate('lblEditPatient'), style: primaryTextStyle(size: 14)),
              ],
            ),
          ),
        );
        list.add(
          PopupMenuItem(
            value: 1,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(FontAwesomeIcons.calendarCheck, size: 16).withWidth(20),
                6.width,
                Text(translate('lblEncounters'), style: primaryTextStyle(size: 14)),
              ],
            ),
          ),
        );
        list.add(
          PopupMenuItem(
            value: 2,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(FontAwesomeIcons.trash, size: 16).withWidth(20),
                6.width,
                Text(translate('lblDelete'), style: primaryTextStyle(size: 14)),
              ],
            ),
          ),
        );
        return list;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.add, color: Colors.white),
          onPressed: () async {
            bool? res = await AddPatientScreen().launch(context);
            if (res ?? false) setState(() {});
          },
        ),
        body: body(),
      ),
    );
  }
}
