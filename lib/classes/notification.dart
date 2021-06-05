// To parse this JSON data, do
//
//     final notifications = notificationsFromJson(jsonString);

import 'dart:convert';

Notifications notificationsFromJson(String str) => Notifications.fromJson(json.decode(str));

String notificationsToJson(Notifications data) => json.encode(data.toJson());

class Notifications {
  Notifications({
     this.ownerAlerts,
     this.responseCode,
     this.responseMessage,
     this.signKey,
     this.url,
  });

  List<OwnerAlert> ownerAlerts;
  int responseCode;
  String responseMessage;
  String signKey;
  String url;

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
    ownerAlerts: List<OwnerAlert>.from(json["OwnerAlerts"].map((x) => OwnerAlert.fromJson(x))),
    responseCode: json["ResponseCode"],
    responseMessage: json["ResponseMessage"],
    signKey: json["SignKey"],
    url: json["Url"],
  );

  Map<String, dynamic> toJson() => {
    "OwnerAlerts": List<dynamic>.from(ownerAlerts.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "ResponseMessage": responseMessage,
    "SignKey": signKey,
    "Url": url,
  };
}

class OwnerAlert {
  OwnerAlert({
     this.alertId,
     this.body,
     this.createdOn,
     this.deviceId,
     this.deviceIsActive,
     this.fcmKey,
     this.id,
     this.isActive,
     this.isRead,
     this.ownerAlertId,
     this.ownerIsActive,
     this.title,
  });

  int alertId;
  String body;
  DateTime createdOn;
  int deviceId;
  bool deviceIsActive;
  String fcmKey;
  int id;
  bool isActive;
  bool isRead;
  int ownerAlertId;
  bool ownerIsActive;
  String title;

  factory OwnerAlert.fromJson(Map<String, dynamic> json) => OwnerAlert(
    alertId: json["AlertId"],
    body: json["Body"],
    createdOn: DateTime.parse(json["CreatedOn"]),
    deviceId: json["DeviceId"],
    deviceIsActive: json["DeviceIsActive"],
    fcmKey: json["FcmKey"],
    id: json["Id"],
    isActive: json["IsActive"],
    isRead: json["IsRead"],
    ownerAlertId: json["OwnerAlertId"],
    ownerIsActive: json["OwnerIsActive"],
    title: json["Title"],
  );

  Map<String, dynamic> toJson() => {
    "AlertId": alertId,
    "Body": body,
    "CreatedOn": createdOn.toIso8601String(),
    "DeviceId": deviceId,
    "DeviceIsActive": deviceIsActive,
    "FcmKey": fcmKey,
    "Id": id,
    "IsActive": isActive,
    "IsRead": isRead,
    "OwnerAlertId": ownerAlertId,
    "OwnerIsActive": ownerIsActive,
    "Title": title,
  };
}
