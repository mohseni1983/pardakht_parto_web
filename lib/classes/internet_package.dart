import 'dart:convert';

import 'package:flutter/material.dart';

class InternetPackageOperators{
  int id;
  String name;
  String grayImage;
  String colorImage;
  List<SimCardTypes> simTypes;
  Color color;

  InternetPackageOperators({ this.id,  this.name,  this.grayImage,  this.colorImage, this.simTypes, this.color=Colors.grey});
}

class SimCardTypes{
  int id;
  String name;

  SimCardTypes({ this.id,  this.name});
}


InternetPackage internetPackageFromJson(String str) => InternetPackage.fromJson(json.decode(str));

String internetPackageToJson(InternetPackage data) => json.encode(data.toJson());

class InternetPackage {
  InternetPackage({
     this.amount,
     this.billGroup,
     this.canUseWallet,
     this.cash,
     this.dataPlans,
     this.responseCode,
     this.responseMessage,
  });

  double amount;
  int billGroup;
  bool canUseWallet;
  double cash;
  List<DataPlan> dataPlans;
  int responseCode;
  String responseMessage;

  factory InternetPackage.fromJson(Map<String, dynamic> json) => InternetPackage(
    amount: json["Amount"],
    billGroup: json["BillGroup"],
    canUseWallet: json["CanUseWallet"],
    cash: json["Cash"],
    dataPlans: List<DataPlan>.from(json["DataPlans"].map((x) => DataPlan.fromJson(x))),
    responseCode: json["ResponseCode"],
    responseMessage: json["ResponseMessage"],
  );

  Map<String, dynamic> toJson() => {
    "Amount": amount,
    "BillGroup": billGroup,
    "CanUseWallet": canUseWallet,
    "Cash": cash,
    "DataPlans": List<dynamic>.from(dataPlans.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "ResponseMessage": responseMessage,
  };
}

class DataPlan {
  DataPlan({
     this.dataPlanType,
     this.id,
     this.dataPlanOperator,
     this.period,
     this.priceWithTax,
     this.priceWithoutTax,
     this.profileId,
     this.title,
     this.uniqCode,
  });

  int dataPlanType;
  int id;
  int dataPlanOperator;
  int period;
  double priceWithTax;
  double priceWithoutTax;
  int profileId;
  String title;
  String uniqCode;

  factory DataPlan.fromJson(Map<String, dynamic> json) => DataPlan(
    dataPlanType: json["DataPlanType"],
    id: json["Id"],
    dataPlanOperator: json["Operator"],
    period: json["Period"],
    priceWithTax: json["PriceWithTax"],
    priceWithoutTax: json["PriceWithoutTax"],
    profileId: json["ProfileId"],
    title: json["Title"],
    uniqCode: json["UniqCode"],
  );

  Map<String, dynamic> toJson() => {
    "DataPlanType": dataPlanType,
    "Id": id,
    "Operator": dataPlanOperator,
    "Period": period,
    "PriceWithTax": priceWithTax,
    "PriceWithoutTax": priceWithoutTax,
    "ProfileId": profileId,
    "Title": title,
    "UniqCode": uniqCode,
  };
}
