import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/components/DoctorDashboardWidget.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorListScreen extends StatefulWidget {
  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  int page = 1;

  bool isLastPage = false;
  bool isReady = false;

  List<DoctorList> doctorList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  TextEditingController searchCont = TextEditingController();

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    searchCont.dispose();
    setDynamicStatusBarColor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: translate('lblClinicDoctor')),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            NotificationListener(
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
                future: getDoctorList(page: page),
                builder: (_, snap) {
                  if (snap.hasData) {
                    if (page == 1) doctorList.clear();
                    doctorList.addAll(snap.data!.doctorList!);
                    isReady = true;
                    isLastPage = snap.data!.total.validate() <= doctorList.length;

                    if (doctorList.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$TOTAL_DOCTOR (${doctorList.length})', style: boldTextStyle(size: 16)),
                          8.height,
                          Wrap(
                            runSpacing: 4,
                            spacing: 16,
                            children: snap.data!.doctorList!
                                .map((e) {
                                  String maleImage = "images/doctorAvatars/doctor2.png";
                                  String femaleImage = "images/doctorAvatars/doctor1.png";
                                  String image = e.gender!.toLowerCase() == "male" ? maleImage : femaleImage;
                                  return DoctorDashboardWidget(image: image, data: e);
                                })
                                .toList(),
                          ),
                        ],
                      );
                    } else {
                      return noDataWidget(text: translate('lblNoDataFound'));
                    }
                  }
                  return snapWidgetHelper(snap);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
