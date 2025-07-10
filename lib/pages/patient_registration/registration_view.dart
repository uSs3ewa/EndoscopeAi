import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'patient_registration_model.dart';

class PatientRegistrationView extends StatefulWidget {
  final PatientRegistrationModel model;
  const PatientRegistrationView({Key? key, required this.model}) : super(key: key);

  @override
  State<PatientRegistrationView> createState() => _PatientRegistrationViewState();
}

class _PatientRegistrationViewState extends State<PatientRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _pathController = TextEditingController();

  @override
  void dispose() {
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
      appBar: AppBar(title: const Text('Данные пациента')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID пациента'),
                keyboardType: TextInputType.number,
                onChanged: widget.model.setId,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pathController,
                decoration: const InputDecoration(
                  labelText: 'Папка для сохранения',
                ),
                onChanged: widget.model.setPathToStorage,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickDirectory,
                child: const Text('Выбрать папку'),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      widget.model.nextRoute,
                      arguments: widget.model.getRecordData(),
                    );
                  },
                  child: const Text('Далее'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
