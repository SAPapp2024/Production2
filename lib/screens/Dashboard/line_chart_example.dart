import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartExampleScreen extends StatelessWidget {
  static const String id = '/line_chart_example';
  const LineChartExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            context.goBackWeb();
          },
        ),
        backgroundColor: AppColors.appPrimaryGreen,
        centerTitle: true,
        title: const Text("Line Chart Example"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("images/agrokLogo.png"),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius:
            BorderRadius.all(Radius.circular(4))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 1000,
              height: 500,
              child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(
                      show: false,
                    ),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 0.3,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.w500);
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(meta.formattedValue, style: style),
                            );
                          }
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: 1,
                          color: AppColors.black1,
                          strokeWidth: 2,
                          dashArray: [10, 10],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 5, bottom: 5, left: 20),
                            style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500),
                            labelResolver: (line) => "${line.y}",
                          ),
                        ),
                        HorizontalLine(
                          y: 2,
                          color: AppColors.black1,
                          strokeWidth: 2,
                          dashArray: [10, 10],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 5, bottom: 5, left: 20),
                            style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500),
                            labelResolver: (line) => "${line.y}",
                          ),
                        ),
                      ]
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: AppColors.blue,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                        spots: const [
                          FlSpot(1, 1),
                          FlSpot(3, 1.5),
                          FlSpot(5, 1.4),
                          FlSpot(7, 3.4),
                          FlSpot(10, 2),
                          FlSpot(12, 2.2),
                          FlSpot(13, 1.8),
                        ],
                      ),
                      LineChartBarData(
                        isCurved: true,
                        color: AppColors.orange,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                        dashArray: [2, 12],
                        spots: const [
                          FlSpot(2, 1),
                          FlSpot(3, 4.5),
                          FlSpot(4, 1.4),
                          FlSpot(6, 3.4),
                          FlSpot(7, 2),
                          FlSpot(12, 2.2),
                          FlSpot(13, 1.8),
                        ],
                      )
                    ],
                    lineTouchData: LineTouchData(enabled: false)
                  )
              ),
            ),
          ),
        ),
      ),
    );
  }
}
