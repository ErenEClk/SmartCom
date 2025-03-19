import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool filled;
  final Color? fillColor;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool expands;
  final bool showCursor;
  final double? cursorHeight;
  final Color? cursorColor;
  final Radius? cursorRadius;
  final double? cursorWidth;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final bool isDense;
  final bool isCollapsed;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final bool alignLabelWithHint;
  final Color? iconColor;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final bool autocorrect;
  final bool enableSuggestions;

  const CustomTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.focusNode,
    this.validator,
    this.autovalidateMode,
    this.filled = true,
    this.fillColor,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.expands = false,
    this.showCursor = true,
    this.cursorHeight,
    this.cursorColor,
    this.cursorRadius,
    this.cursorWidth,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
    this.isDense = false,
    this.isCollapsed = false,
    this.floatingLabelBehavior,
    this.alignLabelWithHint = false,
    this.iconColor,
    this.prefixIconColor,
    this.suffixIconColor,
    this.autocorrect = true,
    this.enableSuggestions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      focusNode: focusNode,
      validator: validator,
      autovalidateMode: autovalidateMode,
      textCapitalization: textCapitalization,
      style: style,
      textAlign: textAlign,
      expands: expands,
      showCursor: showCursor,
      cursorHeight: cursorHeight,
      cursorColor: cursorColor ?? AppColors.primary,
      cursorRadius: cursorRadius,
      cursorWidth: cursorWidth ?? 2.0,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: filled,
        fillColor: fillColor ?? Colors.white,
        border: border,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: focusedErrorBorder,
        labelStyle: labelStyle,
        hintStyle: hintStyle,
        errorStyle: errorStyle,
        helperStyle: helperStyle,
        isDense: isDense,
        isCollapsed: isCollapsed,
        floatingLabelBehavior: floatingLabelBehavior,
        alignLabelWithHint: alignLabelWithHint,
        iconColor: iconColor,
        prefixIconColor: prefixIconColor,
        suffixIconColor: suffixIconColor,
      ),
    );
  }
} 