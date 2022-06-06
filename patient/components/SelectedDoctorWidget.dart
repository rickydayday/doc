import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:nb_utils/nb_utils.dart';

class SelectedDoctorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String maleImage = "images/doctorAvatars/doctor2.png";
    String femaleImage = "images/doctorAvatars/doctor1.png";
    String image = appointmentAppStore.mDoctorSelected!.gender!.toLowerCase() == "male" ? maleImage : femaleImage;
    DoctorList data = appointmentAppStore.mDoctorSelected!;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: EdgeInsets.all(4),
      decoration: boxDecorationWithShadow(
        blurRadius: 0,
        spreadRadius: 0,
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: context.dividerColor),
        backgroundColor: Theme.of(context).cardColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          data.profile_image == null
              ? Image.asset(image, height: 60, width: 60)
              : cachedImage(data.profile_image, height: 60, width: 60, radius: defaultRadius, fit: BoxFit.cover).cornerRadiusWithClipRRect(
                  defaultRadius,
                ),
          8.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Dr. ${data.display_name.validate()}", style: boldTextStyle(size: 16)),
              6.width,
              Text("${data.specialties.validate()}", style: secondaryTextStyle(), textAlign: TextAlign.center),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
