//  ###FLAVOR: web###

import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text("I am the web widget."),
          Image.asset("assets/Camille.png"),
        ],
      ),
    );
  }
}
