import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../services/auth/auth_service.dart';
import '../../navigation/main_scaffold.dart';
import '../../profile/screens/profile_edit_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final PatientRepository _patientRepo = PatientRepository();
  StreamSubscription<AuthState>? _authSubscription;
  
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
    
    _authSubscription = AuthService.instance.authStateChanges?.listen((data) {
      if (mounted) {
        if (data.session != null) {
          _checkProfile();
        } else {
          setState(() {
            _isAuthenticated = false;
            _hasProfile = false;
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialState() async {
    final session = AuthService.instance.currentSession;
    if (session != null) {
      await _checkProfile();
    } else {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkProfile() async {
    try {
      final user = AuthService.instance.currentUser;
      final patient = await _patientRepo.getPatient(user?.id);
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _hasProfile = patient != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
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

    if (!_isAuthenticated) {
      return const LoginScreen();
    }

    if (!_hasProfile) {
      return ProfileEditScreen(
        onProfileSaved: _onProfileSaved,
      );
    }

    return const MainScaffold();
  }
}
