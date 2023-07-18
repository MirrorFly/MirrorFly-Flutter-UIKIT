import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../controllers/view_all_media_controller.dart';
import '../../../models.dart';

class ViewAllMediaView extends StatefulWidget {
  const ViewAllMediaView({Key? key, required this.name, required this.jid, required this.isGroup,this.enableAppBar=true}) : super(key: key);
  final String name;
  final String jid;
  final bool isGroup;
  final bool enableAppBar;
  @override
  State<ViewAllMediaView> createState() => _ViewAllMediaViewState();
}

class _ViewAllMediaViewState extends State<ViewAllMediaView> {
  var controller = Get.put(ViewAllMediaController());
  @override
  void initState() {
    controller.init(widget.name,widget.jid,widget.isGroup);
    super.initState();
  }
  @override
  void dispose() {
    Get.delete<ViewAllMediaController>();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        appBar: widget.enableAppBar ? AppBar(
          backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
          actionsIconTheme: IconThemeData(
              color: MirrorflyUikit.getTheme?.colorOnAppbar ??
                  iconColor),
          iconTheme: IconThemeData(
              color: MirrorflyUikit.getTheme?.colorOnAppbar ??
                  iconColor),
          automaticallyImplyLeading: true,
          title: Text(widget.name,style: TextStyle(color: MirrorflyUikit
              .getTheme?.colorOnAppbar ),),
          centerTitle: false,
          bottom: TabBar(
              indicatorColor: MirrorflyUikit.getTheme?.primaryColor,//buttonBgColor,
              labelColor: MirrorflyUikit.getTheme?.primaryColor,//buttonBgColor,
              unselectedLabelColor: MirrorflyUikit.getTheme?.colorOnAppbar,//appbarTextColor,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: [
                Center(
                  child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: const Text(
                        "Media",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      )),
                ),
                Center(
                  child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: const Text("Docs",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16))),
                ),
                Center(
                  child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: const Text("Links",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16))),
                ),
              ]),
        ) : null,
        body: SafeArea(child: TabBarView(children: [mediaView(), docsView(), linksView()])),
      ),
    );
  }

  Widget mediaView() {
    return Obx(() {
      return controller.medialistdata.isNotEmpty
          ? SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.medialistdata.length,
                    itemBuilder: (context, index) {
                      var header = controller.medialistdata.keys.toList()[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [headerItem(header), gridView(header)],
                      );
                    }),
                const SizedBox(height: 10,),
                Text("${controller.imageCount} Photos, ${controller.videoCount} Videos, ${controller.audioCount} Audios",style: TextStyle(color: MirrorflyUikit.getTheme?.textSecondaryColor),),
              ],
            ),
          )
          : Center(child: Text("No Media Found...!!!",style: TextStyle(color: MirrorflyUikit.getTheme?.textSecondaryColor)));
    });
  }

  Widget gridView(String header) {
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.medialistdata[header]!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (context, gridIndex) {
          var item = controller.medialistdata[header]![gridIndex].chatMessage;
          return gridItem(item, gridIndex);
        });
  }

  Widget headerItem(String header) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
      child: Text(
        header,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MirrorflyUikit.getTheme?.textPrimaryColor),
      ),
    );
  }

  Widget gridItem(ChatMessageModel item, int gridIndex) {
    return InkWell(
      child: Container(
          margin: const EdgeInsets.only(right: 3),
          color: item.isAudioMessage()
              ? darken(MirrorflyUikit.getTheme!.primaryColor,0.3)//const Color(0xff97A5C7)
              : Colors.transparent,
          child: item.isAudioMessage()
              ? audioItem(item)
              : item.isVideoMessage()
                  ? videoItem(item)
                  : item.isImageMessage()
                      ? Image.file(
                          File(item.mediaChatMessage!.mediaLocalStoragePath),
                          fit: BoxFit.cover,
                        )
                      : const SizedBox()),
      onTap: () {
        if (item.isImageMessage() || item.isVideoMessage()) {
          controller.openImage(context,gridIndex);
        } else if (item.isAudioMessage()) {
          // controller.openFile(item.mediaChatMessage!.mediaLocalStoragePath);
          controller.openImage(context,gridIndex);
        }
      },
    );
  }

  Widget videoItem(ChatMessageModel item) {
    return Stack(
      children: [
        controller.imageFromBase64String(
            item.mediaChatMessage!.mediaThumbImage, null, null),
        Center(
          child: CircleAvatar(
            radius: 8,
              backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
              child: Icon(Icons.play_arrow,color: MirrorflyUikit.getTheme?.colorOnPrimary,size: 12,)))
      ],
    );
  }

  Widget audioItem(ChatMessageModel item) {
    return Center(
      child: SvgPicture.asset(
          item.mediaChatMessage!.isAudioRecorded ? audioMic1 : audioWhite,package: package,color: MirrorflyUikit.getTheme?.colorOnPrimary,),
    );
  }

  Widget docsView() {
    return Obx(() {
      return controller.docslistdata.isNotEmpty
          ? listView(controller.docslistdata, true)
          : Center(child: Text("No Docs Found...!!!",style: TextStyle(color: MirrorflyUikit.getTheme?.textSecondaryColor)));
    });
  }

  Widget listView(Map<String, List<MessageItem>> list, bool doc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
              itemCount: list.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var header = list.keys.toList()[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    headerItem(header),
                    ListView.builder(
                        itemCount: list[header]!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, listIndex) {
                          var item = list[header]![listIndex].chatMessage;
                          return doc
                              ? docTile(
                                  assetName: getDocAsset(
                                      item.mediaChatMessage!.mediaFileName),
                                  title: item.mediaChatMessage!.mediaFileName,
                                  subtitle: getFileSizeText(item
                                      .mediaChatMessage!.mediaFileSize
                                      .toString()),
                                  //item.mediaChatMessage!.mediaFileSize.readableFileSize(base1024: false),
                                  date: getDateFromTimestamp(
                                      item.messageSentTime.toInt(), "d/MM/yy"),
                                  path: item.mediaChatMessage!.mediaLocalStoragePath)
                              : linkTile(list[header]![listIndex]);
                        }),
                  ],
                );
              }),
          const SizedBox(height: 10,),
          doc ? Text("${controller.documentCount} Documents") : Text("${controller.linkCount} Links",style: TextStyle(color: MirrorflyUikit.getTheme?.textSecondaryColor))
        ],
      ),
    );
  }

  Widget docTile(
      {required String assetName,
      required String title,
      required String subtitle,
      required String date,
      required String path}) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SvgPicture.asset(
                  assetName,package: package,
                  width: 20,
                  height: 20,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 13,color: MirrorflyUikit.getTheme?.textPrimaryColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11,color: MirrorflyUikit.getTheme?.textSecondaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Text(date, style: TextStyle(fontSize: 11,color: MirrorflyUikit.getTheme?.textSecondaryColor)),
              )),
            ],
          ),
          const AppDivider(
            padding: EdgeInsets.symmetric(horizontal: 16),
          )
        ],
      ),
      onTap: () {
        controller.openFile(path);
      },
    );
  }

  Widget linkTile(MessageItem item) {
    return Column(
      children: [
        Container(
          margin:
              const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          decoration: BoxDecoration(
              color: MirrorflyUikit.getTheme!.primaryColor.withAlpha(60),
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: (){
                  launchWeb(item.linkMap!["url"]);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: MirrorflyUikit.getTheme!.primaryColor.withAlpha(50),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        (item.chatMessage.isImageMessage() ||
                                item.chatMessage.isVideoMessage())
                            ? ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8)),
                                child: controller.imageFromBase64String(
                                    item.chatMessage.mediaChatMessage!
                                        .mediaThumbImage,
                                    70,
                                    70),
                              )
                            : Container(
                                constraints: const BoxConstraints(minHeight: 70,minWidth: 70),
                                decoration: BoxDecoration(
                                    color: MirrorflyUikit.getTheme!.primaryColor,//Color(0xff97A5C7),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8))),
                                child: Center(
                                  child: SvgPicture.asset(linkImage,package: package,color: MirrorflyUikit.getTheme?.colorOnPrimary,),
                                ),
                              ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.linkMap!["url"],
                                style: TextStyle(fontSize: 14,color: MirrorflyUikit.getTheme?.textPrimaryColor),
                              ),
                              Text(
                                item.linkMap!["host"],
                                style: TextStyle(fontSize: 10,color: MirrorflyUikit.getTheme?.textSecondaryColor),
                              ),
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  controller.navigateMessage(item.chatMessage);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          (item.chatMessage.isTextMessage())
                              ? item.chatMessage.messageTextContent!
                              : (item.chatMessage.isImageMessage() ||
                                      item.chatMessage.isVideoMessage())
                                  ? item.chatMessage.mediaChatMessage!
                                      .mediaCaptionText
                                  : Constants.emptyString,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.blue),//Color(0xff7889B3)),
                          // overflow: TextOverflow.clip,
                          maxLines: 1,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: MirrorflyUikit.getTheme?.primaryColor//Color(0xff7185b5),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        const AppDivider(
          padding: EdgeInsets.symmetric(horizontal: 16),
        )
      ],
    );
  }

  Widget linksView() {
    return Obx(() {
      return controller.linklistdata.isNotEmpty
          ? listView(controller.linklistdata, false)
          : Center(child: Text("No Links Found...!!!",style: TextStyle(color: MirrorflyUikit.getTheme?.textSecondaryColor)));
    });
  }
}
