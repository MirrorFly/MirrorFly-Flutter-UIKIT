import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';

import '../../model/chat_message_model.dart';

class NotificationUtils{
  static var deletedMessage = AppConstants.thisMessageWasDeleted;
  static var imageEmoji = "📷";
  static var videoEmoji = "📽️";
  static var contactEmoji = "👤";
  static var audioEmoji = "🎵";
  static var fileEmoji = "📄";
  static var locationEmoji = "📌";

  /*
  * Returns the message summary
  * @param message Instance on ChatMessage in NotificationMessageModel
  * @return String Summary of the message
  * */
  static String getMessageSummary(ChatMessageModel message){
    if(Constants.mText == message.messageType || Constants.mNotification == message.messageType) {
      if (message.isMessageRecalled.value.checkNull()) {
        return deletedMessage;
      } else {
        var lastMessageMentionContent = message.messageTextContent.checkNull();
       /* if(message.mentionedUsersIds!=null && message.mentionedUsersIds!.isNotEmpty){
          //need to work on mentions
        }*/
        return lastMessageMentionContent;
      }
    }else if(message.isMessageRecalled.value.checkNull()){
      return deletedMessage;
    }else{
      return getMediaMessageContent(message);
    }
  }

  /*
  * Returns the media message Content
  * @param message Instance of ChatMessage in NotificationMessageModel
  * @return String media message content
  * */
  static String getMediaMessageContent(ChatMessageModel message){
    var contentBuilder = StringBuffer();
    switch(message.messageType){
      case Constants.mAudio:
        contentBuilder.write("$audioEmoji ${AppConstants.nAudio}");
        break;
      case Constants.mContact:
        contentBuilder.write("$contactEmoji ${AppConstants.nContact}");
        break;
      case Constants.mDocument:
        contentBuilder.write("$fileEmoji ${AppConstants.nFile}");
        break;
      case Constants.mImage:
        contentBuilder.write("$imageEmoji ${getMentionMediaCaptionTextFormat(message)}");
        break;
      case Constants.mLocation:
        contentBuilder.write("$locationEmoji ${AppConstants.nLocation}");
        break;
      case Constants.mVideo:
        contentBuilder.write("$videoEmoji ${getMentionMediaCaptionTextFormat(message)}");
        break;
    }
    return contentBuilder.toString();
  }

  /*
  * Returns the image or video media message caption
  * @param message Instance of ChatMessage in NotificationMessageModel
  * @return String image or video media message caption
  * */
  static String getMentionMediaCaptionTextFormat(ChatMessageModel message){
    var mediaCaption = (message.mediaChatMessage != null && message.mediaChatMessage?.mediaCaptionText !=null && message.mediaChatMessage!.mediaCaptionText.toString().isNotEmpty)
        ? message.mediaChatMessage!.mediaCaptionText.toString() : getMessageTypeText(message.messageType.toString().toUpperCase());
    return mediaCaption;
  }

  static String getMessageTypeText(String messageType){
    switch(messageType){
      case Constants.mImage: return AppConstants.nImage;
      case Constants.mFile: return AppConstants.nFile;
      case Constants.mAudio: return AppConstants.nAudio;
      case Constants.mVideo: return AppConstants.nVideo;
      case Constants.mDocument: return AppConstants.nDocument;
      case Constants.mContact: return AppConstants.nContact;
      case Constants.mLocation: return AppConstants.nLocation;
      default: return messageType;
    }
  }
}