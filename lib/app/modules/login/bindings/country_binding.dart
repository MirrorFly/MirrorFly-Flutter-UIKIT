import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/login/controllers/country_controller.dart';


class CountryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CountryController>(
      () => CountryController(),
    );
  }
}
