import 'package:flutter_test/flutter_test.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit_plugin_method_channel.dart';

void main() {
  MethodChannelMirrorflyUikitPlugin platform =
      MethodChannelMirrorflyUikitPlugin();
  // const MethodChannel channel = MethodChannel('mirrorfly_uikit_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // channel.setMockMethodCallHandler((MethodCall methodCall) async {
    //   return '42';
    // });
  });

  tearDown(() {
    // channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
