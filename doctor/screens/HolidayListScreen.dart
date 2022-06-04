import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/AddHolidayScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/HolidayModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class HolidayScreen extends StatefulWidget {
  @override
  _HolidayScreenState createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  TextEditingController searchCont = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
    await getDoctor();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  deleteHoliday(int id) async {
    isLoading = true;
    setState(() {});
    Map request = {"id": id};
    await deleteHolidayData(request).then((value) {
      successToast(translate('lblHolidayDeleted'));
    }).catchError((e) {
      errorToast(e.toString());
    });
    isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    setDynamicStatusBarColor();
  }

  @override
  void didUpdateWidget(covariant HolidayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget body() {
    return FutureBuilder<HolidayModel>(
      future: getHolidayResponse(),
      builder: (_, snap) {
        if (snap.hasData) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translate('lblHolidays') + ' (${snap.data!.holidayData!.length.validate()})', style: boldTextStyle()),
                8.height,
                Wrap(
                  spacing: 16,
                  children: List.generate(
                    snap.data!.holidayData!.length,
                        (index) {
                      HolidayData data = snap.data!.holidayData![index];
                      int totalDays = (DateTime.parse(data.end_date!).difference(DateTime.parse(data.start_date!))).inDays;
                      int pendingDays = DateTime.parse(data.end_date!).difference(DateTime.now()).inDays;
                      bool isPending = (DateTime.parse(data.end_date!).isAfter(DateTime.now()));
                      return Container(
                        margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                        width: context.width() / 2 - 24,
                        decoration: boxDecorationWithShadow(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          blurRadius: 0,
                          spreadRadius: 0,
                          border: Border.all(color: context.dividerColor),
                          backgroundColor: Theme.of(context).cardColor,
                        ),
                        child: Stack(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    data.module_type == 'doctor'
                                        ? Text(
                                      listAppStore.doctorList.firstWhereOrNull((element) => element!.iD == data.module_id.toInt()) == null
                                          ? ''
                                          : '${listAppStore.doctorList.firstWhereOrNull((element) => element!.iD == data.module_id.toInt())!.display_name}',
                                      style: boldTextStyle(size: 18),
                                    )
                                        : Text(translate('lblClinic'), style: boldTextStyle(size: 18)),
                                    4.height,
                                    Text('${data.start_date.validate().getFormattedDate('dd-MMM-yyyy').validate()}', style: primaryTextStyle(size: 14)),
                                    4.height,
                                    Container(height: 1, width: 3, color: Colors.black),
                                    4.height,
                                    Text('${data.end_date.validate().getFormattedDate('dd-MMM-yyyy').validate()}', style: primaryTextStyle(size: 14)),
                                    10.height,
                                    Text(translate('lblAfter') + ' ${pendingDays == 0 ? '1' : pendingDays} ' + translate('lblDays'), style: boldTextStyle(size: 16)).visible(isPending),
                                    Text(translate('lblWasOffFor') + ' ${totalDays == 0 ? '1' : totalDays} ' + translate('lblDays'), style: boldTextStyle(size: 16)).visible(!isPending),
                                  ],
                                ).expand(),
                              ],
                            ).paddingAll(16),
                            Positioned(
                              top: 0,
                              left: 0,
                              bottom: 0,
                              child: Container(
                                width: 6,
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: boxDecorationWithRoundedCorners(
                                  backgroundColor: getHolidayStatusColor(isPending).withOpacity(0.5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(defaultRadius),
                                    bottomLeft: Radius.circular(defaultRadius),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).onTap(() async {
                        bool? res = await AddHolidayScreen(holidayData: data).launch(context);
                        if (res ?? false) {
                          setState(() {});
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: appAppBar(context, name: translate('lblYourHolidays')),
          body: body().visible(!isLoading, defaultWidget: setLoader()),
          floatingActionButton: AddFloatingButton(
            onTap: () async {
              bool? res = await AddHolidayScreen().launch(context);
              if (res ?? false) {
                setState(() {});
              }
            },
          )),
    );
  }
}
