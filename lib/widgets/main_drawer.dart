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
            padding: const EdgeInsets.all(2),
              child:
                  Row(
                    children: [
                      Icon(
                          Icons.book,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary
                      ),
                      const SizedBox(width: 10),
                      Text('Reader', style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      )),
                    ],
                  )
          ),
          ListTile(
            leading: Icon(
              Icons.cached,
              size: 26,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Currently on the read',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14
              ),
            ),
            onTap: () {
              onSelectScreen('current_doc_list');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.list,
              size: 26,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Books & Documents',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14
              ),
            ),
            onTap: () {
              onSelectScreen('all_doc_list');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.star,
              size: 26,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Favorites',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14
              ),
            ),
            onTap: () {
              onSelectScreen('favorites');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.access_time_outlined,
              size: 26,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Read wish list',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14
              ),
            ),
            onTap: () {
              onSelectScreen('wish_doc_lis');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.check,
              size: 26,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Read',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14
              ),
            ),
            onTap: () {
              onSelectScreen('read_doc_lis');
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
                  fontSize: 14
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