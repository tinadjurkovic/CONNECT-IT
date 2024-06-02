import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;

  const TextFieldInput({
    Key? key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    required this.textInputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
      borderRadius: BorderRadius.circular(10.0),
    );
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 32, 65, 122), fontSize: 14.5),
        border: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: Theme.of(context).secondaryHeaderColor,
            width: 2.0,
          ),
        ),
        enabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColorDark,
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 13.0,
        ),
        prefixIcon: isPass
            ? const Icon(Icons.lock)
            : const Icon(Icons.person), 
        suffixIcon: isPass
            ? const Icon(Icons.visibility) 
            : null,
      ),
      keyboardType: textInputType,
      obscureText: isPass,
      style: const TextStyle(color: Color.fromARGB(255, 32, 65, 122), fontSize: 14.5),
    );
  }
}
