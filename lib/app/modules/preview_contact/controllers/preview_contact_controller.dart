import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../model/local_contact_model.dart';
import '../../chat/controllers/chat_controller.dart';

class PreviewContactController extends GetxController {
  var contactList = <LocalContactPhone>[].obs;
  var argContactList = <LocalContact>[];
  var previewContactList = <String>[];
  var previewContactName = "";
  var from = "";


  void init(List<LocalContact>? contactList, List<String>? previewContactList, String from, String? contactName) {
    this.from = from;
    if(from == "chat" && previewContactList != null && contactName != null) {
      this.previewContactList = previewContactList;
      previewContactName = contactName;
    }else if(contactList != null){
      argContactList = contactList;
    }else{
      debugPrint("Contact list is Empty");
    }
  }
  @override
  void onReady() {
    super.onReady();
    if (from == "chat") {
      // previewContactList = Get.arguments['previewContactList'];
      // previewContactName = Get.arguments['contactName'];

      var newContactList = <ContactDetail>[];
      for (var phone in previewContactList) {
        ContactDetail contactDetail =
            ContactDetail(mobNo: phone, isSelected: true, mobNoType: "");
        newContactList.add(contactDetail);
      }
      LocalContactPhone localContactPhone = LocalContactPhone(
          contactNo: newContactList, userName: previewContactName);
      contactList.add(localContactPhone);
    } else {
      // argContactList = Get.arguments['contactList'];
      for (var contact in argContactList) {
        var newContactList = <ContactDetail>[];
        for (var phone in contact.contact.phones!) {
          ContactDetail contactDetail = ContactDetail(
              mobNo: phone.value!, isSelected: true, mobNoType: phone.label!);
          newContactList.add(contactDetail);
        }
        LocalContactPhone localContactPhone = LocalContactPhone(
            contactNo: newContactList, userName: name(contact.contact));
        contactList.add(localContactPhone);
      }
    }
    // shareContactList.addAll(args1);
    debugPrint("received length--> ${contactList.length}");
  }

  name(Contact item) {
    return item.displayName ??
        item.givenName ??
        item.middleName ??
        item.androidAccountName ??
        item.familyName ??
        "";
  }

  shareContact(BuildContext context) async {

    Helper.showLoading(
        message: "Sharing Contact", buildContext: context);
    var contactServerSharing = <ShareContactDetails>[];
      for (var item in contactList) {
        var contactSharing = <String>[];
        for (var contactItem in item.contactNo) {
          if (contactItem.isSelected) {
            debugPrint("adding--> ${contactItem.mobNo}");
            contactSharing.add(contactItem.mobNo);
          } else {
            debugPrint("skipping--> ${contactItem.mobNo}");
          }
        }
        if (contactSharing.isEmpty) {
          toToast("Select at least one number");
          return;
        }
        debugPrint("adding contact list--> ${contactSharing.toString()}");
        contactServerSharing.add(ShareContactDetails(
            contactNo: contactSharing, userName: item.userName));
        // contactSharing.clear();
      }

      debugPrint("sharing contact length--> ${contactServerSharing.length}");

      for (var contactItem in contactServerSharing) {
        debugPrint("sending contact--> ${contactItem.userName}");
        debugPrint("sending contact--> ${contactItem.contactNo}");

        var response = await Get.find<ChatController>()
            .sendContactMessage(contactItem.contactNo, contactItem.userName, context);
        debugPrint("ContactResponse ==> $response");
      }

    if(context.mounted) {
      Helper.hideLoading(context: context);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  void changeStatus(ContactDetail phoneItem) {
    phoneItem.isSelected = !phoneItem.isSelected;
    contactList.refresh();
  }

}