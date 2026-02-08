import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';

import '../navigation/router-map.dart';

class CustomScaffold extends HookWidget {
  final Widget body;
  final Color? backgroundColor;
  final void Function(int index) onTap;

  const CustomScaffold({super.key, required this.body, required this.backgroundColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // final uiService = GetIt.I<UiService>();
    //
    // var topBar = useExistingSignal(uiService.topBar);
    // var isBottomNavbarVisible = useExistingSignal(
    //   uiService.isBottomNavbarVisible,
    // );
    //
    // var getBottomNavBar = useCallback(() {
    //   if (isBottomNavbarVisible.value) {
    //     return AppBottomNavBar(onTap: onTap);
    //   }
    //
    //   return null;
    // }, []);

    // var getTopBar = useCallback((){
    //   var activeRoute = getActiveRoute(context);
    //   var isActiveRouteTopBarWhitelisted = topBarWhitelist.any((c)=>c == activeRoute);
    //   if(!isActiveRouteTopBarWhitelisted){
    //     return null;
    //   }
    //
    //   return topBar.value;
    // },[]);

    final media = MediaQuery.of(context);
    final padding = media.padding;

    return Scaffold(
      body: Padding(
          padding: EdgeInsets.only(top: padding.top, bottom: padding.bottom, left: padding.left, right: padding.right),
          child: body),
      backgroundColor: backgroundColor,
      // appBar: getTopBar(),
      bottomNavigationBar: Container(
        height: 48,
      ),
      extendBody: true,
    );
  }
}