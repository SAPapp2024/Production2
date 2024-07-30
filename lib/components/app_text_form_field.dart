import 'dart:async';

import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/general_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

const textSize = 16.0;
const textStyle = TextStyle(
  fontSize: textSize,
  fontWeight: FontWeight.w400,
  color: AppColors.strongGray,
);

class AppPhoneFormField extends StatelessWidget {
  final TextEditingController controller;
  final void Function()? onEditingComplete;
  final TextInputAction? textInputAction;
  final String? hint;
  final String? floatingLabel;
  final void Function(Country)? onCountryChanged;
  final String? initialCountryCode;
  final FocusNode? focusNode;

  const AppPhoneFormField(
      {super.key,
      required this.controller,
      this.onEditingComplete,
      this.textInputAction,
      this.hint,
      this.floatingLabel,
      this.onCountryChanged,
      this.initialCountryCode,
      this.focusNode});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: textSize,
      fontWeight: FontWeight.w400,
      color: AppColors.strongGray,
    );
    final decoration = appTextFormFieldDecoration.copyWith(
        hintText: hint,
        hintStyle: textStyle.copyWith(color: AppColors.subtitleGray));
    final phoneFormField = IntlPhoneField(
      focusNode: focusNode,
      initialCountryCode: initialCountryCode,
      keyboardType: TextInputType.phone,
      decoration: decoration.copyWith(
          suffixIcon: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () {
                controller.clear();
              },
              icon: const Icon(
                Icons.close,
                size: 24,
                color: AppColors.subtitleGray,
              ))),
      controller: controller,
      onEditingComplete: onEditingComplete,
      textInputAction: textInputAction,
      style: textStyle,
      dropdownTextStyle: const TextStyle(
        color: AppColors.black1,
        fontWeight: FontWeight.bold,
        fontSize: textSize,
      ),
      disableLengthCheck: true,
      onCountryChanged: onCountryChanged,
      textAlignVertical: TextAlignVertical.center,
    );
    if (floatingLabel != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              floatingLabel!.toUpperCase(),
              style: floatingLabelTextStyle,
            ),
          ),
          const SizedBox(height: 4),
          phoneFormField,
        ],
      );
    } else {
      return phoneFormField;
    }
  }
}

class AppTextFormField extends StatefulWidget {
  final GlobalKey? containerKey;
  final ScrollController? scrollController;
  final TextEditingController controller;
  final void Function()? onEditingComplete;
  final TextInputAction? textInputAction;
  final String? hint;
  final String? floatingLabel;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  final int? minLines;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool showClearButton;
  final List<TextInputFormatter> inputFormatters;
  final void Function(String)? onChanged;

  const AppTextFormField(
      {super.key,
      this.containerKey,
      this.scrollController,
      required this.controller,
      this.onEditingComplete,
      this.textInputAction,
      this.hint,
      this.floatingLabel,
      this.obscureText = false,
      this.validator,
      this.onTap,
      this.minLines,
      this.focusNode,
      this.keyboardType,
      this.showClearButton = true,
      this.inputFormatters = const [],
      this.onChanged});

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  FocusNode? _focusNode;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.scrollController != null && widget.containerKey != null) {
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode!.addListener(() {
        if (_focusNode!.hasFocus) {
          final bool isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);
          Future.delayed(Duration(milliseconds: isKeyboardVisible ? 0 : 500)).then((value) {
            final renderObject = widget.containerKey!.currentContext!
                .findRenderObject() as RenderBox;
            final position = MatrixUtils.transformPoint(
                renderObject.getTransformTo(null), Offset(0, Scrollable
                .of(context)
                .position
                .pixels));
            widget.scrollController!.animateTo(
              position.dy - 100,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = appTextFormFieldDecoration.copyWith(
        hintText: widget.hint,
        hintStyle: textStyle.copyWith(color: AppColors.subtitleGray));
    final textFormField = TextFormField(
      key: _key,
      inputFormatters: [...widget.inputFormatters],
      onChanged: widget.onChanged,
      decoration: decoration.copyWith(
          suffixIcon: widget.showClearButton
              ? IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    widget.controller.clear();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 24,
                    color: AppColors.subtitleGray,
                  ))
              : null,
          alignLabelWithHint: widget.minLines != null),
      controller: widget.controller,
      onEditingComplete: widget.onEditingComplete,
      textInputAction: widget.textInputAction,
      style: textStyle,
      obscureText: widget.obscureText,
      validator: widget.validator,
      onTap: widget.onTap,
      minLines: widget.minLines,
      maxLines: widget.minLines != null ? null : 1,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
    );
    if (widget.floatingLabel != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              widget.floatingLabel!.toUpperCase(),
              style: floatingLabelTextStyle,
            ),
          ),
          const SizedBox(height: 4),
          textFormField,
        ],
      );
    } else {
      return textFormField;
    }
  }
}

class AutoCompleteTextFormField<T> extends StatefulWidget {
  final GlobalKey? containerKey;
  final ScrollController? scrollController;
  final TextEditingController controller;
  final void Function()? onEditingComplete;
  final TextInputAction? textInputAction;
  final String? hint;
  final String? floatingLabel;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  final SuggestionsCallback<T> suggestionsCallback;
  final ItemBuilder<T> itemBuilder;
  final void Function(T) onSuggestionSelected;
  final FocusNode? focusNode;
  final SuggestionsBoxController? suggestionsBoxController;
  final TextCapitalization textCapitalization;

  const AutoCompleteTextFormField(
      {super.key,
      this.containerKey,
      this.scrollController,
      required this.controller,
      this.onEditingComplete,
      this.textInputAction,
      this.hint,
      this.floatingLabel,
      this.obscureText = false,
      this.validator,
      this.onTap,
      required this.suggestionsCallback,
      required this.itemBuilder,
      required this.onSuggestionSelected,
      this.focusNode,
      this.suggestionsBoxController,
      this.textCapitalization = TextCapitalization.none});

  @override
  State<AutoCompleteTextFormField<T>> createState() => _AutoCompleteTextFormFieldState<T>();
}

class _AutoCompleteTextFormFieldState<T> extends State<AutoCompleteTextFormField<T>> {

  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();

    if (widget.scrollController != null && widget.containerKey != null) {
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode!.addListener(() {
        if (_focusNode!.hasFocus) {
          final bool isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);
          Future.delayed(Duration(milliseconds: isKeyboardVisible ? 0 : 500)).then((value) {
            final renderObject = widget.containerKey!.currentContext!
                .findRenderObject() as RenderBox;
            final position = MatrixUtils.transformPoint(
                renderObject.getTransformTo(null), Offset(0, Scrollable
                .of(context)
                .position
                .pixels));
            widget.scrollController!.animateTo(
              position.dy - 100,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = appTextFormFieldDecoration.copyWith(
        hintText: widget.hint,
        hintStyle: textStyle.copyWith(color: AppColors.subtitleGray));
    final textFormField = TypeAheadFormField(
      suggestionsBoxController: widget.suggestionsBoxController,
      textFieldConfiguration: TextFieldConfiguration(
        textCapitalization: widget.textCapitalization,
        focusNode: widget.focusNode,
        inputFormatters: [restrictedInputFormatterForFirestoreKeys],
        decoration: decoration.copyWith(
            suffixIcon: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  widget.controller.clear();
                },
                icon: const Icon(
                  Icons.close,
                  size: 24,
                  color: AppColors.subtitleGray,
                ))),
        controller: widget.controller,
        onEditingComplete: widget.onEditingComplete,
        textInputAction: widget.textInputAction,
        style: textStyle,
        obscureText: widget.obscureText,
      ),
      validator: widget.validator,
      suggestionsCallback: widget.suggestionsCallback,
      itemBuilder: widget.itemBuilder,
      onSuggestionSelected: widget.onSuggestionSelected,
    );
    if (widget.floatingLabel != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              widget.floatingLabel!.toUpperCase(),
              style: floatingLabelTextStyle,
            ),
          ),
          const SizedBox(height: 4),
          textFormField,
        ],
      );
    } else {
      return textFormField;
    }
  }
}

const floatingLabelTextStyle = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w500,
  color: AppColors.strongGray,
);

const appTextFormFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Color(0xFFF6F6F6),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  ),
  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12.5),
);

const typeAheadFormFieldTextFieldConfiguration = TextFieldConfiguration(
  decoration: appTextFormFieldDecoration,
  style: textStyle,
);
