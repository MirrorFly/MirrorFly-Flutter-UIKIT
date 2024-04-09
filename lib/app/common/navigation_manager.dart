import 'package:flutter/material.dart';

class NavigationManager {
  final List<String> routeHistory = [];
  String? currentRoute;

  void navigateTo({required BuildContext context, required Widget pageToNavigate, required String routeName, Function()? onNavigateComplete}) {
    // Navigate to the new route (simulated navigation)
    currentRoute = routeName;
    debugPrint("Navigating to $routeName");
    // Push the current route to the history before navigating
    if (currentRoute != null) {
      debugPrint("Adding the current route");
      routeHistory.add(currentRoute!);
    }else{
      debugPrint("current route is null not adding the history");
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => pageToNavigate,
    )).then((_) {
      // Execute the callback when navigation is complete if provided
      onNavigateComplete?.call();
    });
  }

  void navigatePushReplacement({required BuildContext context, required Widget pageToNavigate, required String routeName, Function()? onNavigateComplete}) {
    // Navigate to the new route (simulated navigation)
    currentRoute = routeName;
    debugPrint("Navigating to $routeName");
    // Push the current route to the history before navigating
    if (currentRoute != null) {
      debugPrint("Adding the current route");
      routeHistory.removeLast();
      routeHistory.add(currentRoute!);
    } else {
      debugPrint("current route is null not adding the history");
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => pageToNavigate,
      ),
    ).then((value) => onNavigateComplete?.call());
  }
  void navigatePushRemoveUntil({required BuildContext context, required Widget pageToNavigate, required String routeName, Function()? onNavigateComplete}) {
    // Navigate to the new route (simulated navigation)
    currentRoute = routeName;
    debugPrint("Navigating to $routeName");
    // Push the current route to the history before navigating
    if (currentRoute != null) {
      debugPrint("Adding the current route");
      routeHistory.add(currentRoute!);
    } else {
      debugPrint("current route is null not adding the history");
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => pageToNavigate,
      ), (route) => false,
    ).then((value) => onNavigateComplete?.call());
  }


  void navigateBack({required BuildContext context}) {
    if (routeHistory.isNotEmpty) {
      currentRoute = routeHistory.removeLast();
      debugPrint("Navigating back to $currentRoute");
      Navigator.pop(context);
    } else {
      debugPrint("Cannot navigate back; history is empty.");
    }
  }

  String getCurrentRoute(){
    if (routeHistory.isNotEmpty) {
      String lastContent = routeHistory.last;
      debugPrint("Last Content: $lastContent");
      return lastContent;
    } else {
      // Handle the case when 'routeHistory' is empty
      debugPrint("routeHistory is empty");
      return "";
    }
  }

  bool hasPrevRoute(){
    if(routeHistory.isNotEmpty){
      return true;
    }
    return false;
  }
}

