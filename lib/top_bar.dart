import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool displayBackButton;
  final Widget? leading;
  final List<Widget>? actions;

  const TopBar(this.title,
      {super.key, this.displayBackButton = true, this.leading, this.actions});

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: displayBackButton,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title),
      leading: leading,
      actions: actions,
      toolbarHeight: preferredSize.height,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
