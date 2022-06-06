import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/receiptionist/screens/RAddNewDoctor.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  final DoctorList? data;

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: context.width(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 35,
            decoration: boxDecorationWithShadow(backgroundColor: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
          ).center(),
          16.height,
          Row(
            children: [
              Text(translate('lblDoctorDetails').toUpperCase(), style: boldTextStyle()).expand(),
              if (isReceptionist())
                IconButton(
                  icon: FaIcon(Icons.edit, size: 20),
                  onPressed: () async {
                    finish(context);
                    bool? res = await RAddNewDoctor(doctorList: widget.data, isUpdate: true).launch(context);
                    if (res ?? false) {}
                  },
                ),
              if (isReceptionist())
                IconButton(
                  icon: FaIcon(Icons.delete, size: 20),
                  onPressed: () async {
                    bool? res = await showConfirmDialog(context, translate('lblAreYouWantToDeleteDoctor'));
                    if (res ?? false) {
                      finish(context);

                      Map<String, dynamic> request = {
                        "doctor_id": widget.data!.iD,
                      };
                      deleteDoctor(request).then((value) {
                        successToast(translate('lblDoctorDeleted'));
                      }).catchError((e) {
                        errorToast(e.toString());
                      }).whenComplete(() {
                        //
                      });
                    }
                  },
                ),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  finish(context);
                },
              )
            ],
          ),
          Divider(color: viewLineColor),
          Row(
            children: [
              Icon(Icons.drive_file_rename_outline, size: 15, color: primaryColor),
              4.width,
              Text("Dr. ${widget.data!.display_name.validate()}".toUpperCase(), style: primaryTextStyle()),
            ],
          ),
          16.height,
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 15, color: primaryColor),
              4.width,
              Text('${widget.data!.no_of_experience.validate()} ' + translate('lblYearsExperience'), style: primaryTextStyle()),
            ],
          ),
          16.height,
          Row(
            children: [
              Icon(Icons.email_outlined, size: 15, color: primaryColor),
              4.width,
              Text('${widget.data!.user_email.validate()}', style: primaryTextStyle()),
            ],
          ),
          16.height,
          Row(
            children: [
              Icon(Icons.call, size: 15, color: primaryColor),
              4.width,
              Text('${widget.data!.mobile_number.validate()}', style: primaryTextStyle()),
            ],
          ),
          16.height,
          Text(translate('lblAvailableOn'), style: boldTextStyle()),
          widget.data!.available != null
              ? Wrap(
                  spacing: 8,
                  children: List.generate(
                    widget.data!.available!.split(",").length,
                    (index) => Chip(
                      backgroundColor: primaryColor,
                      label: Text('${widget.data!.available!.split(",")[index]}', style: primaryTextStyle(color: Colors.white)),
                    ),
                  ),
                )
              : noDataWidget(),
        ],
      ),
    );
  }
}
