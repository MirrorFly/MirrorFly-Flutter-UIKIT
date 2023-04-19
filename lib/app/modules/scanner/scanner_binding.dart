import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/scanner/scanner_controller.dart';

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScannerController());
  }
}