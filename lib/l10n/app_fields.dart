import 'package:flutter/material.dart';
import 'app_text.dart';

InputDecoration _decoration(BuildContext context, InputDecoration source) =>
    source.copyWith(
      labelText: source.labelText == null
          ? null
          : translate(context, source.labelText!),
      hintText:
          source.hintText == null ? null : translate(context, source.hintText!),
      helperText: source.helperText == null
          ? null
          : translate(context, source.helperText!),
      errorText: source.errorText == null
          ? null
          : translate(context, source.errorText!),
    );

class AppTextField extends StatelessWidget {
  const AppTextField(
      {super.key,
      this.controller,
      this.decoration = const InputDecoration(),
      this.keyboardType,
      this.obscureText = false,
      this.onChanged});
  final TextEditingController? controller;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => TextField(
      controller: controller,
      decoration: _decoration(context, decoration),
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged);
}

class AppTextFormField extends StatelessWidget {
  const AppTextFormField(
      {super.key,
      this.controller,
      this.decoration = const InputDecoration(),
      this.keyboardType,
      this.obscureText = false,
      this.validator});
  final TextEditingController? controller;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  @override
  Widget build(BuildContext context) => TextFormField(
      controller: controller,
      decoration: _decoration(context, decoration),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator == null
          ? null
          : (value) {
              final error = validator!(value);
              return error == null ? null : translate(context, error);
            });
}

class AppSemantics extends StatelessWidget {
  const AppSemantics(
      {super.key,
      this.label,
      this.image,
      this.liveRegion,
      required this.child});
  final String? label;
  final bool? image;
  final bool? liveRegion;
  final Widget child;
  @override
  Widget build(BuildContext context) => Semantics(
      label: label == null ? null : translate(context, label!),
      image: image,
      liveRegion: liveRegion,
      child: child);
}
