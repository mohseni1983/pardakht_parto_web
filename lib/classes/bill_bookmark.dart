// To parse this JSON data, do
//
//     final billBookmark = billBookmarkFromJson(jsonString);

import 'dart:convert';

List<BillBookmark> billBookmarkFromJson(String str) => List<BillBookmark>.from(json.decode(str).map((x) => BillBookmark.fromJson(x)));

String billBookmarkToJson(List<BillBookmark> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BillBookmark {
  BillBookmark({
     this.billGroups,
     this.code,
     this.title,
  });

  int billGroups;
  String code;
  String title;

  factory BillBookmark.fromJson(Map<String, dynamic> json) => BillBookmark(
    billGroups: json["BillGroups"],
    code: json["Code"],
    title: json["Title"],
  );

  Map<String, dynamic> toJson() => {
    "BillGroups": billGroups,
    "Code": code,
    "Title": title,
  };
}
