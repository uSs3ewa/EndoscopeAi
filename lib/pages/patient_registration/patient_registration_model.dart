import 'package:flutter/material.dart';

class PatientRegistrationModel {
  late String _name;
  late String _surname;
  late int _id;
  late DateTime _time;

  void setName(String newValue) => _name = newValue;
  void setSurname(String newValue) => _surname = newValue;
  void setId(String newValue) => _id = int.tryParse(newValue) ?? -1;
  void setTime(DateTime newValue) => _time = newValue;
}
