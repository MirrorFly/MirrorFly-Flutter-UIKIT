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
            url "https://repo.mirrorfly.com/snapshot/"
        }
    }
  }
```

### Create iOS dependency
 - Check and Add the following code at end of your `ios/Podfile`

```dart
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.1'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"      
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
  mirrorfly_uikit_plugin: ^0.0.9
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
 void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MirrorflyUikit.instance.initUIKIT(  baseUrl: 'YOUR_BASE_URL',
      licenseKey: 'Your_Mirrorfly_Licence_Key',
      googleMapKey: 'Your_Google_Map_Key_for_location_messages',
      iOSContainerID: 'Your_iOS_app_Container_id');
  runApp(const MyApp());
}
```

### Step 2: Add Configuration json file

create `mirrorfly_config.json` json file with configuration details then add the json file into under your `assets` folder(`assets/mirrorfly_config.json`).

> **Info** Download config json file from [Flutter UIKit docs](https://www.mirrorfly.com/docs/UIKit/flutter/quick-start/)

### Step 3: Registration

Use the below method to register a user in sandbox Live mode.

> **Info** Unless you log out the session, make a note that should never call the registration method more than once in an application

> **Note**: While registration, the below `registerUser` method will accept the `FCM_TOKEN` as an optional param and pass it across. `The connection will be established automatically upon completion of registration and not required for seperate login`.

```dart
try {
    var response = await MirrorflyUikit.registerUser(uniqueId);
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

## Getting Help

Check out the Official Mirrorfly UIKit [Flutter UIKit docs](https://www.mirrorfly.com/docs/UIKit/flutter/quick-start/)

<br />