class WalletTransFinancingInfoList {
  WalletTransFinancingInfoList({
     this.financingInfoLists,
     this.totalCounts,
  });

  List<FinancingInfoListElement> financingInfoLists;
  int totalCounts;

  factory WalletTransFinancingInfoList.fromJson(Map<String, dynamic> json) => WalletTransFinancingInfoList(
    financingInfoLists: List<FinancingInfoListElement>.from(json["FinancingInfoLists"].map((x) => FinancingInfoListElement.fromJson(x))),
    totalCounts: json["TotalCounts"],
  );

  Map<String, dynamic> toJson() => {
    "FinancingInfoLists": List<dynamic>.from(financingInfoLists.map((x) => x.toJson())),
    "TotalCounts": totalCounts,
  };
}

class FinancingInfoListElement {
  FinancingInfoListElement({
     this.creditAmount,
     this.creditRemain,
     this.description,
     this.id,
     this.isNew,
     this.ownerId,
     this.transactDate,
     this.transactionType,
     this.transactionTypeDetails
  });

  double creditAmount;
  double creditRemain;
  String description;
  int id;
  bool isNew;
  int ownerId;
  DateTime transactDate;
  int transactionType;
  String transactionTypeDetails;

  factory FinancingInfoListElement.fromJson(Map<String, dynamic> json) => FinancingInfoListElement(
    creditAmount: json["CreditAmount"],
    creditRemain: json["CreditRemain"],
    description: json["Description"],
    id: json["Id"],
    isNew: json["IsNew"],
    ownerId: json["OwnerId"],
    transactDate: DateTime.parse(json["TransactDate"]),
    transactionType: json["TransactionType"],
      transactionTypeDetails: json["TransactionTypeDetails"]
  );

  Map<String, dynamic> toJson() => {
    "CreditAmount": creditAmount,
    "CreditRemain": creditRemain,
    "Description": description,
    "Id": id,
    "IsNew": isNew,
    "OwnerId": ownerId,
    "TransactDate": transactDate.toIso8601String(),
    "TransactionType": transactionType,
    "TransactionTypeDetails":transactionTypeDetails
  };
}