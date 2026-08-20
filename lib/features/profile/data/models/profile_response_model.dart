class ProfileResponseModel {
  const ProfileResponseModel({this.status, this.message, this.data});

  final String? status;
  final String? message;
  final ProfileDataModel? data;

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? ProfileDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ProfileDataModel {
  const ProfileDataModel({this.name, this.email, this.phone});

  final String? name;
  final String? email;
  final String? phone;

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}
