import 'package:equatable/equatable.dart';

class GeneralModel extends Equatable {
  const GeneralModel({this.code, this.desc, this.type});

  final String? code;
  final String? desc;
  final String? type;

  GeneralModel copyWith({String? code, String? desc, String? type}) =>
      GeneralModel(code: code ?? this.code, desc: desc ?? this.desc, type: type ?? this.type);

  factory GeneralModel.fromJson(Map<String, dynamic> json) =>
      GeneralModel(code: json["code"], desc: json["desc"], type: json["type"]);

  Map<String, dynamic> toJson() => {"code": code, "desc": desc, "type": type};

  String get display => "${(type ?? code)} : ${(desc ?? "-")}";

  @override
  List<Object?> get props => [code, desc];
}
