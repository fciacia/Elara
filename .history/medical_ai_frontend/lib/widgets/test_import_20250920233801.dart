import 'package:flutter/material.dart';
import 'patient_context_panel.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PatientContextPanel(patientId: 'test');
  }
}