import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/main/utils/readmore.dart';
import 'package:kivicare_flutter/patient/Fragment/FeedDetailsScreen.dart';
import 'package:kivicare_flutter/patient/model/NewsModel.dart';
import 'package:nb_utils/nb_utils.dart';

class NewsDashboardWidget extends StatelessWidget {
  final NewsData? newsData;
  final int? index;

  NewsDashboardWidget({this.newsData, this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: index == 0 ? 0 : 4),
      width: index == 0 ? context.width() : context.width() / 2 - 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cachedImage(newsData!.image.validate()).onTap(() {
            FeedDetailsScreen(newsData: newsData).launch(context);
          }),
          5.height,
          Text(translate('lblHealth')),
          10.height,
          Text('${newsData!.post_title.validate()}', style: boldTextStyle(size: 16)),
          5.height,
          ReadMoreText(
            parseHtmlString(newsData!.post_excerpt),
            trimLines: 3,
            style: secondaryTextStyle(),
            moreStyle: secondaryTextStyle(color: appSecondaryColor),
            lessStyle: secondaryTextStyle(color: appSecondaryColor),
            colorClickableText: Colors.pink,
            trimMode: TrimMode.Line,
            trimCollapsedText: translate('lblReadMore'),
            trimExpandedText: translate('lblReadLess'),
            locale: Localizations.localeOf(context),
          ),
          5.height,
          Text(translate('lblBy') + ' ${newsData!.post_author_name.validate().capitalizeFirstLetter()} ${newsData!.human_time_diff.validate()}', style: boldTextStyle(size: 12)),
        ],
      ),
    );
  }
}
