import 'dart:convert';
import 'dart:io';

ChatDataModel chatDataModelFromJson(String str) =>
    ChatDataModel.fromJson(json.decode(str));

String chatDataModelToJson(ChatDataModel data) => json.encode(data.toJson());

class ChatDataModel {
  List<MediaAttachmentsUri>? mediaAttachmentsUri;
  String? messageContent;
  String? subject;

  ChatDataModel({
    this.mediaAttachmentsUri,
    this.messageContent,
    this.subject,
  });

  factory ChatDataModel.fromJson(Map<String, dynamic> json) => ChatDataModel(
        mediaAttachmentsUri: json["mediaAttachmentsUri"] == null
            ? []
            : List<MediaAttachmentsUri>.from(json["mediaAttachmentsUri"]!
                .map((x) => MediaAttachmentsUri.fromJson(x))),
        messageContent: json["messageContent"],
        subject: json["subject"],
      );

  Map<String, dynamic> toJson() => {
        "mediaAttachmentsUri": mediaAttachmentsUri == null
            ? []
            : List<dynamic>.from(mediaAttachmentsUri!.map((x) => x.toJson())),
        "messageContent": messageContent,
        "subject": subject,
      };
}

class MediaAttachmentsUri {
  Authority? authority;
  Fragment? fragment;
  Authority? path;
  Fragment? query;
  String? scheme;
  String? uriString;
  String? host;
  int? port;
  String? file;

  MediaAttachmentsUri(
      {this.authority,
      this.fragment,
      this.path,
      this.query,
      this.scheme,
      this.uriString,
      this.host,
      this.port,
      this.file});

  factory MediaAttachmentsUri.fromJson(Map<String, dynamic> json) =>
      MediaAttachmentsUri(
          authority: json["authority"] == null
              ? null
              : Authority.fromJson(json["authority"]),
          fragment: json["fragment"] == null
              ? null
              : Fragment.fromJson(json["fragment"]),
          path: json["path"] == null ? null : Authority.fromJson(json["path"]),
          query:
              json["query"] == null ? null : Fragment.fromJson(json["query"]),
          scheme: json["scheme"],
          uriString: json["uriString"],
          host: json["host"],
          port: json["port"],
          file: Platform.isIOS
              ? json["file"]
              : json["path"] == null
                  ? null
                  : json["path"]["encoded"]);

  Map<String, dynamic> toJson() => {
        "authority": authority?.toJson(),
        "fragment": fragment?.toJson(),
        "path": path?.toJson(),
        "query": query?.toJson(),
        "scheme": scheme,
        "uriString": uriString,
        "host": host,
        "port": port,
      };
}

class Authority {
  String? decoded;
  String? encoded;
  int? mCanonicalRepresentation;

  Authority({
    this.decoded,
    this.encoded,
    this.mCanonicalRepresentation,
  });

  factory Authority.fromJson(Map<String, dynamic> json) => Authority(
        decoded: json["decoded"],
        encoded: json["encoded"],
        mCanonicalRepresentation: json["mCanonicalRepresentation"],
      );

  Map<String, dynamic> toJson() => {
        "decoded": decoded,
        "encoded": encoded,
        "mCanonicalRepresentation": mCanonicalRepresentation,
      };
}

class Fragment {
  int? mCanonicalRepresentation;

  Fragment({
    this.mCanonicalRepresentation,
  });

  factory Fragment.fromJson(Map<String, dynamic> json) => Fragment(
        mCanonicalRepresentation: json["mCanonicalRepresentation"],
      );

  Map<String, dynamic> toJson() => {
        "mCanonicalRepresentation": mCanonicalRepresentation,
      };
}
