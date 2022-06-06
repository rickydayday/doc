import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/patient/components/DoctorDetailsScreen.dart';
import 'package:kivicare_flutter/patient/screens/AddAppointmentScreenStep2.dart';
import 'package:kivicare_flutter/patient/screens/AddAppointmentScreenStep3.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorDashboardWidget extends StatelessWidget {
  final String? image;
  final DoctorList? data;
  final bool isBooking;

  DoctorDashboardWidget({this.image, this.data, this.isBooking = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: EdgeInsets.all(8),
      width: context.width() / 2 - 25,
      decoration: boxDecorationWithShadow(
        blurRadius: 0,
        spreadRadius: 0,
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: context.dividerColor),
        backgroundColor: Theme.of(context).cardColor,
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              16.height,
              data!.profile_image == null
                  ? Container(
                      decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle),
                      child: Image.asset(
                        image!,
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ).cornerRadiusWithClipRRect(45).center())
                  : cachedImage(
                      data!.profile_image,
                      height: 90,
                      width: 90,
                    ).cornerRadiusWithClipRRect(45).center(),
              12.height,
              Text("Dr. ${data!.display_name.validate()}", style: boldTextStyle(size: 16)),
              6.height,
              data!.specialties.validate().isNotEmpty ? Text(data!.specialties.validate(), style: secondaryTextStyle(), textAlign: TextAlign.center) : SizedBox(),
              /*       6.height,
              data.clinic_id.length >= 1
                  ? UL(
                      children: List.generate(data.clinic_name.split(",").length, (index) {
                        return Text('${data.clinic_name.split(",")[index]}', style: primaryTextStyle());
                      }),
                    )
                  : 0.height,
              6.height,*/
              8.height,
              AppButton(
                text: translate('lblBookNow'),
                textStyle: primaryTextStyle(size: 14, color: primaryColor),
                color: context.cardColor,
                width: context.width(),
                shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius), side: BorderSide(color: viewLineColor)),
                onTap: () {
                  appStore.setBookedFromDashboard(true);
                  appointmentAppStore.setSelectedDoctor(data);
                  isProEnabled() ? AddAppointmentScreenStep3().launch(context) : AddAppointmentScreenStep2().launch(context);
                },
              ).visible(isBooking)
            ],
          ).onTap(() {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
              builder: (context) {
                return DoctorDetailScreen(data: data);
              },
            );
          }),
          Icon(Icons.info, color: primaryColor, size: 20).paddingAll(4)
        ],
      ),
    );
  }
}
