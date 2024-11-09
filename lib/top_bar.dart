import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool displayBackButton;

  const TopBar(this.title, {super.key, this.displayBackButton = true});

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: displayBackButton,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title),
      toolbarHeight: preferredSize.height,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
