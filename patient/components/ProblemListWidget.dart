import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/components/EncounterItemWidget.dart';
import 'package:kivicare_flutter/main/model/MedicalHistroyModel.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class ProblemListWidget extends StatefulWidget {
  final String? encounterType;

  List<EncounterType>? medicalHistory;

  ProblemListWidget({this.medicalHistory, this.encounterType});

  @override
  _ProblemListWidgetState createState() => _ProblemListWidgetState();
}

class _ProblemListWidgetState extends State<ProblemListWidget> {
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
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${widget.encounterType.capitalizeFirstLetter()}s (${widget.medicalHistory!.length})", style: boldTextStyle()),
          16.height,
          ListView.separated(
            itemCount: widget.medicalHistory!.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              EncounterType data = widget.medicalHistory![index];
              return EncounterItemWidget(
                data: data,
                isDeleteOn: false,
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(color: viewLineColor);
            },
          ).visible(widget.medicalHistory!.isNotEmpty, defaultWidget: noDataTextWidget()),
        ],
      ),
    );
  }
}
