import 'package:flutter/material.dart';

class CustomCircleIconButton extends StatelessWidget {
  IconData icon;
  Function() onTap;
  CustomCircleIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(icon, color: Colors.white, size: 16)),
      ),
    );
  }
}
