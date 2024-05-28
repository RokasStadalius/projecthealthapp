import 'package:flutter/material.dart';
import 'package:projecthealthapp/models/Edamam.dart';
import 'package:projecthealthapp/presentation/screens/recipe_detail_screen.dart';

class RecipeCard extends StatelessWidget {
  final EdamamRecipeModel recipe;

  RecipeCard({required this.recipe});

  void saveRecipe(BuildContext context, String recipeName) {
    // Implement your saving logic here
    // For example, you can show a snackbar message for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$recipeName logged into the diary!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              child: Image.network(
                recipe.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 150,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => saveRecipe(context, recipe.title),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time),
                      SizedBox(width: 4),
                      Text('${recipe.cookingTime} min'),
                      SizedBox(width: 16),
                      // Add more icons and data as needed
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
