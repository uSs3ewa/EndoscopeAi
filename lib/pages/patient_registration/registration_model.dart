import 'package:endoscopy_ai/features/record_data.dart';

class PatientRegistrationModel {
  final String nextRoute;
  int _id = -1;
  String _pathToStorage = '';

  PatientRegistrationModel(this.nextRoute);

  void setId(String value) => _id = int.tryParse(value) ?? -1;
  void setPathToStorage(String value) => _pathToStorage = value;

  RecordData getRecordData() =>
      RecordData(id: _id, pathToStorage: _pathToStorage);
}
