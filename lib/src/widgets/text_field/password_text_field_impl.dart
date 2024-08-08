import 'package:flutter/material.dart';

@immutable
class CorePasswordTextField extends StatefulWidget {
  const CorePasswordTextField({
    this.controller,
    this.validator,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.autovalidateMode,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.prefixIcon,
    this.hintText,
    this.labelText,
    this.maxLength,
    this.buildCounter,
    this.suffixIcon,
    this.suffixIconOff,
    this.enabled,
    this.focusNode,
    super.key,
  });
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextAlign textAlign;
  final AutovalidateMode? autovalidateMode;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final String? hintText;
  final String? labelText;
  final int? maxLength;
  final InputCounterWidgetBuilder? buildCounter;
  final IconData? suffixIcon;
  final IconData? suffixIconOff;
  final bool? enabled;
  final FocusNode? focusNode;

  @override
  State<CorePasswordTextField> createState() => _CorePasswordTextFieldState();
}

class _CorePasswordTextFieldState extends State<CorePasswordTextField> {
  var _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      textAlign: widget.textAlign,
      autovalidateMode: widget.autovalidateMode,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      buildCounter: widget.buildCounter,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        hintText: widget.hintText,
        labelText: widget.labelText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? widget.suffixIcon ?? Icons.visibility_outlined : widget.suffixIconOff ?? Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
