import 'package:get/get.dart';

import '../chat/bindings/chat_binding.dart';
import '../chat/bindings/location_binding.dart';
import '../chat/views/chat_view.dart';
import '../chat/views/location_sent_view.dart';
import '../gallery_picker/bindings/gallery_picker_binding.dart';
import '../gallery_picker/views/gallery_picker_view.dart';
import '../media_preview/bindings/media_preview_binding.dart';
import '../media_preview/views/media_preview_view.dart';

// import '../modules/dashboard/bindings/recent_search_binding.dart';
// import '../modules/dashboard/views/recent_search_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.dashboard;
  static const profile = Routes.profile;
  static const dashboard = Routes.dashboard;
  static const contactSync = Routes.contactSync;
  static const chat = Routes.chat;
  static const adminBlocked = Routes.adminBlocked;

  static final routes = [

    GetPage(
      name: _Paths.chat,
      page: () => ChatView(onBack: (){},),
      // arguments: Profile(),
      binding: ChatBinding(),
    ),
    /*GetPage(
      name: _Paths.forwardChat,
      page: () => const ForwardChatView(),
      binding: ForwardChatBinding(),
    ),
    GetPage(
      name: _Paths.chatSearch,
      page: () => const ChatSearchView(),
    ),*/
    GetPage(
      name: _Paths.locationSent,
      page: () => const LocationSentView(),
      binding: LocationBinding(),
    ),
    /*GetPage(
      name: _Paths.imagePreview,
      page: () => const ImagePreviewView(),
      binding: ImagePreviewBinding(),
    ),*/
    /*GetPage(
      name: _Paths.videoPreview,
      page: () => const VideoPreviewView(),
      binding: VideoPreviewBinding(),
    ),
    GetPage(
      name: _Paths.videoPlay,
      page: () => const VideoPlayerView(),
      binding: VideoPlayBinding(),
    ),*//*GetPage(
      name: _Paths.videoPreview,
      page: () => const VideoPreviewView(),
      binding: VideoPreviewBinding(),
    ),
    GetPage(
      name: _Paths.videoPlay,
      page: () => const VideoPlayerView(),
      binding: VideoPlayBinding(),
    ),
    GetPage(
      name: _Paths.imageView,
      page: () => const ImageViewView(),
      binding: ImageViewBinding(),
    ),*/
    /*GetPage(
      name: _Paths.localContact,
      page: () => const LocalContactView(),
      binding: LocalContactBinding(),
    ),*/
    /*GetPage(
      name: _Paths.previewContact,
      page: () => const PreviewContactView(),
      binding: PreviewContactBinding(),
    ),*/
    /*GetPage(
      name: _Paths.messageInfo,
      page: () => const MessageInfoView(),
      binding: MessageInfoBinding(),
    ),*/
    /*GetPage(
      name: _Paths.chatInfo,
      page: () => const ChatInfoView(),
      binding: ChatInfoBinding(),
    ),*/
    /*GetPage(
      name: _Paths.cameraPick,
      page: () => const CameraPickView(),
      binding: CameraPickBinding(),
    ),*/
    GetPage(
      name: _Paths.galleryPicker,
      page: () => const GalleryPickerView(),
      binding: GalleryPickerBinding(),
    ),
    GetPage(
      name: _Paths.mediaPreview,
      page: () => const MediaPreviewView(),
      binding: MediaPreviewBinding(),
    ),
    /*GetPage(
      name: _Paths.viewAllMediaPreview,
      page: () => const ViewAllMediaPreviewView(),
      binding: ViewAllMediaPreviewBinding(),
    ),*/
  ];
}
