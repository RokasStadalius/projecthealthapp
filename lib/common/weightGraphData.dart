import 'package:collection/collection.dart';

class WeightGraphData {
  final double x;
  final double y;
  WeightGraphData({required this.x, required this.y});
}

List<WeightGraphData> get weightData {
  final data = <double>[90, 89, 88, 85];
  return data
      .mapIndexed(
          ((index, element) => WeightGraphData(x: index.toDouble(), y: element)))
      .toList();
}
