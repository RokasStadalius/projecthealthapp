import 'package:fl_chart/fl_chart.dart';
import 'package:projecthealthapp/common/weightGraphData.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final List<WeightGraphData> weight;

  const LineChartWidget(this.weight, {Key? key}) : super(key: key);

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      default:
        return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color.fromRGBO(59, 59, 59, 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 2,
        child: LineChart(
          LineChartData(
              lineBarsData: [
                LineChartBarData(
                    spots: weight
                        .map((point) => FlSpot(point.x, point.y))
                        .toList(),
                    isCurved: true,
                    dotData: FlDotData(show: true)),
              ],
              titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameSize: 25,
                    axisNameWidget: const Text(
                      
                      'Months',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 18,
                      interval: 1,
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    axisNameSize: 25,
                    axisNameWidget: Text(
                      'Weight',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))),
        ));
  }
}
