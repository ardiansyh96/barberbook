import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';


class CustomTextField extends StatefulWidget {
  /// Controller for managing text input
  final TextEditingController? controller;

  /// Label text displayed above the input field
  final String? label;

  /// Placeholder text when the field is empty
  final String? hintText;

  /// Icon displayed at the start of the field
  final IconData? prefixIcon;

  /// Custom widget displayed at the start (overrides prefixIcon)
  final Widget? prefixWidget;

  /// Icon displayed at the end of the field
  final IconData? suffixIcon;

  /// Custom widget displayed at the end (overrides suffixIcon)
  final Widget? suffixWidget;

  /// Whether this is a password field (adds visibility toggle)
  final bool isPassword;

  /// Keyboard type for the input
  final TextInputType keyboardType;

  /// Text input action (e.g. next, done)
  final TextInputAction textInputAction;

  /// Validation function - returns error message or null if valid
  final String? Function(String?)? validator;

  /// Called when the text changes
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field
  final ValueChanged<String>? onSubmitted;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is read-only (tap only)
  final bool readOnly;

  /// Called when the field is tapped (useful with readOnly)
  final VoidCallback? onTap;

  /// Maximum number of lines
  final int maxLines;

  /// Minimum number of lines
  final int minLines;

  /// Maximum length of input
  final int? maxLength;

  /// Input formatters (e.g. FilteringTextInputFormatter.digitsOnly)
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to auto-focus this field
  final bool autofocus;

  /// Focus node for managing focus
  final FocusNode? focusNode;

  /// Text capitalization behavior
  final TextCapitalization textCapitalization;

  /// Whether to obscure text (non-password fields)
  final bool obscureText;

  /// Custom fill color override
  final Color? fillColor;

  /// Whether to show error immediately without waiting for validation
  final String? errorText;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.suffixWidget,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.fillColor,
    this.errorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  /// Tracks whether the password is visible
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Label ───────────────────────────────────────────────────
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingSM),
        ],

        // ─── Text Form Field ─────────────────────────────────────────
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          obscureText: widget.isPassword ? _obscurePassword : widget.obscureText,
          style: const TextStyle(
            color: AppColors.primaryBlack,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: widget.fillColor ?? AppColors.offWhite,
            counterText: '', // Hide character counter

            // ─── Prefix ─────────────────────────────────────────────
            prefixIcon: widget.prefixWidget ??
                (widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: AppColors.darkGrey,
                        size: AppDimensions.iconMD,
                      )
                    : null),

            // ─── Suffix ─────────────────────────────────────────────
            suffixIcon: widget.suffixWidget ??
                (widget.isPassword
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.darkGrey,
                          size: AppDimensions.iconMD,
                        ),
                      )
                    : widget.suffixIcon != null
                        ? Icon(
                            widget.suffixIcon,
                            color: AppColors.darkGrey,
                            size: AppDimensions.iconMD,
                          )
                        : null),

            // ─── Borders ────────────────────────────────────────────
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLG,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.lightGrey,
                width: AppDimensions.inputBorderWidth,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.lightGrey,
                width: AppDimensions.inputBorderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.gold,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: AppDimensions.inputBorderWidth,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.lightGrey,
                width: AppDimensions.inputBorderWidth,
              ),
            ),
            errorText: widget.errorText,
          ),
        ),
      ],
    );
  }
}
