import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/shared/models/app_image_item.dart';

class PremiseCensusImageMapper {
  PremiseCensusImageMapper._();

  static AppImageItem toAppImageItem(PremiseCensusImage image) {
    return AppImageItem(
      id: image.localId?.toString() ?? image.id?.toString(),
      localPath: image.localPath,
      networkUrl: image.networkUrl,
    );
  }

  static List<AppImageItem> toAppImageItems(List<PremiseCensusImage> images) {
    return images.map(toAppImageItem).toList();
  }

  static PremiseCensusImage fromLocalCapture({required String localPath, String? typeCode, String? typeDescription}) {
    return PremiseCensusImage(
      localPath: localPath,
      typeCode: typeCode ?? PremiseCensusImageDefaults.typeCode,
      typeDescription: typeDescription ?? PremiseCensusImageDefaults.typeDescription,
    );
  }
}
