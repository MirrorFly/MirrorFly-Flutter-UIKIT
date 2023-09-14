import 'package:flutter/widgets.dart';

class RouteObserverProvider extends RouteObserver<PageRoute<dynamic>> {
  static final RouteObserverProvider _instance = RouteObserverProvider._();

  factory RouteObserverProvider() => _instance;

  RouteObserverProvider._();
}
