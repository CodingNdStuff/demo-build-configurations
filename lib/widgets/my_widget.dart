//###FLAVOR: DEFAULT###
//YOU CAN LEAVE THIS ONE EMPTY.
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text("I am the default widget."),
    );
  }
}
