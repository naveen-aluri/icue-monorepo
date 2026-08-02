// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

import 'package:flutter/material.dart';

List<MenuItem> menuItemFromJson(String str) =>
    List<MenuItem>.from(json.decode(str).map((x) => MenuItem.fromJson(x)));

String menuItemToJson(List<MenuItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MenuItem<T> {
  MenuItem({required this.id, required this.name});

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      MenuItem(id: json['id'], name: json['name']);

  final T id;
  final String name;

  MenuItem copyWith({T? id, String? name}) =>
      MenuItem(id: id ?? this.id, name: name ?? this.name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

List<DropdownMenuItem<T>>? getDropDownMenuItems<T>([
  List<T>? list,
  List<MenuItem<T>>? listMap,
]) {
  final List<DropdownMenuItem<T>> items = [];
  if (list != null) {
    for (final T item in list) {
      items.add(DropdownMenuItem(value: item, child: Text('$item')));
    }
  } else {
    for (final MenuItem<T> item in listMap!) {
      items.add(DropdownMenuItem(value: item.id, child: Text(item.name)));
    }
  }
  return items;
}

class Dropdown<T> extends StatelessWidget {
  const Dropdown({
    super.key,
    this.value,
    this.onChanged,
    this.items,
    required this.title,
    this.required = false,
    this.showTitle = false,
    this.disabled = false,
    this.filled = false,
    this.valueStyle,
    this.dropdownColor,
    this.width = double.infinity,
  });

  final bool disabled;
  final Color? dropdownColor;
  final bool filled;
  final List<DropdownMenuItem<T>>? items;
  final ValueChanged<T?>? onChanged;
  final bool required;
  final bool showTitle;
  final String title;
  final T? value;
  final TextStyle? valueStyle;
  final double width;

  @override
  Widget build(BuildContext context) {
    final bool isPresent = items?.any((item) => item.value == value) ?? false;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 5),
              child: RichText(
                text: TextSpan(
                  text: title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  children: required
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
            ),
          DropdownButtonFormField<T>(
            dropdownColor: dropdownColor ?? Colors.white,
            initialValue: isPresent ? value : null,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            hint: Text(title, style: const TextStyle(fontSize: 16)),
            validator: !required
                ? null
                : (value) {
                    if (value == null || value == '') {
                      return 'This is required';
                    }
                    return null;
                  },
            isExpanded: true,
            decoration: InputDecoration(
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
              isDense: true,
              fillColor: Colors.white,
              filled: filled,
              contentPadding: const EdgeInsets.all(10),
            ),
            onChanged: disabled ? null : onChanged,
            items: items,
          ),
        ],
      ),
    );
  }
}
