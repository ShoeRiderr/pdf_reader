import 'package:flutter/material.dart';

enum Filter {
  autoStart
}

class SearchSettingsScreen extends StatefulWidget {
  const SearchSettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SearchSettingsScreenState();
  }
}

class _SearchSettingsScreenState extends State<SearchSettingsScreen> {
  bool _isAutostart = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, dynamic result) {
              if(didPop) return;
              Navigator.of(context).pop({
                Filter.autoStart: _isAutostart,
              });
            },
            child: Column(
                children: [
                  SwitchListTile(
                    value: _isAutostart,
                    onChanged: (isChecked) {
                      setState(() {
                        _isAutostart = isChecked;
                      });
                    },
                    title: Text(
                        'AutoStart',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                    subtitle: Text(
                      'Search for documents at startup',
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    activeColor: Theme.of(context).colorScheme.tertiary,
                    contentPadding: const EdgeInsets.only(left: 34, right: 22),
                  )
                ]
            )
        ),

    );
  }

}