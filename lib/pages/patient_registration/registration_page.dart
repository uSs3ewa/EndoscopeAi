import 'package:flutter/material.dart';

import 'patient_registration_model.dart';
import 'patient_registration_view.dart';

class PatientRegistrationPage extends StatefulWidget {
  final String nextRoute;
  const PatientRegistrationPage({Key? key, required this.nextRoute})
      : super(key: key);

  @override
  State<PatientRegistrationPage> createState() => _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  late final PatientRegistrationModel _model;

  @override
  void initState() {
    super.initState();
    _model = PatientRegistrationModel(widget.nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return PatientRegistrationView(model: _model);
  }
}
