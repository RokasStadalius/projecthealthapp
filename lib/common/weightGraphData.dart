import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecthealthapp/common/databaseService.dart';

class WeightGraphData {
  final double x;
  final double y;
  WeightGraphData({required this.x, required this.y});
}

List<double> weights = [];
Future<void> fetchWeights() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('weight')
        .where('userID', isEqualTo: DatabaseService().userId)
        .orderBy('date')
        .get();

    weights = querySnapshot.docs.map((doc) {
      return double.parse(doc['weight']);
    }).toList();
    print(weights);
  } catch (e) {
    print('Error fetching weights: $e');
  }
}

List<WeightGraphData> get weightData {
  fetchWeights();
  return weights
      .mapIndexed(((index, element) =>
          WeightGraphData(x: index.toDouble(), y: element)))
      .toList();
}
