import 'package:flutter/material.dart';
import 'package:neorganizer/note_list.dart';
import 'package:neorganizer/settings.dart';

enum BottomBarTab {
  notes,
  settings,
}

class BottomBar extends StatelessWidget {
  final BottomBarTab currentTab;

  const BottomBar(this.currentTab, {super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Заметки'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Настройки')
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: BottomBarTab.values.indexOf(currentTab),
        onTap: (current) {
          var selectedTab = BottomBarTab.values[current];
          if (selectedTab == currentTab) {
            return;
          }

          Widget route;
          switch (selectedTab) {
            case BottomBarTab.notes:
              route = NoteListRoute();
              break;
            case BottomBarTab.settings:
              route = const SettingsRoute();
              break;
          }
          Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation1,
                      Animation<double> animation2) =>
                  route,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero));
        });
  }
}
