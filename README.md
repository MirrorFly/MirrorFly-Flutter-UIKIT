# mirrorfly_uikit_plugin

[![Platform](https://img.shields.io/badge/platform-flutter-blue)](https://flutter.dev/)
[![Language](https://img.shields.io/badge/language-dart-blue)](https://dart.dev/)

## Table of contents

1. [Introduction](#Introduction)
1. [Requirements](#requirements)
1. [Integration](#Integration)
1. [Getting help](#getting-help)

## Introduction

Mirrorfly Flutter UIKit Plugin is a set of prebuilt UI Widgets that allows you to easily integrate an in-app chat with all the essential messaging features. Our development kit includes light and dark themes, text fonts, colors and more. You can customize these components to create an interactive messaging unique interface.

## Requirements

The minimum requirements for Flutter are:

- Visual Studio Code or Android Studio
- Dart 2.19.1 or above
- Flutter 2.0.0 or higher

The requirements for Android are:
- Android Lollipop 5.0 (API Level 21) or above
- Java 7 or higher
- Gradle 4.1.0 or higher

The minimum requirements for Chat SDK for iOS

- iOS 12.1 or later

### Step 1: Let's integrate Plugin for Flutter

Our Mirrorfly UIKit Plugin lets you initialize and configure the chat easily. With the server-side, Our solution ensures the most reliable infra-management services for the chat within the app. Furthermore, we will let you know how to install the chat Plugin in your app for a better in-app chat experience.

### Plugin License Key
Follow the below steps to get your license key:

1. Sign up into [MirrorFly Console page](https://console.mirrorfly.com/register) for free MirrorFly account, If you already have a MirrorFly account, sign into your account
2. Once you’re in! You get access to your MirrorFly account ‘Overview page’ where you can find a license key for further integration process
3. Copy the license key from the ‘Application info’ section


### Step 2: Install packages

Installing the Mirrorfly UIKit Plugin is a simple process. Follow the steps mentioned below.

### Create Android dependency

- Add the following to your root `build.gradle` file in your Android folder.

```gradle
   allprojects {
    repositories {
        google()
        mavenCentral()
        jcenter()
        maven {
            url "https://repo.mirrorfly.com/release"
        }
    }
  }
```

### Create iOS dependency
 - Check and Add the following code at end of your `ios/Podfile`

```dart
post_install do |installer|
    installer.aggregate_targets.each do |target|
        target.xcconfigs.each do |variant, xcconfig|
        xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
        IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
        end
    end
    
    installer.pods_project.targets.each do |target|
        flutter_additional_ios_build_settings(target)
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.1'
            config.build_settings['ENABLE_BITCODE'] = 'NO'
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = 'arm64'
            
                shell_script_path = "Pods/Target Support Files/#{target.name}/#{target.name}-frameworks.sh"
                if File::exist?(shell_script_path)
                    shell_script_input_lines = File.readlines(shell_script_path)
                    shell_script_output_lines = shell_script_input_lines.map { |line| line.sub("source=\"$(readlink \"${source}\")\"", "source=\"$(readlink -f \"${source}\")\"") }
                    File.open(shell_script_path, 'w') do |f|
                        shell_script_output_lines.each do |line|
                          f.write line
                        end
                    end
                end
            end
    end
end
```
 - Now, enable all the below mentioned capabilities into your project from `Xcode`.

```dart
Goto Project -> Target -> Signing & Capabilities -> Click `+ Capability` at the top left corner -> Search for `App groups` and add the `App group capability`
```

> **Note**: The App Group Must be same as `iOSContainerId` in json config file. [See Integration Step 2](#Integration).

![ScreenShot](https://www.mirrorfly.com/docs/assets/images/AppGroups-c9933d95df192665e1389f19ece4fd94.png)

### Flutter
 - Add following dependency in `pubspec.yaml`.

```yaml
dependencies:
  mirrorfly_uikit_plugin: ^2.0.1-beta
```

- Run `flutter pub get` command in your project directory.

### Step 3: Use the Mirrorfly UIKit Plugin in your App

You can use all classes and methods just with the one import statement as shown below.

```dart
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit';
```

### Integration

In order to use the features of Mirrorfly UIKit Plugin for Flutter, you should initiate the `MirrorflyUikit` instance through user authentication with Mirrorfly server. This instance communicates and interacts with the server based on an authenticated user account, allowing the client app to use the Mirrorfly Plugin's features.

Here are the steps to integrate the Mirrorfly UIkit Plugin:

### Step 1: Initialize the Mirrorfly UIKit Plugin

To initialize the plugin, place the below code in your `main.dart` file inside `main` function before `runApp()`.

```dart
final navigatorKey = GlobalKey<NavigatorState>();
 void main() {
  WidgetsFlutterBinding.ensureInitialized();
  await MirrorflyUikit.instance.initUIKIT(
      licenseKey: 'Your_Mirrorfly_Licence_Key',
      googleMapKey: 'Your_Google_Map_Key_for_location_messages',
      iOSContainerID: 'Your_iOS_app_Container_id',
      navigatorKey: navigatorKey,
      enableLocalNotification: true);
  runApp(const MyApp());
}
```

### Step 2: Add Configuration json file

**Notice:** The previous method of placing the `mirrorfly_config.json` file under the `assets` folder (`assets/mirrorfly_config.json`) has been removed. The configuration file setup has been moved to a new method.

### New Method:

You can now add inline styles and themes for the UI pages in the UIKIT plugin. The `AppStyleConfig` class is used to set the styles for the UIKIT pages.

### To set the Dashboard page style:
```dart
AppStyleConfig.setDashboardStyle(const DashBoardPageStyle(tabItemStyle: TabItemStyle(textStyle: TextStyle(fontStyle: FontStyle.italic))));
```

### To set the Chat page style:
```dart
AppStyleConfig.setChatPageStyle(const ChatPageStyle(messageTypingAreaStyle: MessageTypingAreaStyle(sentIconColor: Colors.blue)));
```

> **Info** The above code sample sets the style for the Dashboard and Chat pages. You can add more styles and customizations in the same method using different styling parameters

### Step 3: Login/Register User

Use the below method to register a user in sandbox/Live mode.

> **Info** Unless you log out the session, make a note that should never call the registration method more than once in an application

> **Note**: While registration/login, the below `login` method will accept the `fcmToken` as an optional param and pass it across. `The connection will be established automatically upon completion of login`.

```dart
try {
    var response = await MirrorflyUikit.instance.login(userIdentifier: uniqueId, fcmToken: "Your Google FCM Token");
    debugPrint("register user $response");
    //{'status': true, 'message': 'Register Success};
} catch (e) {
  debugPrint(e.toString());
}
```

### Step 4: Navigate to Chat Dashboard

```dart
Navigator.push(context, MaterialPageRoute(builder: (con)=> const DashboardView(title: "Chats",)));
```

### Local Notification
To enable or disable local notifications, use the `enableLocalNotification` parameter in `MirrorflyUikit.instance.initUIKIT`.

You can achieve handling local notification clicks as follows:

```dart
selectNotificationStream.stream.listen((String? jid) async {
// 'jid' represents the user JID who sent the message.
// You can customize the logic here, or navigate to a Chat page as shown in step 4.
});

```

### Remote Push Notification

To configure remote push notifications, you can set up the `firebase_messaging` package in your app and then send the FCM token through the `registerUser` method.

### Additionally:

- The handleReceivedMessage method is added to receive chat messages from FCM notifications, specifically for Android.
- For iOS, you will need to add a Notification Extension Service and follow the steps provided in the Notification Service class.

```dart
import mirrorfly_plugin
```

```swift
 override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        MirrorFlyNotification().handleNotification(notificationRequest: request, contentHandler: contentHandler, containerID: "containerID", licenseKey: "Your License Key")
        
    }
```

### Step 5: Locale Support

The UIKit Plugin supports multiple languages. You can set the locale for the plugin as shown below:

```dart
 MaterialApp(
    navigatorKey: navigatorKey,
    themeMode: ThemeMode.dark,
    debugShowCheckedModeBanner: false,
    /// CHANGE THE LOCALE TO 'en' TO SEE THE LOCALIZATION IN ENGLISH, 'ar' FOR ARABIC, 'hi' FOR HINDI
    locale: const Locale('en'),
    /// ADD THE SUPPORTED LOCALES TO THE APP
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
    ],
    /// ADD THE NAVIGATION OBSERVER TO THE APP, TO HANDLE THE NAVIGATION EVENTS
    navigatorObservers: [
      MirrorFlyNavigationObserver()
    ],
    /// ADD THE ROUTE GENERATOR TO THE APP, TO HANDLE THE ROUTES
    onGenerateRoute: (settings) {
    switch (settings.name) {
        default:
          return mirrorFlyRoute(settings);
        }
    },
    theme: ThemeData(textTheme: GoogleFonts.latoTextTheme()),
    home: YOUR_HOME_PAGE);
```

### Step 6: To Add Your Locale Support

To add your locale support, you can add the locale file in the `assets/locale` folder. The locale file should be named as `en.json` for English, `ar.json` for Arabic, and so on and add it to the supported locales in the `AppLocalizations` class.

```dart
AppLocalizations.addSupportedLocales(const Locale("ar","UAE"));
```

### Step 7: To Log Out

To log out the user, use the below method:

```dart
MirrorflyUikit.instance.logoutFromUIKIT().then((value) {
    debugPrint("Logout Success");
}).catchError((er) {});
```

## Getting Help

Check out the Official Mirrorfly UIKit [Flutter UIKit docs](https://www.mirrorfly.com/docs/UIKit/flutter/quick-start/)

<br />