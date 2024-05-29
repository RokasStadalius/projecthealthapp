import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecthealthapp/common/auth.dart';
import 'package:projecthealthapp/common/databaseService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projecthealthapp/models/Edamam.dart';
import 'package:projecthealthapp/presentation/screens/diary_page.dart';
import 'package:projecthealthapp/presentation/screens/main_page.dart';
import 'package:projecthealthapp/presentation/screens/settings_screen.dart';
import 'package:projecthealthapp/ui/widgets/LoadingCard.dart';
import 'package:projecthealthapp/ui/widgets/RecipeCard.dart';
import 'dart:math';

class FoodPage extends StatefulWidget {
  const FoodPage({Key? key}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  EdamamApiService api = EdamamApiService();
  List<EdamamRecipeModel> recipes = [];
  List<String> selectedIngredients = [];
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    _fetchRecipes();
    loadList();
    _fetchUserHealthProblems();
    super.initState();
  }

  Future<void> _fetchUserHealthProblems() async {
    final problems = await DatabaseService().getUserHealthProblemsList();
    setState(() {
      userHealthProblems = problems;
    });
  }

  Future<void> _fetchRecipes() async {
    recipes = await api.getRecipes();
    recipes.shuffle(Random());
    setState(() {});
  }

  void loadList() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIngredients = prefs.getStringList('selectedIngredients') ?? [];
    });
  }

  void updateSelectedIngredients(String ingredient) async {
    setState(() {
      if (selectedIngredients.contains(ingredient)) {
        selectedIngredients.remove(ingredient);
        _db.removeIngredientFromFirebase(ingredient);
      } else {
        selectedIngredients.add(ingredient);
        _db.saveIngredientToFirebase(ingredient);
      }
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedIngredients', selectedIngredients);
  }

  List<String> userHealthProblems = [];
  Map<String, List<String>> groupedIngredients = {};

  List<String> getIngredientsFromSingle(String healthProblem) {
    // Mapping health problems to their corresponding food ingredients
    Map<String, List<String>> healthToIngredients = {
      'Overweight, obesity': [
        'Leafy Greens',
        'Berries',
        'Nuts and Seeds',
        'Whole Grains',
        'Legumes'
      ],
      'Type 2 diabetes': [
        'Non-Starchy Vegetables',
        'Fatty Fish',
        'Whole Grains',
        'Berries',
        'Nuts'
      ],
      'Iron deficiency': [
        'Red Meat',
        'Spinach',
        'Lentils',
        'Pumpkin Seeds',
        'Quinoa'
      ],
      'Vitamin D deficiency': [
        'Fatty Fish',
        'Egg Yolks',
        'Fortified Foods',
        'Mushrooms',
        'Cod Liver Oil'
      ],
      'Calcium deficiency': [
        'Dairy Products',
        'Leafy Greens',
        'Almonds',
        'Fortified Plant Milks',
        'Tofu'
      ],
      'Vitamin A deficiency': [
        'Carrots',
        'Sweet Potatoes',
        'Spinach',
        'Bell Peppers',
        'Liver'
      ],
      'Magnesium deficiency': [
        'Dark Chocolate',
        'Avocados',
        'Nuts',
        'Legumes',
        'Whole Grains'
      ],
      'Zinc deficiency': ['Shellfish', 'Meat', 'Seeds', 'Nuts', 'Legumes'],
      'Vitamin C deficiency': [
        'Citrus Fruits',
        'Bell Peppers',
        'Strawberries',
        'Kiwi',
        'Broccoli'
      ],
    };

    // List to hold recommended ingredients
    List<String> recommendedIngredients = [];

    // Loop through each health problem and add corresponding ingredients to the list

    if (healthToIngredients.containsKey(healthProblem)) {
      recommendedIngredients.addAll(healthToIngredients[healthProblem]!);
    }

    // Remove duplicates by converting to a set and back to a list
    recommendedIngredients = recommendedIngredients.toSet().toList();

    return recommendedIngredients;
  }

  List<String> getIngredients(List<String> healthProblems) {
    // Mapping health problems to their corresponding food ingredients
    Map<String, List<String>> healthToIngredients = {
      'Overweight, obesity': [
        'Leafy Greens',
        'Berries',
        'Nuts and Seeds',
        'Whole Grains',
        'Legumes'
      ],
      'Type 2 diabetes': [
        'Non-Starchy Vegetables',
        'Fatty Fish',
        'Whole Grains',
        'Berries',
        'Nuts'
      ],
      'Iron deficiency': [
        'Red Meat',
        'Spinach',
        'Lentils',
        'Pumpkin Seeds',
        'Quinoa'
      ],
      'Vitamin D deficiency': [
        'Fatty Fish',
        'Egg Yolks',
        'Fortified Foods',
        'Mushrooms',
        'Cod Liver Oil'
      ],
      'Calcium deficiency': [
        'Dairy Products',
        'Leafy Greens',
        'Almonds',
        'Fortified Plant Milks',
        'Tofu'
      ],
      'Vitamin A deficiency': [
        'Carrots',
        'Sweet Potatoes',
        'Spinach',
        'Bell Peppers',
        'Liver'
      ],
      'Magnesium deficiency': [
        'Dark Chocolate',
        'Avocados',
        'Nuts',
        'Legumes',
        'Whole Grains'
      ],
      'Zinc deficiency': ['Shellfish', 'Meat', 'Seeds', 'Nuts', 'Legumes'],
      'Vitamin C deficiency': [
        'Citrus Fruits',
        'Bell Peppers',
        'Strawberries',
        'Kiwi',
        'Broccoli'
      ],
    };

    // List to hold recommended ingredients
    List<String> recommendedIngredients = [];

    // Loop through each health problem and add corresponding ingredients to the list
    for (String problem in healthProblems) {
      if (healthToIngredients.containsKey(problem)) {
        recommendedIngredients.addAll(healthToIngredients[problem]!);
      }
    }

    // Remove duplicates by converting to a set and back to a list
    recommendedIngredients = recommendedIngredients.toSet().toList();

    return recommendedIngredients;
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
                              const SizedBox(width: 5),
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
                                          const SettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/sakutes.png',
                                      height: 70,
                                      width: 70,
                                    ),
                                    const SizedBox(width: 18),
                                    const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Food suggestions',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins-n',
                                            fontSize: 19,
                                            color:
                                                Color.fromRGBO(59, 59, 59, 1),
                                          ),
                                        ),
                                        Text(
                                          'Based on your preferences',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins-n',
                                            fontSize: 13,
                                            color: Color.fromRGBO(
                                                153, 153, 153, 1),
                                          ),
                                        ),
                                        Text(
                                          'get 3 daily recipes!',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins-n',
                                            fontSize: 13,
                                            color: Color.fromRGBO(
                                                153, 153, 153, 1),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: ListView.builder(
                                  itemCount: 3,
                                  itemBuilder: (context, index) {
                                    if (index < recipes.length) {
                                      return RecipeCard(recipe: recipes[index]);
                                    } else {
                                      return LoadingCard();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 30),
                              Container(
                                width: 500,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Ingredient suggestions',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins-n',
                                        fontSize: 19,
                                        color: Color.fromRGBO(59, 59, 59, 1),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'If you consumed these ingredients click on them',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins-n',
                                        fontSize: 13,
                                        color: Color.fromRGBO(153, 153, 153, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              for (String problem in userHealthProblems)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Container(
                                      width: 500,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Ingredient suggestions for $problem',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins-n',
                                                fontSize: 19,
                                                color: Color.fromRGBO(
                                                    59, 59, 59, 1),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          for (String ingredient
                                              in getIngredientsFromSingle(
                                                  problem))
                                            ingredientButton(ingredient),
                                          const SizedBox(
                                            height: 10,
                                          )
                                        ],
                                      ),
                                    ),
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
                  bottomNavigationItem(
                    icon: 'assets/diary.png',
                    label: 'Diary',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DiaryPage()),
                      );
                    },
                  ),
                  bottomNavigationItem(
                    icon: 'assets/home.png',
                    label: 'Home',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainScreen()),
                      );
                    },
                  ),
                  bottomNavigationItem(
                    icon: 'assets/food.png',
                    label: 'Food',
                    onPressed: () => print('home pressed'),
                    selected: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ingredientButton(String ingredient) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 50,
        width: 300,
        child: ElevatedButton(
          onPressed: () {
            updateSelectedIngredients(ingredient);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              selectedIngredients.contains(ingredient)
                  ? const Color.fromRGBO(255, 199, 199, 1)
                  : Colors.white,
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
              selectedIngredients.contains(ingredient)
                  ? Colors.white
                  : const Color.fromRGBO(135, 133, 162, 1),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: Text(
            ingredient,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomNavigationItem(
      {required String icon,
      required String label,
      required VoidCallback onPressed,
      bool selected = false}) {
    return Column(
      children: [
        IconButton(
          color: selected
              ? const Color.fromRGBO(255, 199, 199, 1)
              : const Color.fromRGBO(135, 133, 162, 1),
          icon: ImageIcon(AssetImage(icon)),
          iconSize: 28,
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color.fromRGBO(255, 199, 199, 1)
                : const Color.fromRGBO(135, 133, 162, 1),
            fontWeight: FontWeight.w100,
            fontFamily: 'Poppins',
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
