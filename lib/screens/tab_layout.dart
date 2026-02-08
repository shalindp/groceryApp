import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/scalfold.dart';

class TabLayout extends StatelessWidget {
  final StatefulNavigationShell _navigationShell;
  const TabLayout(this._navigationShell, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: CustomScaffold(
        body: _navigationShell,
        onTap: _navigationShell.goBranch,
        backgroundColor: Colors.white,
      ),
    );
  }
}