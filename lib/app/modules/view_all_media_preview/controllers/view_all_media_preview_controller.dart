
import 'package:flutter/material.dart';
import '../../../models.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ViewAllMediaPreviewController extends GetxController {


  var previewMediaList = List<ChatMessageModel>.empty(growable: true).obs;
  var index = 0.obs;
  late PageController pageViewController;
  var title = "Sent Media".obs;

  /*@override
  void onInit() {
    super.onInit();*/
  void init(List<ChatMessageModel> images, int index){
    previewMediaList.addAll(images);
    this.index(index);
    pageViewController = PageController(initialPage: this.index.value, keepPage: false);
  }

  shareMedia() {
    var mediaItem = previewMediaList.elementAt(index.value).mediaChatMessage!.mediaLocalStoragePath;
    Share.shareXFiles([XFile(mediaItem)]);
  }

  void onMediaPreviewPageChanged(int value) {
    index(value);
    setTitle(value);
  }

  void setTitle(int index) {
    if(previewMediaList.elementAt(index).isMessageSentByMe){
      title("Sent Media");
    }else{
      title("Received Media");
    }
  }
}
