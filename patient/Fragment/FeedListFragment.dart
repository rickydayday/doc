import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/Fragment/FeedDetailsScreen.dart';
import 'package:kivicare_flutter/patient/model/NewsModel.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';

class FeedListFragment extends StatefulWidget {
  @override
  _FeedListFragmentState createState() => _FeedListFragmentState();
}

class _FeedListFragmentState extends State<FeedListFragment> {
  bool descTextShowFlag = false;

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
    return FutureBuilder<NewsModel>(
      future: getNewsList(),
      builder: (_, snap) {
        if (snap.hasData) {
          return ListView.builder(
            itemCount: snap.data!.newsData!.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 16),
            itemBuilder: (BuildContext context, int index) {
              NewsData data = snap.data!.newsData![index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.transparent, width: 2),
                          gradient: LinearGradient(
                            colors: [
                              getColorFromHex('#FFDC80'),
                              getColorFromHex('#C13584'),
                              getColorFromHex('#833AB4'),
                            ],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: cachedImage(data.image.validate(), fit: BoxFit.cover),
                        ).onTap(
                          () {},
                        ),
                      ),
                      16.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${data.post_title.validate()}', style: boldTextStyle()),
                          Text('${data.readable_date.validate()}', style: secondaryTextStyle(size: 12)).paddingOnly(right: 8),
                        ],
                      ).expand(),
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {
                          Share.share(data.share_url.validate());
                        },
                      )
                    ],
                  ).paddingOnly(left: 8, right: 8),
                  8.height,
                  cachedImage("${data.image.validate()}", fit: BoxFit.fitWidth, width: context.width()),
                  8.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${parseHtmlString(data.post_excerpt.validate())}', style: secondaryTextStyle()),
                      8.height,
                      Text(translate('lblBy') + ' ${data.post_author_name.validate().capitalizeFirstLetter()} ${data.human_time_diff.validate()}', style: boldTextStyle(size: 12)),
                    ],
                  ).paddingOnly(left: 8, right: 8),
                  24.height,
                ],
              ).onTap(() {
                FeedDetailsScreen(newsData: data).launch(context);
              });
            },
          );
        }
        return snapWidgetHelper(snap);
      },
    );
  }
}
