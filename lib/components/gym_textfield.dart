import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';

enum GymTextFieldType { text, number, email, phone, password }

/// Toss Design System TextField
/// A customizable text input component with Gym design language
class GymTextField extends StatefulWidget {
  const GymTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.type = GymTextFieldType.text,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final GymTextFieldType type;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final TextAlign textAlign;

  @override
  State<GymTextField> createState() => _GymTextFieldState();
}

class _GymTextFieldState extends State<GymTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.background : AppColors.grey100,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.border,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: _obscureText,
            maxLines: _obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            autofocus: widget.autofocus,
            textInputAction: widget.textInputAction,
            // textAlign: widget.textAlign,
            keyboardType: _getKeyboardType(),
            inputFormatters: _getInputFormatters(),
            style: AppTextStyles.bodyLarge.copyWith(
              color:
                  widget.enabled
                      ? AppColors.textPrimary
                      : AppColors.textDisabled,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon:
                  widget.prefixIcon != null
                      ? Icon(
                        widget.prefixIcon,
                        color:
                            widget.enabled
                                ? AppColors.grey600
                                : AppColors.textDisabled,
                        size: 22,
                      )
                      : null,
              suffixIcon: _buildSuffixIcon(),
              filled: false,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: widget.maxLines == 1 ? 18 : AppSpacing.md,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorText: null,
              counterText: '',
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: AppSpacing.iconSmall,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(widget.errorText!, style: AppTextStyles.error),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.grey500,
          size: AppSpacing.iconMedium,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case GymTextFieldType.number:
        return TextInputType.number;
      case GymTextFieldType.email:
        return TextInputType.emailAddress;
      case GymTextFieldType.phone:
        return TextInputType.phone;
      case GymTextFieldType.password:
        return TextInputType.visiblePassword;
      default:
        return widget.maxLines > 1
            ? TextInputType.multiline
            : TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    switch (widget.type) {
      case GymTextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case GymTextFieldType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ];
      default:
        return [];
    }
  }
}
