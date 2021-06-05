// To parse this JSON data, do
//
//     final recipt = reciptFromJson(jsonString);

import 'dart:convert';

Recipt reciptFromJson(String str) => Recipt.fromJson(json.decode(str));

String reciptToJson(Recipt data) => json.encode(data.toJson());

class Recipt {
  Recipt({
     this.rrn,
     this.terminalId,
     this.invoiceId,
     this.amount,
     this.cardNumber,
     this.traceNumber,
     this.datePaid,
     this.respCode,
     this.respMsg,
     this.issuerBank,
     this.requestType,
     this.billId,
     this.payId,
     this.cellNumber,
     this.description,
     this.billGroup,
  });

  String rrn;
  String terminalId;
  String invoiceId;
  String amount;
  String cardNumber;
  String traceNumber;
  String datePaid;
  String respCode;
  String respMsg;
  String issuerBank;
  String requestType;
  String billId;
  String payId;
  String cellNumber;
  String description;
  int billGroup;

  factory Recipt.fromJson(Map<String, dynamic> json) => Recipt(
    rrn: json["Rrn"],
    terminalId: json["TerminalId"],
    invoiceId: json["InvoiceId"],
    amount: json["Amount"],
    cardNumber: json["CardNumber"],
    traceNumber: json["TraceNumber"],
    datePaid: json["DatePaid"],
    respCode: json["RespCode"],
    respMsg: json["RespMsg"],
    issuerBank: json["IssuerBank"],
    requestType: json["RequestType"],
    billId: json["BillId"],
    payId: json["PayId"],
    cellNumber: json["CellNumber"],
    description: json["Description"],
    billGroup: json["BillGroup"],
  );

  Map<String, dynamic> toJson() => {
    "Rrn": rrn,
    "TerminalId": terminalId,
    "InvoiceId": invoiceId,
    "Amount": amount,
    "CardNumber": cardNumber,
    "TraceNumber": traceNumber,
    "DatePaid": datePaid,
    "RespCode": respCode,
    "RespMsg": respMsg,
    "IssuerBank": issuerBank,
    "RequestType": requestType,
    "BillId": billId,
    "PayId": payId,
    "CellNumber": cellNumber,
    "Description": description,
    "BillGroup": billGroup,
  };
}
