import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final void Function(String?) onSaved;
  final RegExp validationRegex;
  final double height;

  const CustomTextfield({
    super.key,
    required this.hintText,
    this.obscureText = false,
    required this.onSaved,
    required this.validationRegex,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        onSaved: onSaved,
        obscureText: obscureText,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: const OutlineInputBorder(),
          hintText: hintText,
        ),
        validator: (value) {
          if (value != null && validationRegex.hasMatch(value)) {
            return null;
          } else {
            return 'Enter a valid  ${hintText.toLowerCase()}';
          }
        },
      ),
    );
  }
}
