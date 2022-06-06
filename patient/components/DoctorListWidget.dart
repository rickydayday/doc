import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/components/DoctorDetailsScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorListWidget extends StatefulWidget {
  @override
  _DoctorListWidgetState createState() => _DoctorListWidgetState();
}

class _DoctorListWidgetState extends State<DoctorListWidget> {
  int selectedDoctor = -1;
  int page = 1;

  bool isLastPage = false;
  bool isReady = false;

  List<DoctorList> doctorList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
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
      child: FutureBuilder<DoctorListModel>(
        future: getDoctorList(page: page, clinicId: isProEnabled() ? appointmentAppStore.mClinicSelected!.clinic_id.toInt() : null),
        builder: (_, snap) {
          if (snap.hasData) {
            if (page == 1) doctorList.clear();

            doctorList.addAll(snap.data!.doctorList.validate());
            isReady = true;

            isLastPage = snap.data!.total.validate() <= doctorList.length;
            if (doctorList.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: doctorList.length,
                itemBuilder: (BuildContext context, int index) {
                  DoctorList data = doctorList[index];
                  String maleImage = "images/doctorAvatars/doctor2.png";
                  String femaleImage = "images/doctorAvatars/doctor1.png";
                  String image = data.gender!.toLowerCase() == "male" ? maleImage : femaleImage;
                  return GestureDetector(
                    onTap: () {
                      if (selectedDoctor == index) {
                        selectedDoctor = -1;
                        appointmentAppStore.setSelectedDoctor(null);
                      } else {
                        selectedDoctor = index;
                        appointmentAppStore.setSelectedDoctor(data);
                      }
                      setState(() {});
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 8, bottom: 8),
                      decoration: boxDecorationWithShadow(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        border: Border.all(color: context.dividerColor),
                        backgroundColor: selectedDoctor == index ? selectedColor : context.cardColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          data.profile_image == null
                              ? Container(
                                  decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle),
                                  child: Image.asset(
                                    image,
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  ).cornerRadiusWithClipRRect(45)).paddingLeft(16)
                              : cachedImage(
                                  data.profile_image,
                                  height: 90,
                                  width: 90,
                                ).cornerRadiusWithClipRRect(45).paddingLeft(16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              8.height,
                              Text("Dr. ${data.display_name.validate()}", style: boldTextStyle(size: 16)),
                              6.height,
                              Text(data.specialties.validate().isNotEmpty ? data.specialties.validate() : 'NA', style: secondaryTextStyle()),
                              8.height,
                              AppButton(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                text: translate('lblViewDetails'),
                                textStyle: primaryTextStyle(color: white),
                                color: context.primaryColor,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                                    builder: (context) {
                                      return DoctorDetailScreen(data: data);
                                    },
                                  );
                                },
                              )
                            ],
                          ).paddingSymmetric(horizontal: 8, vertical: 10).expand(),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return noDataWidget(text: translate('lblNoDataFound'));
            }
          }
          return snapWidgetHelper(snap);
        },
      ),
    );
  }
}
