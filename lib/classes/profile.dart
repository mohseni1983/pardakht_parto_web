// To parse this JSON data, do
//
//     final profileInfo = profileInfoFromJson(jsonString);

import 'dart:convert';

ProfileInfo profileInfoFromJson(String str) => ProfileInfo.fromJson(json.decode(str));

String profileInfoToJson(ProfileInfo data) => json.encode(data.toJson());

class ProfileInfo {
  ProfileInfo({
     this.deviceInfo,
  });

  DeviceInfo deviceInfo;

  factory ProfileInfo.fromJson(Map<String, dynamic> json) => ProfileInfo(
    deviceInfo: DeviceInfo.fromJson(json["DeviceInfo"]),
  );

  Map<String, dynamic> toJson() => {
    "DeviceInfo": deviceInfo.toJson(),
  };
}

class DeviceInfo {
  DeviceInfo({
     this.birthDate,
     this.cellNumber,
     this.credit,
     this.deviceCreateOn,
     this.deviceId,
     this.deviceIsActive,
     this.deviceKey,
     this.expireCode,
     this.family,
     this.gender,
     this.name,
     this.os,
     this.ownerCreateOn,
     this.ownerId,
     this.ownerIsActive,
     this.registerCode,
     this.signKey,
     this.urlSchema,
     this.point
  });

  DateTime birthDate;
  String cellNumber;
  double credit;
  DateTime deviceCreateOn;
  int deviceId;
  bool deviceIsActive;
  String deviceKey;
  DateTime expireCode;
  String family;
  int gender;
  String name;
  int os;
  DateTime ownerCreateOn;
  int ownerId;
  bool ownerIsActive;
  String registerCode;
  String signKey;
  String urlSchema;
  double point;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    birthDate: DateTime.parse(json["BirthDate"]),
    cellNumber: json["CellNumber"],
    credit: json["Credit"],
    deviceCreateOn: DateTime.parse(json["DeviceCreateOn"]),
    deviceId: json["DeviceId"],
    deviceIsActive: json["DeviceIsActive"],
    deviceKey: json["DeviceKey"],
    expireCode: DateTime.parse(json["ExpireCode"]),
    family: json["Family"],
    gender: json["Gender"],
    name: json["Name"],
    os: json["Os"],
    ownerCreateOn: DateTime.parse(json["OwnerCreateOn"]),
    ownerId: json["OwnerId"],
    ownerIsActive: json["OwnerIsActive"],
    registerCode: json["RegisterCode"],
    signKey: json["SignKey"],
    urlSchema: json["UrlSchema"],
    point: json["Point"]
  );

  Map<String, dynamic> toJson() => {
    "BirthDate": birthDate.toIso8601String(),
    "CellNumber": cellNumber,
    "Credit": credit,
    "DeviceCreateOn": deviceCreateOn.toIso8601String(),
    "DeviceId": deviceId,
    "DeviceIsActive": deviceIsActive,
    "DeviceKey": deviceKey,
    "ExpireCode": expireCode.toIso8601String(),
    "Family": family,
    "Gender": gender,
    "Name": name,
    "Os": os,
    "OwnerCreateOn": ownerCreateOn.toIso8601String(),
    "OwnerId": ownerId,
    "OwnerIsActive": ownerIsActive,
    "RegisterCode": registerCode,
    "SignKey": signKey,
    "UrlSchema": urlSchema,
  };
}



