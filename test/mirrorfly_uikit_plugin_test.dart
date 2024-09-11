import 'package:flutter_test/flutter_test.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit_plugin.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit_plugin_platform_interface.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMirrorflyUikitPluginPlatform
    with MockPlatformInterfaceMixin
    implements MirrorflyUikitPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MirrorflyUikitPluginPlatform initialPlatform =
      MirrorflyUikitPluginPlatform.instance;

  test('$MethodChannelMirrorflyUikitPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMirrorflyUikitPlugin>());
  });

  test('getPlatformVersion', () async {
    MockMirrorflyUikitPluginPlatform fakePlatform =
        MockMirrorflyUikitPluginPlatform();
    MirrorflyUikitPluginPlatform.instance = fakePlatform;

    expect(await MirrorflyUikit.instance.getPlatformVersion(), '42');
  });
}
