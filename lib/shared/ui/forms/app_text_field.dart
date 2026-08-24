import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ilms/shared/formatters/uppercase_text_formatter.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';

/// Reusable labelled text field aligned with [ThemeData.inputDecorationTheme].
///
/// Supports legacy-style title labels, optional uppercase input, read-only
/// tap targets (dropdown / date picker), and validation inside a [Form].
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.required = false,
    this.uppercase = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.suffixWidget,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textCapitalization = TextCapitalization.sentences,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool required;
  final bool uppercase;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;
  final TextCapitalization textCapitalization;

  /// A field that's `readOnly` with no [onTap] has no possible interaction
  /// at all — a plain view-mode display field, as opposed to a `readOnly`
  /// field that opens a picker/date-sheet on tap (still an active control).
  /// Only the former gets the muted "view" treatment; a tappable picker
  /// stays visually normal until the caller explicitly sets `enabled: false`.
  bool get _isStaticView => readOnly && onTap == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isStaticView = _isStaticView;

    Widget field = TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onFieldSubmitted,
      onEditingComplete: onEditingComplete,
      autovalidateMode: autovalidateMode,
      textCapitalization: uppercase ? TextCapitalization.characters : textCapitalization,
      inputFormatters: [if (uppercase) const UppercaseTextFormatter(), ...?inputFormatters],
      style: isStaticView ? textTheme.bodyLarge?.copyWith(color: cs.onSurface.withValues(alpha: 0.75)) : null,
      cursorColor: isStaticView ? Colors.transparent : null,
      decoration: InputDecoration(
        hintText: hintText,
        counterText: maxLength != null ? '' : null,
        prefixIcon: prefixWidget ?? (prefixIcon != null ? Icon(prefixIcon, color: _iconColor(cs, isStaticView)) : null),
        suffixIcon: suffixWidget ?? (suffixIcon != null ? Icon(suffixIcon, color: _iconColor(cs, isStaticView)) : null),
      ),
    );

    if (isStaticView) {
      // Reuses the theme's already-defined `disabledBorder`/muted fill so a
      // view-mode field reads as "not editable" at a glance, without
      // actually disabling the field (text stays selectable/copyable).
      final baseInputTheme = theme.inputDecorationTheme;
      field = Theme(
        data: theme.copyWith(
          inputDecorationTheme: baseInputTheme.copyWith(
            fillColor: cs.surfaceContainerLow,
            enabledBorder: baseInputTheme.disabledBorder,
            focusedBorder: baseInputTheme.disabledBorder,
          ),
        ),
        child: field,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text.rich(
            TextSpan(
              text: label,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: isStaticView ? 0.6 : 0.85),
              ),
              children: [
                if (required)
                  TextSpan(
                    text: ' *',
                    style: textTheme.labelLarge?.copyWith(color: cs.error, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        field,
      ],
    );
  }

  Color? _iconColor(ColorScheme cs, bool isStaticView) => isStaticView ? cs.onSurface.withValues(alpha: 0.4) : null;
}

/// Read-only field that opens an option picker bottom sheet on tap.
class AppPickerField<T> extends StatelessWidget {
  const AppPickerField({
    super.key,
    required this.label,
    required this.controller,
    this.onTap,
    this.options,
    this.optionLabel,
    this.sheetTitle,
    this.sheetSubtitle,
    this.onOptionSelected,
    this.required = false,
    this.enabled = true,
    this.validator,
    this.suffixIcon = Icons.keyboard_arrow_down_rounded,
    this.searchable = false,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback? onTap;
  final List<T>? options;
  final String Function(T option)? optionLabel;
  final String? sheetTitle;
  final String? sheetSubtitle;
  final ValueChanged<T>? onOptionSelected;
  final bool required;
  final bool enabled;
  final String? Function(String?)? validator;
  final IconData suffixIcon;

  /// Shows a live-filter search box in the option sheet — off by default,
  /// meant for pickers with realistically long lists (postcodes, etc.).
  final bool searchable;

  Future<void> _handleTap(BuildContext context) async {
    if (!enabled) return;

    if (onTap != null) {
      onTap!();
      return;
    }

    final items = options;
    if (items == null || items.isEmpty) return;

    final resolveLabel = optionLabel ?? (option) => option.toString();
    final selected = await showAppOptionPicker<T>(
      context: context,
      title: sheetTitle ?? label,
      subtitle: sheetSubtitle,
      options: items,
      label: resolveLabel,
      isSelected: (option) => controller.text.trim() == resolveLabel(option).trim(),
      searchable: searchable,
    );

    if (selected == null) return;
    controller.text = resolveLabel(selected);
    onOptionSelected?.call(selected);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      readOnly: true,
      enabled: enabled,
      required: required,
      validator: validator,
      onTap: () => _handleTap(context),
      suffixIcon: suffixIcon,
    );
  }
}
