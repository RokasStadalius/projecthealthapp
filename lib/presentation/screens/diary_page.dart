import 'package:flutter/material.dart';
import 'package:projecthealthapp/common/databaseService.dart';
import 'package:projecthealthapp/common/lineChart.dart';
import 'package:projecthealthapp/presentation/screens/food_page.dart';
import 'package:projecthealthapp/presentation/screens/main_page.dart';
import 'package:projecthealthapp/presentation/screens/settings_screen.dart';
import 'package:projecthealthapp/common/weightGraphData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  List<String> selectedIngredients = [];
  DateTime selectedDate = DateTime.now();
  double? selectedDateWeight;

  @override
  void initState() {
    super.initState();
    loadlist();
    fetchWeightData();
  }

  void loadlist() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() =>
        selectedIngredients = prefs.getStringList('selectedIngredients') ?? []);
  }

  List<WeightEntry> weightEntries = [];
  List<WeightGraphData> graphData = [];

  void fetchWeightData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('weight')
          .where('userID', isEqualTo: DatabaseService().userId)
          .where('date', isGreaterThanOrEqualTo: selectedDate.toUtc())
          .where('date',
              isLessThan: selectedDate.add(const Duration(days: 1)).toUtc())
          .get();

      final data = snapshot.docs.map((doc) {
        final timestamp = (doc['date'] as Timestamp).toDate();
        final weight = double.parse(doc['weight']);
        return WeightEntry(date: timestamp, weight: weight);
      }).toList();

      setState(() {
        weightEntries = data;
        selectedDateWeight = getWeightForDate(selectedDate);
      });
    } catch (e) {
      print('Error fetching weight data: $e');
    }
  }

  void fetchIngredientsData(DateTime selectedDate) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('DailyIngredients')
          .where('userID', isEqualTo: DatabaseService().userId)
          .where('date', isEqualTo: selectedDate.toString().split(' ')[0])
          .get();

      final List<String> ingredients = snapshot.docs.map((doc) {
        return doc['ingredient'].toString();
      }).toList();

      setState(() {
        selectedIngredients = ingredients;
      });
    } catch (e) {
      print('Error fetching ingredients data: $e');
    }
  }

  double? getWeightForDate(DateTime date) {
    final entry = weightEntries.firstWhere(
      (entry) =>
          entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day,
      orElse: () => WeightEntry(date: date, weight: 0),
    );
    return entry.weight != 0 ? entry.weight : null;
  }

  void onDateChanged(DateTime date) {
    setState(() {
      selectedDate = date;
      fetchWeightData();
      fetchIngredientsData(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logi.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Card(
                        child: Container(
                          width: 381,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                height: 58,
                                width: 78,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                'Hello, Name',
                                style: TextStyle(
                                  color: Color.fromRGBO(30, 30, 30, 1),
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'Poppins-n',
                                  fontSize: 20,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const ImageIcon(
                                  AssetImage('assets/settings_icon.png'),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsScreen()));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Container(
                            alignment: Alignment.center,
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CalendarDatePicker(
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2026),
                              onDateChanged: onDateChanged,
                              currentDate: DateTime.now(),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 17, right: 17),
                        child: Container(
                          alignment: Alignment.center,
                          height: 230,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 20, bottom: 20),
                                child: Text(
                                  'Statistics',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 19,
                                    color: Color.fromRGBO(59, 59, 59, 1),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text(
                                        'Weight:',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 19,
                                          color: Color.fromRGBO(59, 59, 59, 1),
                                        ),
                                      ),
                                      Text(
                                        selectedDateWeight != null
                                            ? '${selectedDateWeight!.toStringAsFixed(1)} kg'
                                            : 'No data',
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontFamily: 'Poppins',
                                          color:
                                              Color.fromRGBO(255, 199, 199, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [],
                                  ),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        'Daily steps:',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 19,
                                          color: Color.fromRGBO(59, 59, 59, 1),
                                        ),
                                      ),
                                      Text(
                                        '10,000',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontFamily: 'Poppins',
                                          color:
                                              Color.fromRGBO(255, 199, 199, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        'Water intake:',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 19,
                                          color: Color.fromRGBO(59, 59, 59, 1),
                                        ),
                                      ),
                                      Text(
                                        '10 cups',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontFamily: 'Poppins',
                                          color:
                                              Color.fromRGBO(255, 199, 199, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      // Container(
                      //   height: 300,
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   child: LineChartWidget(graphData),
                      // ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 17, right: 17),
                        child: Container(
                          alignment: Alignment.center,
                          height: 350,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Ingredients that you consumed',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 19,
                                    color: Color.fromRGBO(59, 59, 59, 1),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: selectedIngredients.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, right: 30, top: 20),
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(11),
                                          color: Colors.white,
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15.0),
                                          child: Text(
                                            selectedIngredients[index],
                                            style: const TextStyle(
                                              color: Color.fromRGBO(
                                                  135, 133, 162, 1),
                                              fontFamily: 'Poppins',
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    IconButton(
                      color: const Color.fromRGBO(255, 199, 199, 1),
                      icon: const ImageIcon(
                        AssetImage('assets/diary.png'),
                      ),
                      iconSize: 28,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DiaryPage()));
                      },
                    ),
                    const Text(
                      "Diary",
                      style: TextStyle(
                        color: Color.fromRGBO(255, 199, 199, 1),
                        fontWeight: FontWeight.w100,
                        fontFamily: 'Poppins',
                        fontSize: 15,
                      ),
                    ),
                  ]),
                  Column(
                    children: [
                      IconButton(
                          color: const Color.fromRGBO(135, 133, 162, 1),
                          icon: const ImageIcon(
                            AssetImage('assets/home.png'),
                          ),
                          iconSize: 28,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainScreen(),
                                ));
                          }),
                      const Text(
                        "Home",
                        style: TextStyle(
                          color: Color.fromRGBO(135, 133, 162, 1),
                          fontWeight: FontWeight.w100,
                          fontFamily: 'Poppins',
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Column(children: [
                    IconButton(
                      color: const Color.fromRGBO(135, 133, 162, 1),
                      icon: const ImageIcon(
                        AssetImage('assets/food.png'),
                      ),
                      iconSize: 28,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FoodPage()));
                      },
                    ),
                    const Text(
                      "Food",
                      style: TextStyle(
                        color: Color.fromRGBO(135, 133, 162, 1),
                        fontWeight: FontWeight.w100,
                        fontFamily: 'Poppins',
                        fontSize: 15,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({required this.date, required this.weight});
}
