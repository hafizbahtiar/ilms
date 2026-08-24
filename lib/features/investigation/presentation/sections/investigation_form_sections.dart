import 'package:flutter/material.dart';
import 'package:ilms/features/investigation/presentation/sections/investigation_applicant_section.dart';
import 'package:ilms/features/investigation/presentation/sections/investigation_location_section.dart';
import 'package:ilms/features/investigation/presentation/sections/investigation_minutes_section.dart';
import 'package:ilms/features/investigation/presentation/sections/investigation_photo_section.dart';
import 'package:ilms/features/investigation/presentation/sections/investigation_premise_details_section.dart';

class InvestigationFormSectionDef {
  const InvestigationFormSectionDef({
    required this.id,
    required this.tabLabel,
    required this.headerTitle,
    required this.isRequired,
    required this.builder,
  });

  final String id;
  final String tabLabel;
  final String headerTitle;

  /// Only minutes carries real validation — mirrors legacy's single
  /// validated section, but derived from this registry instead of a
  /// hand-maintained parallel array (the legacy footgun this design fixes).
  final bool isRequired;
  final WidgetBuilder builder;
}

/// Tab / scroll order for the investigation form.
const investigationFormSections = <InvestigationFormSectionDef>[
  InvestigationFormSectionDef(
    id: 'applicant',
    tabLabel: 'Applicant',
    headerTitle: 'Maklumat Pemohon',
    isRequired: false,
    builder: _buildApplicantSection,
  ),
  InvestigationFormSectionDef(
    id: 'location',
    tabLabel: 'Parlimen & Kawasan',
    headerTitle: 'Parlimen & Kawasan',
    isRequired: false,
    builder: _buildLocationSection,
  ),
  InvestigationFormSectionDef(
    id: 'premise_details',
    tabLabel: 'Premis',
    headerTitle: 'Maklumat Premis',
    isRequired: false,
    builder: _buildPremiseDetailsSection,
  ),
  InvestigationFormSectionDef(
    id: 'photos',
    tabLabel: 'Photos',
    headerTitle: 'Gambar Siasatan',
    isRequired: false,
    builder: _buildPhotoSection,
  ),
  InvestigationFormSectionDef(
    id: 'minutes',
    tabLabel: 'Minit',
    headerTitle: 'Minit',
    isRequired: true,
    builder: _buildMinutesSection,
  ),
];

Widget _buildApplicantSection(BuildContext context) => const InvestigationApplicantSection();
Widget _buildLocationSection(BuildContext context) => const InvestigationLocationSection();
Widget _buildPremiseDetailsSection(BuildContext context) => const InvestigationPremiseDetailsSection();
Widget _buildPhotoSection(BuildContext context) => const InvestigationPhotoSection();
Widget _buildMinutesSection(BuildContext context) => const InvestigationMinutesSection();
