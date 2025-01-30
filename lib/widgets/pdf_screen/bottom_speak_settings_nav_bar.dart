import 'package:flutter/material.dart';

class PdfScreenSpeakSettingsBottomNavBar extends StatefulWidget {
  const PdfScreenSpeakSettingsBottomNavBar({
    super.key,
    required this.onClose,
    required this.onNextSentence,
    required this.onPrevSentence,
  });

  final void Function(bool val) onClose;
  final void Function() onNextSentence;
  final void Function() onPrevSentence;

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
          onPressed: () {
            widget.onClose(false);
          },
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {},
        ),
        Text("page"),
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: widget.onPrevSentence,
        ),
        IconButton(
          icon: Icon(Icons.arrow_right),
          onPressed: widget.onNextSentence,
        ),
      ],
    );
  }
}
