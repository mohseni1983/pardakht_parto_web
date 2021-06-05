// To parse this JSON data, do
//
//     final bill = billFromJson(jsonString);

import 'dart:convert';

Bill billFromJson(String str) => Bill.fromJson(json.decode(str));

String billToJson(Bill data) => json.encode(data.toJson());

class Bill {
  Bill({
     this.bills,
     this.canUseWallet,
     this.cash,
     this.responseCode,
     this.responseMessage,
    this.signKey,
    this.txnInfoList,
    this.url,
  });

  String bills;
  bool canUseWallet;
  double cash;
  int responseCode;
  String responseMessage;
  dynamic signKey;
  dynamic txnInfoList;
  dynamic url;

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
    bills: json["Bills"],
    canUseWallet: json["CanUseWallet"],
    cash: json["Cash"],
    responseCode: json["ResponseCode"],
    responseMessage: json["ResponseMessage"],
    signKey: json["SignKey"],
    txnInfoList: json["TxnInfoList"],
    url: json["Url"],
  );

  Map<String, dynamic> toJson() => {
    "Bills": bills,
    "CanUseWallet": canUseWallet,
    "Cash": cash,
    "ResponseCode": responseCode,
    "ResponseMessage": responseMessage,
    "SignKey": signKey,
    "TxnInfoList": txnInfoList,
    "Url": url,
  };
}

BillItems billItemsFromJson(String str) {
  var data=json.decode(str);
  return BillItems.fromJson(data);
}

String billItemsToJson(List<BillItems> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BillItems {
  BillItems({

     this.billId,
     this.paymentId,
     this.amount,
  });


  String billId;
  String paymentId;
  int amount;

  factory BillItems.fromJson(Map<String, dynamic> json) => BillItems(

    billId: json["bill_id"],
    paymentId: json["pay_id"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {

    "bill_id": billId,
    "pay_id": paymentId,
    "amount": amount,
  };
}



BillOther billOtherFromJson(String str) => BillOther.fromJson(json.decode(str));

String billOtherToJson(BillOther data) => json.encode(data.toJson());

class BillOther {
  BillOther({
     this.amount,
     this.billGroup,
     this.bills,
     this.canUseWallet,
     this.cash,
     this.responseCode,
     this.responseMessage,
  });

  double amount;
  int billGroup;
  String bills;
  bool canUseWallet;
  double cash;
  int responseCode;
  String responseMessage;

  factory BillOther.fromJson(Map<String, dynamic> json) => BillOther(
    amount: json["Amount"],
    billGroup: json["BillGroup"],
    bills: json["Bills"],
    canUseWallet: json["CanUseWallet"],
    cash: json["Cash"],
    responseCode: json["ResponseCode"],
    responseMessage: json["ResponseMessage"],
  );

  Map<String, dynamic> toJson() => {
    "Amount": amount,
    "BillGroup": billGroup,
    "Bills": bills,
    "CanUseWallet": canUseWallet,
    "Cash": cash,
    "ResponseCode": responseCode,
    "ResponseMessage": responseMessage,
  };
}


BillOtherItem billOtherItemFromJson(String str) => BillOtherItem.fromJson(json.decode(str));

String billOtherItemToJson(BillOtherItem data) => json.encode(data.toJson());

class BillOtherItem {
  BillOtherItem({
     this.billId,
     this.payId,
     this.amount,
     this.currentCheck,
     this.paymentDate,
     this.previousCheck,
     this.address,
     this.owner,
  });

  String billId;
  String payId;
  int amount;
  String currentCheck;
  String paymentDate;
  String previousCheck;
  String address;
  String owner;

  factory BillOtherItem.fromJson(Map<String, dynamic> json) => BillOtherItem(
    billId: json["bill_id"],
    payId: json["pay_id"],
    amount: json["amount"],
    currentCheck: json["current_check"],
    paymentDate: json["payment_date"],
    previousCheck: json["previous_check"],
    address: json["address"],
    owner: json["owner"],
  );

  Map<String, dynamic> toJson() => {
    "bill_id": billId,
    "pay_id": payId,
    "amount": amount,
    "current_check": currentCheck,
    "payment_date": paymentDate,
    "previous_check": previousCheck,
    "address": address,
    "owner": owner,
  };
}

