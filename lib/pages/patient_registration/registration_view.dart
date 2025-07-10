import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'registration_model.dart';
import 'package:flutter/services.dart';

const Color kPurple = Color(0xFF6C4BA6);
const Color kPurpleLight = Color(0xFFB39DDB);
const Color kPurpleDark = Color(0xFF4B2C69);

class PatientRegistrationView extends StatefulWidget {
  final PatientRegistrationModel model;
  const PatientRegistrationView({Key? key, required this.model})
      : super(key: key);

  @override
  State<PatientRegistrationView> createState() =>
      _PatientRegistrationViewState();
}

class _PatientRegistrationViewState extends State<PatientRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _pathController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _pickDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      setState(() {
        _pathController.text = path;
      });
      widget.model.setPathToStorage(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Информация о пациенте'),
        backgroundColor: kPurple,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Данные пациента',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                _CustomTextField(
                  controller: _idController,
                  label: 'ID пациента',
                  icon: Icons.assignment_ind_rounded,
                  iconColor: kPurple,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: widget.model.setId,
                ),
                const SizedBox(height: 16),
                _CustomTextField(
                  controller: _pathController,
                  label: 'Папка для сохранения',
                  icon: Icons.folder_open,
                  iconColor: kPurple,
                  readOnly: true,
                  onTap: _pickDirectory,
                  onChanged: widget.model.setPathToStorage,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _pickDirectory,
                    icon: const Icon(Icons.folder_special, color: kPurple),
                    label: const Text('Выбрать папку',
                        style: TextStyle(color: kPurple)),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.of(context).pushReplacementNamed(
                          widget.model.nextRoute,
                          arguments: widget.model.getRecordData(),
                        );
                      }
                    },
                    child: const Text(
                      'Далее',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color iconColor;
  final TextInputType? keyboardType;
  final bool readOnly;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.iconColor = kPurple,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      validator: (value) {
        if ((value ?? '').isEmpty) return 'Заполните поле';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kPurple, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kPurpleLight, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kPurple, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      style: const TextStyle(fontSize: 18, color: Colors.black87),
    );
  }
}
