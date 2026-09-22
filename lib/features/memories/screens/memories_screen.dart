import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/mati_speak_button.dart';
import '../../../models/family_member.dart';
import '../../../models/memory.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/repositories/patient_repository.dart';
import '../widgets/family_member_tile.dart';
import '../widgets/memory_card.dart';
import 'add_family_member_screen.dart';
import 'add_memory_screen.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final FamilyRepository _familyRepository = FamilyRepository();
  final MemoryRepository _memoryRepository = MemoryRepository();

  List<FamilyMember> _familyMembers = [];
  List<Memory> _memories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final patient = await PatientRepository().getPatient();
    final patientId = patient?.id;
    if (patientId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final family = await _familyRepository.getAllFamilyMembers(patientId);
      final mems = await _memoryRepository.getAllMemories(patientId);
      
      if (mounted) {
        setState(() {
          _familyMembers = family;
          _memories = mems;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addNewMemoryPhoto() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddMemoryScreen(),
      ),
    );
    if (added == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.coral)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Memories', style: AppTypography.headingLarge()),
                  const MatiSpeakButton(
                    textToSpeak: 'My Memories. Look at familiar family photos.',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Look at familiar family photos',
                style: AppTypography.bodyMedium(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Family Members Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Family', style: AppTypography.headingSmall()),
                  TextButton.icon(
                    onPressed: () async {
                      final added = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddFamilyMemberScreen(),
                        ),
                      );
                      if (added == true) _loadData();
                    },
                    icon: const Icon(
                      Icons.person_add,
                      color: AppColors.coral,
                      size: 20,
                    ),
                    label: Text(
                      'Add Member',
                      style: AppTypography.bodySmall(
                        color: AppColors.coral,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 125,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _familyMembers.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _familyMembers.length) {
                      return GestureDetector(
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddFamilyMemberScreen(member: _familyMembers[index]),
                            ),
                          );
                          if (updated == true) _loadData();
                        },
                        child: FamilyMemberTile(member: _familyMembers[index]),
                      );
                    } else {
                      // Add button tile
                      return GestureDetector(
                        onTap: () async {
                          final added = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddFamilyMemberScreen(),
                            ),
                          );
                          if (added == true) _loadData();
                        },
                        child: Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: AppSpacing.md),
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.borderSoft,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: AppColors.coral,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Add New',
                                style: AppTypography.bodySmall(
                                  color: AppColors.coral,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Memories Feed
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Photo Album', style: AppTypography.headingSmall()),
                  TextButton.icon(
                    onPressed: _addNewMemoryPhoto,
                    icon: const Icon(
                      Icons.add_photo_alternate,
                      color: AppColors.coral,
                      size: 20,
                    ),
                    label: Text(
                      'Add Photo',
                      style: AppTypography.bodySmall(
                        color: AppColors.coral,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_memories.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Center(
                    child: Text(
                      'No memories added yet.\nTap "Add Photo" to create one.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(color: AppColors.textMuted),
                    ),
                  ),
                ),
              ..._memories.map((m) => GestureDetector(
                onTap: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMemoryScreen(memory: m),
                    ),
                  );
                  if (updated == true) _loadData();
                },
                child: MemoryCard(memory: m),
              )),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
