import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class WeeklyChartComponent extends StatefulWidget {
  List<WeeklyAppointment>? weeklyAppointment;

  WeeklyChartComponent({this.weeklyAppointment});

  @override
  State<StatefulWidget> createState() => WeeklyChartComponentState();
}

class WeeklyChartComponentState extends State<WeeklyChartComponent> {
  final Duration animDuration = Duration(milliseconds: 250);

  int? touchedIndex;

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 12 / 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          BarChart(
            mainBarData(),
            swapAnimationDuration: animDuration,
          ).paddingSymmetric(horizontal: 8).expand(),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          colors: isTouched ? [Colors.white] : [barColor],
          width: width,
          borderRadius: BorderRadius.circular(defaultRadius),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 20,
            colors: appStore.isDarkModeOn ? [context.cardColor] : [selectedColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() {
    return List.generate(widget.weeklyAppointment!.length, (i) {
      return makeGroupData(
        i,
        widget.weeklyAppointment![i].y!.toDouble() == 1 ? 0 : widget.weeklyAppointment![i].y!.toDouble(),
        isTouched: i == touchedIndex,
        barColor: primaryColor,
      );
    });
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              late String weekDay;
              switch (group.x.toInt()) {
                case 0:
                  weekDay = 'M';
                  break;
                case 1:
                  weekDay = 'T';
                  break;
                case 2:
                  weekDay = 'W';
                  break;
                case 3:
                  weekDay = 'T';
                  break;
                case 4:
                  weekDay = 'F';
                  break;
                case 5:
                  weekDay = 'S';
                  break;
                case 6:
                  weekDay = 'S';
                  break;
              }
              return BarTooltipItem(weekDay + '\n' + (rod.y - 1).toString(), TextStyle(color: Colors.yellow));
            }),
        touchCallback: (barTouchResponse) {
          setState(() {
            if (barTouchResponse.spot != null && barTouchResponse.touchInput is! PointerUpEvent && barTouchResponse.touchInput is! PointerExitEvent) {
              touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => boldTextStyle(size: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return 'M';
              case 1:
                return 'T';
              case 2:
                return 'W';
              case 3:
                return 'T';
              case 4:
                return 'F';
              case 5:
                return 'S';
              case 6:
                return 'S';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: 2,
          margin: 16,
          getTextStyles: (context, value) => boldTextStyle(size: 14),
          getTitles: (double value) {
            switch (value.toInt()) {
              case -1:
                return 'M';

              default:
                return (value % 100).toInt().toString();
            }
          },
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
    );
  }
}
