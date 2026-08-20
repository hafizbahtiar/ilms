import 'dart:convert';

import 'general_model.dart';

GeneralResponseModel generalResponseModelFromJson(String str) =>
    GeneralResponseModel.fromJson(json.decode(str));

String generalResponseModelToJson(GeneralResponseModel data) =>
    json.encode(data.toJson());

class GeneralResponseModel {
  String? status;
  String? message;
  List<GeneralModel>? data;
  Pagination? pagination;

  GeneralResponseModel({this.status, this.message, this.data, this.pagination});

  GeneralResponseModel copyWith({
    String? status,
    String? message,
    List<GeneralModel>? data,
  }) => GeneralResponseModel(
    status: status ?? this.status,
    message: message ?? this.message,
    data: data ?? this.data,
  );

  factory GeneralResponseModel.fromJson(Map<String, dynamic> json) =>
      GeneralResponseModel(
        status: json["status"],
        message: json["message"],
        pagination: Pagination.fromJson(json["pagination"] ?? {}),
        data: json["data"] == null
            ? []
            : List<GeneralModel>.from(
                json["data"]!.map((x) => GeneralModel.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Pagination {
  int? currentPage;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  Pagination({
    this.currentPage,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  Pagination copyWith({
    int? currentPage,
    String? firstPageUrl,
    int? from,
    int? lastPage,
    String? lastPageUrl,
    String? nextPageUrl,
    String? path,
    int? perPage,
    dynamic prevPageUrl,
    int? to,
    int? total,
  }) => Pagination(
    currentPage: currentPage ?? this.currentPage,
    firstPageUrl: firstPageUrl ?? this.firstPageUrl,
    from: from ?? this.from,
    lastPage: lastPage ?? this.lastPage,
    lastPageUrl: lastPageUrl ?? this.lastPageUrl,
    nextPageUrl: nextPageUrl ?? this.nextPageUrl,
    path: path ?? this.path,
    perPage: perPage ?? this.perPage,
    prevPageUrl: prevPageUrl ?? this.prevPageUrl,
    to: to ?? this.to,
    total: total ?? this.total,
  );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["CurrentPage"],
    firstPageUrl: json["FirstPageUrl"],
    from: json["From"],
    lastPage: json["LastPage"],
    lastPageUrl: json["LastPageUrl"],
    nextPageUrl: json["NextPageUrl"],
    path: json["Path"],
    perPage: json["PerPage"],
    prevPageUrl: json["PrevPageUrl"],
    to: json["To"],
    total: json["Total"],
  );

  Map<String, dynamic> toJson() => {
    "CurrentPage": currentPage,
    "FirstPageUrl": firstPageUrl,
    "From": from,
    "LastPage": lastPage,
    "LastPageUrl": lastPageUrl,
    "NextPageUrl": nextPageUrl,
    "Path": path,
    "PerPage": perPage,
    "PrevPageUrl": prevPageUrl,
    "To": to,
    "Total": total,
  };
}
