import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirrorfly_uikit_plugin/app/extensions/extensions.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit_plugin.dart';
import 'package:tuple/tuple.dart';
import '../common/app_localizations.dart';
import '../model/chat_message_model.dart';
import '../routes/mirrorfly_navigation_observer.dart';
import 'helper.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_style_config.dart';
import '../common/constants.dart';

import 'dart:io';

import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../common/main_controller.dart';
import '../stylesheet/stylesheet.dart';

part 'dialog_utils.dart';
part 'apputils.dart';
part 'media_utils.dart';
part 'nav_utils.dart';
part 'message_utils.dart';
part 'date_utils.dart';
