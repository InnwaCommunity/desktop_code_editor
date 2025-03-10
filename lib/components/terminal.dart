import 'package:flutter/material.dart';

class Terminal extends StatelessWidget {
  const Terminal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: ListView(
        children: [
          Text(
            '> Terminal Output',
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }
}
