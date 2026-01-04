/// Custom Input Field - NotebookLM Clean Style
///
/// Clean input field with floating label animation and BMW accent colors.
/// Follows NotebookLM's minimal design with premium touches.
///
/// Features:
/// - Floating label animation
/// - Clean borders with focus glow
/// - Prefix/suffix icon support
/// - Error state with helper text
/// - Password visibility toggle
/// - Character counter
///
/// Usage:
/// ```dart
/// CustomInput(
///   label: 'Email',
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

class CustomInput extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool showPasswordToggle;

  const CustomInput({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hintText,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.showPasswordToggle = false,
  });

  /// Email input
  factory CustomInput.email({
    required String label,
    TextEditingController? controller,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return CustomInput(
      label: label,
      controller: controller,
      errorText: errorText,
      onChanged: onChanged,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email_outlined),
    );
  }

  /// Password input
  factory CustomInput.password({
    required String label,
    TextEditingController? controller,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return CustomInput(
      label: label,
      controller: controller,
      errorText: errorText,
      onChanged: onChanged,
      obscureText: true,
      showPasswordToggle: true,
      prefixIcon: const Icon(Icons.lock_outline),
    );
  }

  /// Phone input
  factory CustomInput.phone({
    required String label,
    TextEditingController? controller,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return CustomInput(
      label: label,
      controller: controller,
      errorText: errorText,
      onChanged: onChanged,
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone_outlined),
    );
  }

  /// Number input
  factory CustomInput.number({
    required String label,
    TextEditingController? controller,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return CustomInput(
      label: label,
      controller: controller,
      errorText: errorText,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget? suffixIcon = widget.suffixIcon;
    if (widget.showPasswordToggle && widget.obscureText) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textSecondary(isDark),
        ),
        onPressed: _togglePasswordVisibility,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: _isFocused && widget.errorText == null
                ? [
                    BoxShadow(
                      color: AppColors.primary(isDark).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            validator: widget.validator,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary(isDark),
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hintText,
              helperText: widget.helperText,
              errorText: widget.errorText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: widget.enabled
                  ? AppColors.surface(isDark)
                  : AppColors.surfaceVariant(isDark),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.inputPaddingH,
                vertical: AppSpacing.inputPaddingV,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(
                  color: AppColors.primary(isDark),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.error(isDark)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(
                  color: AppColors.error(isDark),
                  width: 2,
                ),
              ),
              labelStyle: AppTypography.bodyMedium.copyWith(
                color: _isFocused
                    ? AppColors.primary(isDark)
                    : AppColors.textSecondary(isDark),
              ),
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary(isDark),
              ),
              helperStyle: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
              errorStyle: AppTypography.bodySmall.copyWith(
                color: AppColors.error(isDark),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
