import 'package:flutter/material.dart';

class HomeHeaderCard extends StatelessWidget {
  final bool isLoggedIn;
  final String username;
  final Function(String) onSearch;
  final VoidCallback onProfileTap;

  const HomeHeaderCard({
    Key? key,
    required this.isLoggedIn,
    required this.username,
    required this.onSearch,
    required this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isLoggedIn ? 'Bienvenue $username !' : 'Bienvenue !',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: onProfileTap,
                  tooltip: isLoggedIn ? 'Profil' : 'Se connecter',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Qu\'est-ce qu\'on va cuisiner aujourd\'hui ?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une recette, un ingrédient…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: onSearch,
            ),
          ],
        ),
      ),
    );
  }
}