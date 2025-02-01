import 'package:flutter/material.dart';

class PdfScreenSpeakSettingsBottomNavBar extends StatefulWidget {
  const PdfScreenSpeakSettingsBottomNavBar({
    super.key,
    required this.onClose,
    required this.onNextSentence,
    required this.onPrevSentence,
    required this.isStopped,
    required this.toggleOnReadingOutLoud,
  });

  final void Function(bool val) onClose;
  final void Function() onNextSentence;
  final void Function() onPrevSentence;

  // speak variables
  final bool isStopped;
  final void Function() toggleOnReadingOutLoud;

  @override
  State<StatefulWidget> createState() {
    return PdfScreenBottomNavBarState();
  }
}

class PdfScreenBottomNavBarState
    extends State<PdfScreenSpeakSettingsBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              mini: true,
              heroTag: 'play_stop_button',
              onPressed: widget.toggleOnReadingOutLoud,
              tooltip: widget.isStopped ? 'Play' : 'Stop',
              child: Icon(
                widget.isStopped ? Icons.play_arrow : Icons.stop,
              ),
            ),
          ],
        ),
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: double.infinity,
          child: Row(
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
          ),
        ),
      ],
    );
  }
}
