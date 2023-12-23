// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_adherence_app/app/resources/app.logger.dart';
import 'package:med_adherence_app/utils/app_constants/app_colors.dart';
import 'package:med_adherence_app/utils/app_constants/app_styles.dart';
import 'package:med_adherence_app/utils/screen_util/screen_util.dart';

var log = getLogger('SizedCustomTextField');

class SizedCustomTextField extends StatelessWidget {
  SizedCustomTextField({
    Key? key,
    this.backgrounFillColor,
    this.borderColor,
    this.height,
    this.width,
    this.topPadding = 4,
    this.bottomPadding = 4,
    this.rightPadding = 12,
    this.leftPadding = 8,
    //
    this.labelText,
    this.textEditingController,
    this.hasSuffixIcon = false,
    this.onSuffixIconPressed,
    this.suffixIcon,
    this.focusNode,
    this.initialValue,
    this.hasPrefixIcon = false,
    this.onPrefixIconPressed,
    this.keyboardType,
    this.inputFormatters,
    this.prefixText,
    this.readOnly,
    this.prefixStyle,
    this.floatingLabelStyle,
    this.suffixIconSize,
    this.obscureText,
    this.onChanged,
    this.maxLines,
    this.onTap,
    this.fillColor,
    this.textAlign,
    this.textAlignVertical,
    this.inputStringStyle,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization,
    this.contentpadding,
    this.scrollPadding,
    this.onSubmitted,
    this.autofocus,
    this.enabled = true,
    this.filled,
    this.suffixText,
    this.isCollapsed,
    this.floatingLabelBehavior,
    this.hintText,
  }) : super(key: key);

  Color? backgrounFillColor;
  Color? borderColor;
  final double? height;
  final double? width;
  final double topPadding;
  final double bottomPadding;
  final double rightPadding;
  final double leftPadding;
  //
  final EdgeInsets? scrollPadding;
  final String? labelText;
  final String? prefixText;
  final String? initialValue;
  final double? suffixIconSize;
  final String? suffixText;
  final String? hintText;
  final bool? enabled;
  final bool? filled;
  final bool? readOnly;
  final bool? autofocus;
  final bool? isCollapsed;
  final int? maxLines;
  final bool hasSuffixIcon;
  final bool hasPrefixIcon;
  final bool? obscureText;
  final IconData? suffixIcon;
  final FocusNode? focusNode;
  final Color? fillColor;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextStyle? inputStringStyle;
  final TextStyle? prefixStyle;
  final TextStyle? floatingLabelStyle;
  final TextInputType? keyboardType;
  final TextEditingController? textEditingController;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization? textCapitalization;
  final void Function()? onSuffixIconPressed;
  final void Function()? onPrefixIconPressed;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final EdgeInsetsGeometry? contentpadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 61,
      width: width ?? screenSize(context).width,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(23)),
        border: Border.all(color: borderColor ?? AppColors.transparent),
        color: backgrounFillColor ?? AppColors.lightGray,
      ),
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
        right: rightPadding,
        left: leftPadding,
      ),
      child: TextFormField(
        enabled: enabled,
        scrollPadding: scrollPadding ?? const EdgeInsets.only(bottom: 200),
        autofocus: autofocus ?? false,
        textCapitalization: textCapitalization ?? TextCapitalization.sentences,
        maxLines: maxLines,
        readOnly: readOnly ?? false,
        obscureText: obscureText ?? false,
        initialValue: initialValue,
        focusNode: focusNode,
        controller: textEditingController,
        showCursor: true,
        autocorrect: false,
        textAlign: textAlign ?? TextAlign.start,
        textAlignVertical: textAlignVertical,
        cursorColor: AppColors.kPrimaryColor,
        keyboardType: keyboardType ?? TextInputType.text,
        inputFormatters: inputFormatters ?? [],
        textInputAction: textInputAction,
        onChanged: onChanged,
        onTap: () => onTap ?? FocusScope.of(context).requestFocus(focusNode),
        onFieldSubmitted: ((value) {
          onSubmitted ??
              SystemChannels.textInput.invokeMethod('TextInput.hide');
        }),
        style: inputStringStyle ??
            AppStyles.inputStringStyle(AppColors.inputFieldBlack).copyWith(
              letterSpacing: 0.8,
            ),
        decoration: InputDecoration(
          isCollapsed: isCollapsed ?? false,
          floatingLabelBehavior: floatingLabelBehavior,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.coolRed, width: 0.0),
          ),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              contentpadding ?? const EdgeInsets.symmetric(horizontal: 12),
          isDense: true,
          prefixText: prefixText,
          prefixStyle: prefixStyle,
          suffixText: suffixText,
          suffixStyle: AppStyles.hintStringStyle(14),
          prefixIconColor: AppColors.fullBlack,
          suffixIconColor: AppColors.fullBlack,
          labelText: labelText ?? '',
          hintText: hintText ?? '',
          labelStyle: AppStyles.hintStringStyle(13),
          hintStyle: AppStyles.regularStringStyle(12, AppColors.darkGray),
          filled: filled ?? false,
          fillColor: fillColor ?? AppColors.transparent,
          focusColor: AppColors.kPrimaryColor,
          floatingLabelStyle: floatingLabelStyle,
          suffixIcon: hasSuffixIcon == true
              ? IconButton(
                  onPressed: onSuffixIconPressed ?? () {},
                  icon: Icon(suffixIcon ?? Icons.expand_more),
                  iconSize: suffixIconSize ?? 35,
                  focusColor: AppColors.regularBlue,
                )
              : null,
          prefixIcon: hasPrefixIcon == true
              ? IconButton(
                  onPressed: onPrefixIconPressed ?? () {},
                  icon: const Icon(Icons.search),
                  iconSize: 35,
                  focusColor: AppColors.regularBlue,
                  splashColor: AppColors.regularGray,
                )
              : null,
        ),
      ),
    );
  }
}
