import 'dart:convert';

Charities charitiesFromJson(String str) => Charities.fromJson(json.decode(str));

String charitiesToJson(Charities data) => json.encode(data.toJson());

class Charities {
  Charities({
     this.cash,
     this.charityTerminals,
     this.responseCode,
     this.responseMessage,
  });

  double cash;
  CharityTerminals charityTerminals;
  int responseCode;
  String responseMessage;

  factory Charities.fromJson(Map<String, dynamic> json) => Charities(
    cash: json["Cash"],
    charityTerminals: CharityTerminals.fromJson(json["CharityTerminals"]),
    responseCode: json["ResponseCode"],
    responseMessage: json["ResponseMessage"],
  );

  Map<String, dynamic> toJson() => {
    "Cash": cash,
    "CharityTerminals": charityTerminals.toJson(),
    "ResponseCode": responseCode,
    "ResponseMessage": responseMessage,
  };
}

class CharityTerminals {
  CharityTerminals({
     this.financingInfoLists,
     this.totalCounts,
  });

  List<FinancingInfoList> financingInfoLists;
  int totalCounts;

  factory CharityTerminals.fromJson(Map<String, dynamic> json) => CharityTerminals(
    financingInfoLists: List<FinancingInfoList>.from(json["FinancingInfoLists"].map((x) => FinancingInfoList.fromJson(x))),
    totalCounts: json["TotalCounts"],
  );

  Map<String, dynamic> toJson() => {
    "FinancingInfoLists": List<dynamic>.from(financingInfoLists.map((x) => x.toJson())),
    "TotalCounts": totalCounts,
  };
}

class FinancingInfoList {
  FinancingInfoList({
     this.id,
     this.pspId,
     this.termId,
     this.title,
  });

  int id;
  int pspId;
  String termId;
  String title;

  factory FinancingInfoList.fromJson(Map<String, dynamic> json) => FinancingInfoList(
    id: json["Id"],
    pspId: json["PspId"],
    termId: json["TermId"],
    title: json["Title"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "PspId": pspId,
    "TermId": termId,
    "Title": title,
  };
}
