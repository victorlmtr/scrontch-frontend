import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int userCount;
  final double starSize;
  final Color filledColor;
  final Color unfilledColor;

  const StarRating({
    super.key, // Changed from Key? key to super.key
    required this.rating,
    required this.userCount,
    this.starSize = 24,
    this.filledColor = Colors.amber,
    this.unfilledColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      children: [
        ...List.generate(
          fullStars,
              (index) => Icon(Icons.star, size: starSize, color: filledColor),
        ),
        if (hasHalfStar)
          Icon(Icons.star_half, size: starSize, color: filledColor),
        ...List.generate(
          emptyStars,
              (index) => Icon(Icons.star_border, size: starSize, color: unfilledColor),
        ),
        const SizedBox(width: 4),
        Text(
          '($userCount)',
          style: TextStyle(color: unfilledColor),
        ),
      ],
    );
  }
}