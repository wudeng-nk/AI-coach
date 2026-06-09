import 'package:flutter/material.dart';

class SquirrelAvatar extends StatelessWidget {
  final double size;
  const SquirrelAvatar({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/squirrel_avatar.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
