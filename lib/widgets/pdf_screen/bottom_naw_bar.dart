import 'package:flutter/material.dart';

class PdfScreenBottomNavBar extends StatefulWidget {
  const PdfScreenBottomNavBar({super.key});

  @override
  State<StatefulWidget> createState() {
    return PdfScreenBottomNavBarState();
  }
}

class PdfScreenBottomNavBarState extends State<PdfScreenBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: Icon(Icons.menu), onPressed: () {}),
        IconButton(icon: Icon(Icons.search), onPressed: () {}),
      ],
    );
  }
}