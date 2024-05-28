import 'package:fl_chart/fl_chart.dart';
import 'package:projecthealthapp/common/weightGraphData.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecthealthapp/common/databaseService.dart';

class LineChartWidget extends StatelessWidget {
  final List<WeightGraphData> weight;

  const LineChartWidget(this.weight, {Key? key}) : super(key: key);

    Future<List<DateTime>> fetchDates() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('weight')
          .where('userID', isEqualTo: DatabaseService().userId)
          .orderBy('date')
          .get();

         return querySnapshot.docs.map((doc) {
        Timestamp timestamp = doc['date'];
        return timestamp.toDate();
      }).toList();

    } catch (e) {
      print('Error fetching dates: $e');
      return [];
    }
  }

Widget bottomTitleWidgets(double value, TitleMeta meta) {
    return FutureBuilder<List<DateTime>>(
      future: fetchDates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Placeholder while loading
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          List<DateTime> dates = snapshot.data!;
          switch (value.toInt()) {
            case 0:
              return Text("${dates[0].month}-${dates[0].day}");
            case 1:
              return Text("${dates[1].month}-${dates[1].day}");
            case 2:
              return Text("${dates[2].month}-${dates[2].day}");
            case 3:
              return Text("${dates[3].month}-${dates[2].day}");
            case 4:
              return Text("${dates[4].month}-${dates[4].day}");
            case 5:
              return Text("${dates[5].month}-${dates[5].day}");
            case 6:
              return Text("${dates[6].month}-${dates[6].day}");
            default:
              return Container();
          }
        }
        return Container(); // Default return
      },
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
                      
                      'Date',
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
