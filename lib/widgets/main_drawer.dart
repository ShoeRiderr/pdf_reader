import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key, required this.onSelectScreen});

  final void Function(String identifier) onSelectScreen;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(10),
              child:
                  Row(
                    children: [
                      Icon(
                          Icons.book,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary
                      ),
                      const SizedBox(width: 18),
                      Text('Reader', style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      )),
                    ],
                  )
          ),
          ListTile(
            leading: Icon(
              Icons.list,
              size: 26,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text('List',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24
              ),
            ),
            onTap: () {
              onSelectScreen('doc_list');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.download,
              size: 26,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Download',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24
              ),
            ),
            onTap: () {
              onSelectScreen('download');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 26,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24
              ),
            ),
            onTap: () {
              onSelectScreen('settings');
            },
          )
        ],
      ),
    );
  }

}