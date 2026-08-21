import 'package:flutter/material.dart';
import 'package:ilms/features/premise/presentation/sections/business_activity_section.dart';
import 'package:ilms/features/premise/presentation/sections/census_images_section.dart';
import 'package:ilms/features/premise/presentation/sections/company_contact_section.dart';
import 'package:ilms/features/premise/presentation/sections/license_section.dart';
import 'package:ilms/features/premise/presentation/sections/premise_address_section.dart';
import 'package:ilms/features/premise/presentation/sections/premise_details_section.dart';
import 'package:ilms/features/premise/presentation/sections/remarks_section.dart';

class PremiseFormSectionDef {
  const PremiseFormSectionDef({
    required this.id,
    required this.tabLabel,
    required this.headerTitle,
    required this.builder,
    this.isRequired = false,
  });

  final String id;
  final String tabLabel;
  final String headerTitle;
  final WidgetBuilder builder;
  final bool isRequired;
}

/// Tab / scroll order for the premise census form.
const premiseFormSections = <PremiseFormSectionDef>[
  PremiseFormSectionDef(
    id: 'license',
    tabLabel: 'License',
    headerTitle: 'License Information',
    builder: _buildLicenseSection,
  ),
  PremiseFormSectionDef(
    id: 'business',
    tabLabel: 'Business',
    headerTitle: 'Business Activities',
    builder: _buildBusinessActivitySection,
  ),
  PremiseFormSectionDef(id: 'remarks', tabLabel: 'Remarks', headerTitle: 'Remarks', builder: _buildRemarksSection),
  PremiseFormSectionDef(
    id: 'images',
    tabLabel: 'Images',
    headerTitle: 'Census Images',
    isRequired: true,
    builder: _buildCensusImagesSection,
  ),
  PremiseFormSectionDef(
    id: 'company',
    tabLabel: 'Company',
    headerTitle: 'Company & Contact Details',
    builder: _buildCompanyContactSection,
  ),
  PremiseFormSectionDef(
    id: 'details',
    tabLabel: 'Details',
    headerTitle: 'Premise Details',
    builder: _buildPremiseDetailsSection,
  ),
  PremiseFormSectionDef(
    id: 'address',
    tabLabel: 'Address',
    headerTitle: 'Premise Address',
    builder: _buildPremiseAddressSection,
  ),
];

Widget _buildCompanyContactSection(BuildContext context) => const CompanyContactSection();
Widget _buildPremiseDetailsSection(BuildContext context) => const PremiseDetailsSection();
Widget _buildPremiseAddressSection(BuildContext context) => const PremiseAddressSection();
Widget _buildLicenseSection(BuildContext context) => const LicenseSection();
Widget _buildBusinessActivitySection(BuildContext context) => const BusinessActivitySection();
Widget _buildRemarksSection(BuildContext context) => const RemarksSection();
Widget _buildCensusImagesSection(BuildContext context) => const CensusImagesSection();
