import 'package:flutter/material.dart';
import 'package:ilms/features/billboard/presentation/sections/billboard_asset_owner_section.dart';
import 'package:ilms/features/billboard/presentation/sections/billboard_detail_section.dart';
import 'package:ilms/features/billboard/presentation/sections/billboard_faces_section.dart';
import 'package:ilms/features/billboard/presentation/sections/billboard_gps_section.dart';
import 'package:ilms/features/billboard/presentation/sections/billboard_license_section.dart';
import 'package:ilms/features/billboard/presentation/sections/billboard_location_section.dart';
import 'package:ilms/features/billboard/presentation/sections/billboard_media_owner_section.dart';
import 'package:ilms/features/billboard/presentation/sections/billboard_photo_section.dart';
import 'package:ilms/features/billboard/presentation/sections/billboard_remarks_section.dart';

class BillboardFormSectionDef {
  const BillboardFormSectionDef({
    required this.id,
    required this.tabLabel,
    required this.headerTitle,
    required this.builder,
  });

  final String id;
  final String tabLabel;
  final String headerTitle;
  final WidgetBuilder builder;
}

/// Tab / scroll order for the billboard census form.
const billboardFormSections = <BillboardFormSectionDef>[
  BillboardFormSectionDef(
    id: 'details',
    tabLabel: 'Details',
    headerTitle: 'Billboard Details',
    builder: _buildDetailSection,
  ),
  BillboardFormSectionDef(
    id: 'location',
    tabLabel: 'Location',
    headerTitle: 'Location',
    builder: _buildLocationSection,
  ),
  BillboardFormSectionDef(id: 'gps', tabLabel: 'GPS', headerTitle: 'GPS Coordinate', builder: _buildGpsSection),
  BillboardFormSectionDef(
    id: 'media_owner',
    tabLabel: 'Media Owner',
    headerTitle: 'Media Owner',
    builder: _buildMediaOwnerSection,
  ),
  BillboardFormSectionDef(
    id: 'asset_owner',
    tabLabel: 'Asset Owner',
    headerTitle: 'Asset Owner',
    builder: _buildAssetOwnerSection,
  ),
  BillboardFormSectionDef(
    id: 'license',
    tabLabel: 'License',
    headerTitle: 'License Information',
    builder: _buildLicenseSection,
  ),
  BillboardFormSectionDef(id: 'remarks', tabLabel: 'Remarks', headerTitle: 'Remarks', builder: _buildRemarksSection),
  BillboardFormSectionDef(id: 'faces', tabLabel: 'Faces', headerTitle: 'Faces', builder: _buildFacesSection),
  BillboardFormSectionDef(id: 'photos', tabLabel: 'Photos', headerTitle: 'Photos', builder: _buildPhotoSection),
];

Widget _buildDetailSection(BuildContext context) => const BillboardDetailSection();
Widget _buildLocationSection(BuildContext context) => const BillboardLocationSection();
Widget _buildGpsSection(BuildContext context) => const BillboardGpsSection();
Widget _buildMediaOwnerSection(BuildContext context) => const BillboardMediaOwnerSection();
Widget _buildAssetOwnerSection(BuildContext context) => const BillboardAssetOwnerSection();
Widget _buildLicenseSection(BuildContext context) => const BillboardLicenseSection();
Widget _buildRemarksSection(BuildContext context) => const BillboardRemarksSection();
Widget _buildFacesSection(BuildContext context) => const BillboardFacesSection();
Widget _buildPhotoSection(BuildContext context) => const BillboardPhotoSection();
