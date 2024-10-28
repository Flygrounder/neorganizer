import 'package:flutter/material.dart';
import 'package:neorganizer/bottom_bar.dart';
import 'package:neorganizer/top_bar.dart';

class SettingsRoute extends StatelessWidget {
  const SettingsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopBar('Настройки'),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Здесь будут ваши настройки'),
        ],
      )),
      bottomNavigationBar: BottomBar(BottomBarTab.settings),
    );
  }
}
