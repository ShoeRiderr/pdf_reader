import 'package:flutter/material.dart';

class MultilineAppBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const MultilineAppBar({super.key, required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    double availableWidth = mediaQuery.size.width - 160;
    availableWidth -= 32 * actions.length;
      availableWidth -= 32;
      return SliverAppBar(
      expandedHeight: 120.0,
      forceElevated: true,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        title: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: availableWidth,
          ),
          child: Text(title, textScaleFactor: .8,),
        ),
      ),
    );
  }
}