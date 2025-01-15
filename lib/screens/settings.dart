import 'package:flutter/material.dart';
import 'package:pdf_reader/screens/search_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.selectedFilters,
    required this.onSelectFilters
  });

  final Map<Filter, bool> selectedFilters;
  final void Function(Map<Filter, bool>? filters) onSelectFilters;

@override
  State<StatefulWidget> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _setScreen() async {
    final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (ctx) => SearchSettingsScreen(),
        )
    );

    widget.onSelectFilters(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
        body: Column(
          children: [
            ListTile(title: Text("Search settings"), onTap: () {
              _setScreen();
            },),
          ]
        )
    );
  }
}