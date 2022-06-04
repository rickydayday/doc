
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:nb_utils/nb_utils.dart';

class DashBoardCountWidget extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final int? count;
  final Color? color1;
  final Color? color2;
  final IconData? icon;

  DashBoardCountWidget({this.title, this.subTitle, this.count, this.color1, this.color2, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(left: 8, right: 8),
      // width: context.width() * 0.45 - 2,
      width: context.width() / 2 - 25,
      height: 120,
      alignment: Alignment.center,
      decoration: boxDecorationWithShadow(
        blurRadius: 0,
        spreadRadius: 0,
        border: Border.all(color: context.dividerColor),
        borderRadius: BorderRadius.circular(defaultRadius),
        backgroundColor: Theme.of(context).cardColor,
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title?.toUpperCase() ?? translate('lblTotalPatient').toUpperCase(), style: secondaryTextStyle(size: 12, color: primaryColor)),
                  5.height,
                  Text(count?.toString() ?? 1.toString(), style: boldTextStyle(size: 24)).expand(),
                  16.height,
                  Text(subTitle ?? translate('lblTotalVisitedPatient'), style: secondaryTextStyle(size: 12)),
                ],
              ).expand()
            ],
          ).paddingOnly(top: 16, left: 8, right: 8, bottom: 16),
          Positioned(
            top: -10,
            right: isRTL ? null : -10,
            left: isRTL ? -10 : null,
            child: Container(
                // height: 75,
                // width: 65,
                padding: EdgeInsets.all(20),
                decoration: boxDecorationWithShadow(
                  boxShape: BoxShape.circle,
                  boxShadow: null,
                  gradient: LinearGradient(
                    colors: [
                      color1 ?? getColorFromHex('#E3482F'),
                      color2 ?? getColorFromHex('#E3712F'),
                      //           color1,
                    ],
                  ),
                ),
                child: FaIcon(icon ?? FontAwesomeIcons.userInjured, color: Colors.white).center()),
          ),
        ],
      ),
    );
  }
}
