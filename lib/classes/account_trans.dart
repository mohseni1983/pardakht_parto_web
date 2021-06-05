class AcountTransTxnInfoList {
  AcountTransTxnInfoList({
     this.totalCounts,
     this.txnInfoLists,
  });

  int totalCounts;
  List<TxnInfoListElement> txnInfoLists;

  factory AcountTransTxnInfoList.fromJson(Map<String, dynamic> json) => AcountTransTxnInfoList(
    totalCounts: json["TotalCounts"],
    txnInfoLists: List<TxnInfoListElement>.from(json["TxnInfoLists"].map((x) => TxnInfoListElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "TotalCounts": totalCounts,
    "TxnInfoLists": List<dynamic>.from(txnInfoLists.map((x) => x.toJson())),
  };
}

class TxnInfoListElement {
  TxnInfoListElement({
     this.amount,
     this.billGroup,
     this.billId,
     this.cardNumber,
     this.cellNumber,
     this.isCharge,
     this.isReverse,
     this.isSettle,
     this.issuerBank,
     this.payId,
     this.requestDate,
     this.requestType,
     this.requestTypeDetails,
     this.rrn,
     this.traceNumber,
     this.id,
     this.payApproveDate,
     this.payRollBackDate,
     this.description,
      this.useWallet

  });

  double amount;
  int billGroup;
  String billId;
  String cardNumber;
  String cellNumber;
  bool isCharge;
  bool isReverse;
  bool isSettle;
  String issuerBank;
  String payId;
  String requestDate;
  int requestType;
  String requestTypeDetails;
  String rrn;
  String traceNumber;
  int id;
  String payApproveDate;
  String payRollBackDate;
  String description;
  bool useWallet;

  factory TxnInfoListElement.fromJson(Map<String, dynamic> json) => TxnInfoListElement(
    amount: json["Amount"],
    billGroup: json["BillGroup"],
    billId: json["BillId"],
    cardNumber: json["CardNumber"] ,
    cellNumber: json["CellNumber"],
    isCharge: json["IsCharge"],
    isReverse: json["IsReverse"],
    isSettle: json["IsSettle"],
    issuerBank: json["IssuerBank"] ,
    payId: json["PayId"],
    requestDate: json["RequestDate"],
    requestType: json["RequestType"],
    requestTypeDetails: json["RequestTypeDetails"],
    rrn: json["Rrn"] ,
    traceNumber: json["TraceNumber"] ,
    id:json['Id'],
    payApproveDate: json['PayApproveDate'],
      payRollBackDate: json['PayRollBackDate'],
    description:json["Description"],
    useWallet: json['UseWallet']
  );

  Map<String, dynamic> toJson() => {
    "Amount": amount,
    "BillGroup": billGroup,
    "BillId": billId,
    "CardNumber": cardNumber,
    "CellNumber": cellNumber,
    "IsCharge": isCharge,
    "IsReverse": isReverse,
    "IsSettle": isSettle,
    "IssuerBank": issuerBank,
    "PayId": payId,
    "RequestDate": requestDate,
    "RequestType": requestType,
    "RequestTypeDetails": requestTypeDetails,
    "Rrn": rrn ,
    "TraceNumber": traceNumber ,
    "Id":id,
    "PayApproveDate":payApproveDate,
    "PayRollBackDate":payRollBackDate,
    "Description":description,
  };
}