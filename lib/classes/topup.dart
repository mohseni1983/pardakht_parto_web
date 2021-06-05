import 'dart:convert';

TopUp topUpFromJson(String str) => TopUp.fromJson(json.decode(str));

String topUpToJson(TopUp data) => json.encode(data.toJson());

class TopUp {
  TopUp({
     this.amount,
     this.cellNumber,
     this.chargeType,
     this.topUpOperator,
     this.uniqCode,
     this.deviceId,
     this.localDate,
     this.requestedIp,
     this.sign,
     this.useWallet,
  });

  int amount;
  String cellNumber;
  int chargeType;
  int topUpOperator;
  String uniqCode;
  int deviceId;
  DateTime localDate;
  String requestedIp;
  String sign;
  bool useWallet;

  factory TopUp.fromJson(Map<String, dynamic> json) => TopUp(
    amount: json["Amount"],
    cellNumber: json["CellNumber"],
    chargeType: json["ChargeType"],
    topUpOperator: json["Operator"],
    uniqCode: json["UniqCode"],
    deviceId: json["DeviceId"],
    localDate: DateTime.parse(json["LocalDate"]),
    requestedIp: json["RequestedIp"],
    sign: json["Sign"],
    useWallet: json["UseWallet"],
  );

  Map<String, dynamic> toJson() => {
    "Amount": amount,
    "CellNumber": cellNumber,
    "ChargeType": chargeType,
    "Operator": topUpOperator,
    "UniqCode": uniqCode,
    "DeviceId": deviceId,
    "LocalDate": localDate.toIso8601String(),
    "RequestedIp": requestedIp,
    "Sign": sign,
    "UseWallet": useWallet,
  };
}

class StraightChargeOperators{
  int id;
  String name;
  String grayImage;
  String colorImage;
  List<ChargeTypesWithPrice> chargeTypes;

  StraightChargeOperators({ this.id,  this.name,  this.grayImage,  this.colorImage, this.chargeTypes});
}


class ChargeTypesWithPrice{
  int id;

  String name;
  List<int> prices;
  String coverImage;
  ChargeTypesWithPrice({ this.id, this.name, this.prices, this.coverImage});
}


