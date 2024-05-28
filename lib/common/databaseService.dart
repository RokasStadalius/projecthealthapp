import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecthealthapp/common/auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String userId = Auth().currentUser!.uid;

  Future<void> AddInitialUserData({required String name}) async {
    await _db.collection('users').add({'userId': userId, 'name': name});
  }

  Future<void> addGeneralQuestions({
    required String birthDate,
    required String gender,
    required String height,
    required String weight,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // currently assuming there's only one document per userId
        String documentId = querySnapshot.docs.first.id;

        await _db.collection('users').doc(documentId).update({
          'birthDate': birthDate,
          'gender': gender,
          'height': height,
          'weight': weight,
        });
      } else {
        print("No document found with userId: $userId");
        // Handle the case where no document matches the userId later
      }
    } catch (e) {
      print("Error adding general questions: $e");
      // Handle the error later
    }
  }

  Future<void> addPreference({required String preference}) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;

        await _db.collection('users').doc(documentId).update({
          'foodPreference': preference,
        });
      } else {
        print("No document found with userId: $userId");
      }
    } catch (e) {
      print("Error adding general questions: $e");
    }
  }

  Future<void> addHealthProblems({required List<String> healthProblems}) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // currently assuming there's only one document per userId
        String documentId = querySnapshot.docs.first.id;

        await _db.collection('users').doc(documentId).update({
          'healthProblems': healthProblems,
        });
      } else {
        print("No document found with userId: $userId");
        // Handle the case where no document matches the userId later
      }
    } catch (e) {
      print("Error adding general questions: $e");
      // Handle the error later
    }
  }

  Future<void> addGoals({required List<String> goals}) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // currently assuming there's only one document per userId
        String documentId = querySnapshot.docs.first.id;

        await _db.collection('users').doc(documentId).update({
          'goals': goals,
        });
      } else {
        print("No document found with userId: $userId");
        // Handle the case where no document matches the userId later
      }
    } catch (e) {
      print("Error adding general questions: $e");
      // Handle the error later
    }
  }

  Future<void> addTimeSpent({required String timeSpent}) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;

        await _db.collection('users').doc(documentId).update({
          'timeSpent': timeSpent,
        });
      } else {
        print("No document found with userId: $userId");
      }
    } catch (e) {
      print("Error adding general questions: $e");
    }
  }

  Stream<QuerySnapshot> userDataStream() {
    return _db
        .collection("user")
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> addDailyData(
      {required int cupCount, required int stepCount}) async {
    DateTime currentDate = DateTime.now();
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('daily')
          .where('userId', isEqualTo: userId)
          .where('date', isLessThanOrEqualTo: currentDate)
          .where('date',
              isGreaterThanOrEqualTo:
                  DateTime.now().subtract(Duration(hours: DateTime.now().hour)))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;

        await _db.collection('daily').doc(documentId).update({
          'waterIntake': cupCount,
          'stepCount': stepCount,
        });
      } else {
        await _db.collection('daily').add({
          'userId': userId,
          'date': currentDate,
          'waterIntake': cupCount,
          'stepCount': stepCount,
        });
      }
    } catch (e) {
      print("Error adding daily data: $e");
    }
  }

  Future<void> addDailyDataFoodIngredients(
      {required List<String> ingredients}) async {
    DateTime currentDate = DateTime.now();
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('daily')
          .where('userId', isEqualTo: userId)
          .where('date', isLessThanOrEqualTo: currentDate)
          .where('date',
              isGreaterThanOrEqualTo:
                  DateTime.now().subtract(Duration(hours: DateTime.now().hour)))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;

        await _db.collection('daily').doc(documentId).update({
          'dailyIngredients': ingredients,
        });
      } else {
        await _db.collection('daily').add({
          'userId': userId,
          'date': currentDate,
          'dailyIngredients': ingredients,
        });
      }
    } catch (e) {
      print("Error adding daily data: $e");
    }
  }

  Future<void> addWeight({required String weight}) async {
    DateTime currentDate = DateTime.now();
    DateTime dateWithoutTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('weight')
          .where('userID', isEqualTo: userId)
          .where('date', isEqualTo: dateWithoutTime)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;

        await _db.collection('weight').doc(documentId).update({
          'weight': weight,
        });
      } else {
        await _db.collection('weight').add({
          'userID': userId,
          'date': dateWithoutTime,
          'weight': weight,
        });
      }
    } catch (e) {
      print("Error adding weight data: $e");
    }
  }

  Future<void> updateWeight({required String weight}) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;

        await _db.collection('users').doc(documentId).update({
          'weight': weight,
        });
      } else {
        print("No document found with userId: $userId");
      }
    } catch (e) {
      print("Error adding general questions: $e");
    }
  }

  Future<Map<String, String>> getUserHeatlthIssues() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('User document does not exist');
    }

    DocumentSnapshot userDoc = querySnapshot.docs.first;
    List<dynamic> healthProblems = userDoc['healthProblems'] as List<dynamic>;
    String dietPreference = userDoc['foodPreference'];
    String timeSpent = userDoc['timeSpent'];

    Map<String, String> nutrientParams = {};

    switch (dietPreference) {
      case 'Vegetarian':
        nutrientParams['health'] = 'vegetarian';
      case 'Vegan':
        nutrientParams['health'] = 'vegan';
      case 'Healthy / balanced diet':
        nutrientParams['diet'] = 'balanced';
      case 'Sports diet':
        nutrientParams['diet'] = 'high-protein';
    }

    switch (timeSpent) {
      case 'Less than 1 hour':
        nutrientParams['time'] = '10-45';
      case '1-2 hours':
        nutrientParams['time'] = '60-120';
      case '2 or longer':
        nutrientParams['time'] = '120%2B';
    }

    for (var issue in healthProblems) {
      switch (issue) {
        case 'Overweight, obesity':
          nutrientParams['calories'] = '300.0-500.0';
          break;
        case 'Heart diseases':
          nutrientParams['CHOLE'] = '0.0-100.0';
          break;
        case 'Type 2 diabetes':
          nutrientParams['SUGAR'] = '0.0-15.0';
        case 'Iron deficiency':
          nutrientParams['FE'] = '2.0-6.0';
        case 'Vitamin D deficiency':
          nutrientParams['VITD'] = '400.0-800.0';
        case 'Calcium deficiency':
          nutrientParams['CA'] = '200.0-500.0';
        case 'Vitamin A deficiency':
          nutrientParams['VITA_RAE'] = '300.0-900.0';
        case 'Magnesium deficiency':
          nutrientParams['MG'] = '100.0-300.0';
        case 'Digestive problems':
          nutrientParams['FIBTG'] = '5.0-10.0';
      }
    }
    return nutrientParams;
  }

  String buildNutrientQuery(Map<String, String> nutrientParams) {
    List<String> queryParams = [];
    nutrientParams.forEach((key, value) {
      queryParams.add('$key=$value');
    });
    return queryParams.join('&');
  }

  Future<void> saveIngredientToFirebase(String ingredient) async {
    final date = DateTime.now().toIso8601String().split('T')[0];

    await _db.collection('DailyIngredients').add({
      'date': date,
      'userId': userId,
      'ingredient': ingredient,
    });
  }

  Future<void> removeIngredientFromFirebase(String ingredient) async {
    final date = DateTime.now().toIso8601String().split('T')[0];

    final snapshot = await _db
        .collection('DailyIngredients')
        .where('date', isEqualTo: date)
        .where('userId', isEqualTo: userId)
        .where('ingredient', isEqualTo: ingredient)
        .get();

    for (var doc in snapshot.docs) {
      await _db.collection('DailyIngredients').doc(doc.id).delete();
    }
  }
}
