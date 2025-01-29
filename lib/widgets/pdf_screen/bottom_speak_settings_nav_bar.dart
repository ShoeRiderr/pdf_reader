import 'package:flutter/material.dart';

class PdfScreenSpeakSettingsBottomNavBar extends StatefulWidget {
  const PdfScreenSpeakSettingsBottomNavBar({super.key});

  @override
  State<StatefulWidget> createState() {
    return PdfScreenBottomNavBarState();
  }
}

class PdfScreenBottomNavBarState
    extends State<PdfScreenSpeakSettingsBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {},
        ),
        Text("page"),
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.arrow_right),
          onPressed: () {},
        ),
      ],
    );
  }
}
