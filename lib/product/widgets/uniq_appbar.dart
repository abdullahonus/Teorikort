
import 'package:flutter/material.dart';

class UniqAppbar extends StatelessWidget {
  final double height;
  const UniqAppbar({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/icons/direksiyon.png',
                scale: 1.5,
              ),
              const Text(
                "Driving Exam",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 80.0),
              const Text(
                "Login",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(10.0),
                width: 50.0,
                height: 5.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
