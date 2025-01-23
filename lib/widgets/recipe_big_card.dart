import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scrontch_flutter/widgets/recipe_length.dart';
import 'package:scrontch_flutter/widgets/star_rating.dart';
import 'package:scrontch_flutter/widgets/unselectable_chip.dart';
import 'package:scrontch_flutter/widgets/unselectable_chip_icon.dart';

import 'badge_count.dart';

class RecipeBigCard extends StatelessWidget {
  final String recipeName;
  final String? imageRes;
  final String chipLabel1;
  final String chipLabel2;
  final String chipLabel3;
  final String chipIcon1;
  final String chipIcon2;
  final String recipeLength;
  final int userCount;
  final double rating;
  final int badgeCount;
  final VoidCallback onTap;

  const RecipeBigCard({
    Key? key,
    required this.recipeName,
    this.imageRes,
    required this.chipLabel1,
    required this.chipLabel2,
    required this.chipLabel3,
    required this.chipIcon1,
    required this.chipIcon2,
    required this.recipeLength,
    required this.userCount,
    required this.rating,
    required this.badgeCount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: double.infinity,
                height: 240,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: imageRes != null
                              ? CachedNetworkImage(
                            imageUrl: imageRes!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            height: 160,
                            color: Colors.grey[300],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black.withOpacity(0.5),
                            child: Text(
                              recipeName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Rating and Length Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StarRating(
                                rating: rating,
                                userCount: userCount,
                              ),
                              RecipeLength(length: recipeLength),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Chips Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              UnselectableChipIcon(
                                label: chipLabel1,
                                iconUrl: chipIcon1,
                              ),
                              UnselectableChipIcon(
                                label: chipLabel2,
                                iconUrl: chipIcon2,
                              ),
                              UnselectableChip(label: chipLabel3),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Badge
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: 8,
              child: BadgeCount(count: badgeCount),
            ),
        ],
      ),
    );
  }
}