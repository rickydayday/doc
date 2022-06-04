import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/doctor/Fragments/AddQualificationScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';

class ProfileQualification extends StatefulWidget {
  final GetDoctorDetailModel? getDoctorDetail;

  ProfileQualification({this.getDoctorDetail});

  @override
  _ProfileQualificationState createState() => _ProfileQualificationState();
}

class _ProfileQualificationState extends State<ProfileQualification> {
  GetDoctorDetailModel? getDoctorDetail;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    getDoctorDetail = widget.getDoctorDetail;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didUpdateWidget(covariant ProfileQualification oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  saveDetails() async {
    Map<String, dynamic> request = {
      "qualifications": jsonEncode(getDoctorDetail!.qualifications),
    };
    editProfileAppStore.addData(request);
    toast(translate('lblDataSaved'));
    await Future.delayed(Duration(milliseconds: 500));
    isLoading = true;
    setState(() {});
    await updateProfile(editProfileAppStore.editProfile, file: image != null ? File(image!.path) : null).then((value) {
      finish(context);
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    setDynamicStatusBarColor();
  }

  Widget body() {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.topEnd,
          child: Container(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor),
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: primaryColor),
                8.width,
                Text(translate('lblAddNewQualification'), style: primaryTextStyle()),
              ],
            ).onTap(
              () async {
                bool? res = await AddQualificationScreen(data: getDoctorDetail, qualificationList: getDoctorDetail!.qualifications == null ? getDoctorDetail!.qualifications = [] : getDoctorDetail!.qualifications)
                    .launch(context);
                if (res ?? false) {
                  setState(() {});
                }
              },
            ),
          ),
        ),
        16.height,
        ListView.builder(
          shrinkWrap: true,
          itemCount: (getDoctorDetail!.qualifications == null || getDoctorDetail!.qualifications!.isEmpty) ? 0 : getDoctorDetail!.qualifications!.length,
          itemBuilder: (BuildContext context, int index) {
            Qualification data = getDoctorDetail!.qualifications![index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
                color: context.cardColor,
                border: Border.all(color: context.dividerColor),
              ),
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.graduationCap, size: 20, color: primaryColor),
                  16.width,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(data.degree!.toUpperCase().validate(), style: boldTextStyle(size: 16)),
                          5.width,
                          Text('- ${data.year.toString().validate()}', style: primaryTextStyle(size: 14)),
                        ],
                      ),
                      Text(data.university.validate(), style: secondaryTextStyle())
                    ],
                  ).expand(),
                  FaIcon(FontAwesomeIcons.edit, size: 20, color: appStore.isDarkModeOn ? Colors.white : Colors.black).onTap(() {
                    AddQualificationScreen(qualification: data, data: getDoctorDetail, qualificationList: getDoctorDetail!.qualifications).launch(context);
                  }),
                ],
              ),
            );
          },
        ),
      ],
    ).paddingAll(16);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.done, color: Colors.white),
          onPressed: () async {
            saveDetails();
          },
        ),
      ),
    );
  }
}
