import 'package:flutter/material.dart';

class PopOutAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color backgroundColor;

  const PopOutAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // The total height of the widget is slightly taller than the circle 
    // to allow the avatar's head/arms to break out of the top bounds.
    return SizedBox(
      width: radius * 2,
      height: (radius * 2) * 1.3,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Background Boundary Circle
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
          ),
          
          // Pop-Out Image (scaled larger and overflowing the container)
          Positioned(
            bottom: 0,
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    width: radius * 2.4, // Wider than the circle bounds
                    height: radius * 2.4, // Taller than the circle bounds
                    fit: BoxFit.contain, // Keeps transparent PNG aspect ratio
                  )
                : Icon(Icons.person, size: radius * 1.2, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
