import 'package:equatable/equatable.dart';

/// Standard payload for the crash / error log sent to `POST /api/mobileErrorLog`.
///
/// The endpoint receives a `FormData` field named `data` holding the JSON
/// encoding of this model's [toJson] map (i.e. `jsonEncode(log.toJson())`).
class MobileErrorLog extends Equatable {
  /// Which module the error surfaced in — `premis` / `billboard` / `siasatan` /
  /// `auth` / `general`.
  final String module;

  /// Route or screen the error occurred on, when known.
  final String? page;

  /// Classification — `crash` / `network` / `business`.
  final String type;

  /// Human-readable error message.
  final String message;

  /// Stack trace, when available.
  final String? stackTrace;

  /// Extra contextual state the caller wants to attach.
  final Map<String, dynamic>? context;

  final String? deviceModel;
  final String? deviceOS;
  final String? deviceOSVersion;
  final String? appVersion;
  final String? buildNumber;
  final String? packageName;

  /// ISO-8601 timestamp of when the error occurred.
  final String timestamp;

  const MobileErrorLog({
    required this.module,
    this.page,
    required this.type,
    required this.message,
    this.stackTrace,
    this.context,
    this.deviceModel,
    this.deviceOS,
    this.deviceOSVersion,
    this.appVersion,
    this.buildNumber,
    this.packageName,
    required this.timestamp,
  });

  factory MobileErrorLog.fromJson(Map<String, dynamic> json) {
    return MobileErrorLog(
      module: json['module'] as String,
      page: json['page'] as String?,
      type: json['type'] as String,
      message: json['message'] as String,
      stackTrace: json['stackTrace'] as String?,
      context: json['context'] as Map<String, dynamic>?,
      deviceModel: json['deviceModel'] as String?,
      deviceOS: json['deviceOS'] as String?,
      deviceOSVersion: json['deviceOSVersion'] as String?,
      appVersion: json['appVersion'] as String?,
      buildNumber: json['buildNumber'] as String?,
      packageName: json['packageName'] as String?,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      if (page != null) 'page': page,
      'type': type,
      'message': message,
      if (stackTrace != null) 'stackTrace': stackTrace,
      if (context != null) 'context': context,
      if (deviceModel != null) 'deviceModel': deviceModel,
      if (deviceOS != null) 'deviceOS': deviceOS,
      if (deviceOSVersion != null) 'deviceOSVersion': deviceOSVersion,
      if (appVersion != null) 'appVersion': appVersion,
      if (buildNumber != null) 'buildNumber': buildNumber,
      if (packageName != null) 'packageName': packageName,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [
    module,
    page,
    type,
    message,
    stackTrace,
    context,
    deviceModel,
    deviceOS,
    deviceOSVersion,
    appVersion,
    buildNumber,
    packageName,
    timestamp,
  ];
}
