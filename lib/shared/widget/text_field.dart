import 'package:endoscopy_ai/pages/patient_registration/patient_registration_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final PatientRegistrationModel _model;
  final String _hintText;
  final IconData _icon;
  final TextInputFormatter _formatter;
  final Function(String) _onSave;

  CustomTextFormField(
      this._model, this._hintText, this._icon, this._formatter, this._onSave,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextFormField(
          inputFormatters: [_formatter],
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(255, 233, 230, 230),
            prefixIcon: Icon(_icon),
            hintText: _hintText,
            hintStyle: const TextStyle(
              fontSize: 22.0,
              height: 1,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsetsGeometry.all(5),
            counterText: '',
          ),
          maxLength: 256,
          maxLines: 1,
          minLines: 1,
          style: const TextStyle(
            fontSize: 20.0,
            height: 1,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          onSaved: (String? value) => _onSave(value ?? ''),
          validator: (String? value) {
            return (value != null && value.contains('@'))
                ? 'Do not use the @ char.'
                : null;
          }),
    );
  }
}
