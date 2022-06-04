import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/AddBillItem.dart';
import 'package:kivicare_flutter/main/model/EncounterDashboardModel.dart';
import 'package:kivicare_flutter/main/model/PatientBillModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class GenerateBillScreen extends StatefulWidget {
  EncounterDashboardModel? data;

  GenerateBillScreen({this.data});

  @override
  _GenerateBillScreenState createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  AsyncMemoizer<PatientBillModule> _memorizer = AsyncMemoizer();
  EncounterDashboardModel? patientData;

  TextEditingController totalCont = TextEditingController();
  TextEditingController discountCont = TextEditingController(text: '0');
  TextEditingController payableCont = TextEditingController();

  bool mIsLoading = false;
  bool isPaid = false;

  String? paymentStatus;

  int payableText = 0;

  List<BillItem> billItemData = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
    patientData = widget.data;
    if (patientData!.payment_status != null) {
      paymentStatus = patientData!.payment_status.toString().toLowerCase();
    }
  }

  saveFrom() {
    if (billItemData.isNotEmpty) {
      mIsLoading = true;
      setState(() {});
      Map<String, dynamic> request = {
        "id": "${patientData!.bill_id == null ? "" : patientData!.bill_id}",
        "encounter_id": "${patientData!.id == null ? "" : patientData!.id}",
        "appointment_id": "${patientData!.appointment_id == null ? "" : patientData!.appointment_id}",
        "total_amount": "${totalCont.text.validate()}",
        "discount": "${discountCont.text.validate()}",
        "actual_amount": "${payableCont.text.validate()}",
        "payment_status": paymentStatus,
        "billItems": billItemData,
      };

      addPatientBill(request).then((value) {
        finish(context);
        successToast(translate('lblBillAddedSuccessfully'));
        LiveStream().emit(UPDATE, true);
        LiveStream().emit(APP_UPDATE, true);
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        mIsLoading = false;
        setState(() {});
      });
    } else {
      errorToast(translate('lblAtLeastSelectOneBillItem'));
    }
  }

  void getTotal() {
    payableText = 0;

    billItemData.forEach((element) {
      payableText += (element.price.validate().toInt() * element.qty.validate().toInt());
    });

    totalCont.text = payableText.toString();
    payableCont.text = payableText.toString();

    setTotalPayable(discountCont.text);
  }

  void setTotalPayable(String v) {
    if (v.isDigit()) {
      payableCont.text = "${payableText - v.toInt()}";
    }
    if (v.trim().isEmpty) {
      payableCont.text = payableText.toString();
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    totalCont.dispose();
    discountCont.dispose();
    payableCont.dispose();
    setDynamicStatusBarColor(color: appPrimaryColor);
    super.dispose();
  }

  Widget body() {
    return FutureBuilder<PatientBillModule>(
      future: _memorizer.runOnce(() => getBillDetails(encounterId: patientData!.id.toInt())),
      builder: (_, snap) {
        if (snap.hasData) {
          if (billItemData.isEmpty) {
            billItemData.addAll(snap.data!.billItems!);
          }
          getTotal();
          return Container(
            child: Stack(
              children: [
                Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        decoration: boxDecorationWithShadow(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(defaultRadius),
                        ),
                        padding: EdgeInsets.all(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: primaryColor, size: 20),
                            4.width,
                            Text(translate('lblAddBillItem'), style: boldTextStyle(color: primaryColor)),
                            4.width,
                          ],
                        ),
                      ).onTap(() async {
                        bool? res = await AddBillItem(billId: patientData!.bill_id.toInt(), billItem: billItemData, doctorId: patientData!.doctor_id.toInt()).launch(context);
                        if (res ?? false) {
                          getTotal();
                          setState(() {});
                        }
                      }),
                    ),
                    32.height,
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(defaultRadius)),
                      child: Row(
                        children: [
                          Text(translate('lblSRNo'), style: boldTextStyle(size: 12, color: Colors.black), textAlign: TextAlign.center).expand(),
                          Text(translate('lblSERVICES'), style: boldTextStyle(size: 12, color: Colors.black), textAlign: TextAlign.center).expand(flex: 2),
                          Text(translate('lblPRICE'), style: boldTextStyle(size: 12, color: Colors.black), textAlign: TextAlign.center).expand(),
                          Text(translate('lblQUANTITY'), style: boldTextStyle(size: 12, color: Colors.black), textAlign: TextAlign.center).expand(),
                          Text(translate('lblTOTAL'), style: boldTextStyle(size: 12, color: Colors.black), textAlign: TextAlign.center).expand(flex: 1),
                        ],
                      ),
                    ),
                    16.height,
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: billItemData.length,
                      itemBuilder: (context, index) {
                        BillItem data = billItemData[index];
                        int total = data.price.validate().toInt() * data.qty.validate().toInt();
                        return Row(
                          children: [
                            Text('${index + 1}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                            Text('${data.label.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 2),
                            Text('${data.price.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                            Text('${data.qty.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                            Text('$total', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 1),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(color: viewLineColor);
                      },
                    )
                  ],
                ).paddingAll(16),
                Positioned(
                  bottom: 160,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: context.width(),
                    decoration: boxDecorationWithShadow(
                      border: Border(top: BorderSide(color: viewLineColor)),
                      blurRadius: 0,
                      spreadRadius: 0,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Row(
                      children: [
                        AppTextField(
                          controller: totalCont,
                          textFieldType: TextFieldType.NAME,
                          decoration: textInputStyle(context: context, label: 'lblTotal', isMandatory: true),
                          readOnly: true,
                        ).expand(),
                        16.width,
                        AppTextField(
                          controller: discountCont,
                          textFieldType: TextFieldType.NAME,
                          keyboardType: TextInputType.number,
                          decoration: textInputStyle(context: context, label: 'lblDiscount', isMandatory: true),
                          onChanged: setTotalPayable,
                          onFieldSubmitted: setTotalPayable,
                        ).expand(),
                        16.width,
                        AppTextField(
                          controller: payableCont,
                          textFieldType: TextFieldType.NAME,
                          decoration: textInputStyle(context: context, label: 'lblPayableAmount'),
                          readOnly: true,
                        ).expand(),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: context.width(),
                    decoration: boxDecorationWithShadow(
                      border: Border(top: BorderSide(color: viewLineColor)),
                      blurRadius: 0,
                      spreadRadius: 0,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      value: paymentStatus,
                      dropdownColor: Theme.of(context).cardColor,
                      decoration: textInputStyle(context: context, label: 'lblStatus', isMandatory: true),
                      items: ["paid", "unpaid"]
                          .map(
                            (e) => DropdownMenuItem(
                              child: Text(e.validate().capitalizeFirstLetter(), style: primaryTextStyle()),
                              value: e,
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) {
                        if (v!.trim() == 'paid') {
                          isPaid = true;
                        } else {
                          isPaid = false;
                        }
                        paymentStatus = v.toString();
                        setState(() {});
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: context.width(),
                    decoration: boxDecorationWithShadow(
                      border: Border(top: BorderSide(color: viewLineColor)),
                      blurRadius: 0,
                      spreadRadius: 0,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppButton(
                          color: context.cardColor,
                          elevation: 0,
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: radius(defaultAppButtonRadius),
                            side: BorderSide(color: primaryColor),
                          ),
                          child: Text(translate('lblCancel'), style: boldTextStyle(color: primaryColor)),
                          onTap: () {
                            finish(context);
                          },
                        ).expand(),
                        16.width,
                        AppButton(
                          color: primaryColor,
                          child: Text('${isPaid ? translate('lblSaveAndCloseEncounter') : translate('lblSave')}', style: boldTextStyle(color: Colors.white)),
                          onTap: () {
                            saveFrom();
                          },
                        ).expand(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return snapWidgetHelper(snap);
      },
    );
  }

  Widget body1() {
    return Stack(
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: boxDecorationWithShadow(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(defaultRadius),
                ),
                padding: EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: primaryColor, size: 20),
                    4.width,
                    Text(translate('lblAddBillItem'), style: boldTextStyle(color: primaryColor)),
                    4.width,
                  ],
                ),
              ).onTap(() async {
                bool? res = await AddBillItem(billId: patientData!.bill_id.toInt(), billItem: billItemData).launch(context);
                if (res ?? false) {
                  getTotal();
                  setState(() {});
                }
              }),
            ),
            32.height,
            Row(
              children: [
                Text(translate('lblSRNo'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                Text(translate('lblSERVICES'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 2),
                Text(translate('lblPRICE'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                Text(translate('lblQUANTITY'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                Text(translate('lblTOTAL'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 1),
              ],
            ),
            16.height,
            ListView.separated(
              shrinkWrap: true,
              itemCount: billItemData.length,
              itemBuilder: (context, index) {
                BillItem data = billItemData[index];
                int total = data.price.validate().toInt() * data.qty.validate().toInt();
                return Row(
                  children: [
                    Text('${index + 1}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                    Text('${data.label.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 2),
                    Text('${data.price.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                    Text('${data.qty.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                    Text('$total', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 1),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return Divider(color: viewLineColor);
              },
            )
          ],
        ).paddingAll(16),
        Positioned(
          bottom: 80,
          child: Container(
            padding: EdgeInsets.all(16),
            width: context.width(),
            decoration: boxDecorationWithShadow(
              border: Border(top: BorderSide(color: viewLineColor)),
              blurRadius: 0,
              spreadRadius: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Row(
              children: [
                AppTextField(
                  controller: totalCont,
                  textFieldType: TextFieldType.NAME,
                  decoration: textInputStyle(context: context, label: 'lblTotal', isMandatory: true),
                  readOnly: true,
                ).expand(),
                16.width,
                AppTextField(
                  controller: discountCont,
                  textFieldType: TextFieldType.NAME,
                  keyboardType: TextInputType.number,
                  decoration: textInputStyle(context: context, label: 'lblDiscount', isMandatory: true),
                  onChanged: setTotalPayable,
                  onFieldSubmitted: setTotalPayable,
                ).expand(),
                16.width,
                AppTextField(
                  controller: payableCont,
                  textFieldType: TextFieldType.NAME,
                  decoration: textInputStyle(context: context, label: 'lblPayableAmount'),
                  readOnly: true,
                ).expand(),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: EdgeInsets.all(16),
            width: context.width(),
            decoration: boxDecorationWithShadow(
              border: Border(top: BorderSide(color: viewLineColor)),
              blurRadius: 0,
              spreadRadius: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  shapeBorder: Border.all(color: primaryColor),
                  color: Colors.transparent,
                  elevation: 0,
                  child: Text(translate('lblCancel'), style: boldTextStyle(color: primaryColor)),
                  onTap: () {
                    //
                  },
                ).cornerRadiusWithClipRRect(defaultRadius).expand(),
                16.width,
                AppButton(
                  color: primaryColor,
                  child: Text('${isPaid ? translate('lblSaveAndCloseEncounter') : translate('lblSave')}', style: boldTextStyle(color: Colors.white)),
                  onTap: () {
                    saveFrom();
                  },
                ).expand(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: translate('lblGenerateInvoice')),
        body: patientData!.bill_id == null ? body1().visible(!mIsLoading, defaultWidget: setLoader()) : body().visible(!mIsLoading, defaultWidget: setLoader()),
      ),
    );
  }
}
