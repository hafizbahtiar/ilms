import 'package:equatable/equatable.dart';

class GeneralModel extends Equatable {
  const GeneralModel({this.code, this.desc, this.type, this.apiDisplay});

  final String? code;
  final String? desc;
  final String? type;

  /// Server-provided label (e.g. `"O : OTHER"`), used as-is when present
  /// instead of composing one from [code]/[desc]. Named `apiDisplay` to avoid
  /// clashing with the legacy [display] getter below.
  final String? apiDisplay;

  GeneralModel copyWith({String? code, String? desc, String? type, String? apiDisplay}) => GeneralModel(
    code: code ?? this.code,
    desc: desc ?? this.desc,
    type: type ?? this.type,
    apiDisplay: apiDisplay ?? this.apiDisplay,
  );

  factory GeneralModel.fromJson(Map<String, dynamic> json) =>
      GeneralModel(code: json["code"], desc: json["desc"], type: json["type"], apiDisplay: json["display"]);

  Map<String, dynamic> toJson() => {"code": code, "desc": desc, "type": type, "display": apiDisplay};

  String get display => "${(type ?? code)} : ${(desc ?? "-")}";

  @override
  List<Object?> get props => [code, desc];
}
