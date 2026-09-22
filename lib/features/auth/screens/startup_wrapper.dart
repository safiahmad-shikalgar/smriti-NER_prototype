import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../navigation/main_scaffold.dart';
import '../../profile/screens/profile_edit_screen.dart';

class StartupWrapper extends StatefulWidget {
  const StartupWrapper({super.key});

  @override
  State<StartupWrapper> createState() => _StartupWrapperState();
}

class _StartupWrapperState extends State<StartupWrapper> {
  final PatientRepository _patientRepo = PatientRepository();
  
  bool _isLoading = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    try {
      final patient = await _patientRepo.getPatient();
      if (mounted) {
        setState(() {
          _hasProfile = patient != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasProfile = false;
          _isLoading = false;
        });
      }
    }
  }

  void _onProfileSaved() {
    setState(() {
      _hasProfile = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.coral)),
      );
    }

    if (!_hasProfile) {
      return ProfileEditScreen(
        onProfileSaved: _onProfileSaved,
      );
    }

    return const MainScaffold();
  }
}
