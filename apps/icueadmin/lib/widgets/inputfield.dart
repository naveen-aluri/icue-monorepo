import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TextFieldType {
  datePicker,
  timePicker,
  text,
  dropdown,
  password,
  readOnly,
  search,
}

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    this.focusNode,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.sentences,
    required this.label,
    required this.initialValue,
    this.onSaved,
    this.isRequired = false,
    this.validator,
    this.type = TextFieldType.text,
    this.onTap,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.autofillHint,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.showTitle = true,
    this.suffix,
    this.maxLength,
    this.readOnly = false,
    this.prefixIcon,
    this.inputFormatters,
    this.hintText,
    this.maxLines = 1,
    this.onFieldSubmitted,
    this.filled = true,
    this.width = double.infinity,
  });

  final Function(String)? onFieldSubmitted;
  final String? autofillHint;
  final TextEditingController? controller;
  final bool enabled;
  final FocusNode? focusNode;
  final String? hintText;
  final String? initialValue;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String label;
  final int? maxLength;
  final int? maxLines;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final GestureTapCallback? onTap, onSuffixIconTap;
  final Widget? prefixIcon;
  final bool readOnly;
  final bool isRequired;
  final bool showTitle;
  final String? suffix;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final TextFieldType type;
  final FormFieldValidator<String>? validator;
  final bool filled;
  final double width;

  Widget? getSuffixIcon() {
    switch (type) {
      case TextFieldType.datePicker:
        return const Icon(Icons.date_range);
      case TextFieldType.timePicker:
        return const Icon(Icons.watch_later_sharp);
      case TextFieldType.search:
        return const Icon(Icons.search);
      case TextFieldType.dropdown:
        return const Icon(Icons.arrow_drop_down, size: 26);
      case TextFieldType.password:
        return GestureDetector(
          onTap: onSuffixIconTap,
          child: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                children: isRequired
                    ? const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ]
                    : null,
              ),
            ),
          if (showTitle) const SizedBox(height: 5),
          TextFormField(
            initialValue: controller == null ? initialValue : null,
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            autofillHints: [autofillHint ?? ''],
            onSaved: onSaved,
            onFieldSubmitted: onFieldSubmitted,
            onTap: onTap,
            enabled: enabled,
            onChanged: onChanged,
            obscureText: obscureText,
            maxLength: maxLength,
            maxLines: maxLines,
            readOnly:
                readOnly ||
                (![
                  TextFieldType.text,
                  TextFieldType.password,
                  TextFieldType.search,
                ].contains(type)),
            style: TextStyle(
              color: enabled ? Colors.black : Colors.grey,
              fontSize: 16,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'^\s+|\s+$/g')),
              ...inputFormatters ?? [],
            ],
            validator: !isRequired
                ? validator ?? (value) => null
                : validator ??
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'This is required';
                        }
                        return null;
                      },
            decoration: InputDecoration(
              filled: filled,
              fillColor: !filled
                  ? null
                  : const Color.fromARGB(255, 239, 239, 239),
              isDense: true,
              prefixIcon: prefixIcon,
              prefixIconConstraints: const BoxConstraints(
                maxHeight: 30,
                maxWidth: 40,
              ),
              suffixText: suffix,
              counterText: '',
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: getSuffixIcon(),
              ),
              suffixIconConstraints: const BoxConstraints(
                maxHeight: 30,
                maxWidth: 30,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(5),
              ),
              contentPadding: const EdgeInsets.all(10),
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/**
 *   enabledBorder: OutlineInputBorder(
               borderSide: BorderSide(color: Colors.transparent),
               borderRadius: BorderRadius.all(Radius.circular(8)),
             ),
             focusedBorder: OutlineInputBorder(
               borderSide: BorderSide(color: Colors.transparent),
               borderRadius: BorderRadius.all(Radius.circular(8)),
             ),
             border: OutlineInputBorder(
               borderSide: BorderSide(color: Colors.transparent),
               borderRadius: BorderRadius.all(Radius.circular(8)),
             ),
             errorBorder: OutlineInputBorder(
               borderSide: BorderSide(color: Colors.red),
               borderRadius: BorderRadius.all(Radius.circular(8)),
             ),
             focusedErrorBorder: OutlineInputBorder(
               borderSide: BorderSide(color: Colors.red),
               borderRadius: BorderRadius.all(Radius.circular(8)),
             ),
             disabledBorder: OutlineInputBorder(
               borderSide: BorderSide(color: Colors.transparent),
               borderRadius: BorderRadius.all(Radius.circular(8)),
             ),
 **/
