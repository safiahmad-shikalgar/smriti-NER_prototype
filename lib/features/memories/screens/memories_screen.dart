import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../models/family_member.dart';
import '../../../models/memory.dart';
import '../../../widgets/mati_speak_button.dart';
import '../widgets/family_member_tile.dart';
import '../widgets/memory_card.dart';
import 'add_family_member_screen.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final FamilyRepository _familyRepository = FamilyRepository();
  final MemoryRepository _memoryRepository = MemoryRepository();
  final ImagePicker _picker = ImagePicker();

  List<FamilyMember> _familyMembers = [
    FamilyMember(
      id: 'fam_riya',
      patientId: 'patient_aai_01',
      name: 'Riya',
      relationship: 'Granddaughter',
      photoPath: AssetPaths.riyaAvatar,
      createdAt: DateTime.now(),
    ),
    FamilyMember(
      id: 'fam_dejit',
      patientId: 'patient_aai_01',
      name: 'Dejit',
      relationship: 'Son',
      photoPath: AssetPaths.dejitAvatar,
      createdAt: DateTime.now(),
    ),
    FamilyMember(
      id: 'fam_mona',
      patientId: 'patient_aai_01',
      name: 'Mona',
      relationship: 'Daughter',
      photoPath: AssetPaths.monaAvatar,
      createdAt: DateTime.now(),
    ),
  ];

  List<Memory> _memories = [
    Memory(
      id: 'mem_1',
      patientId: 'patient_aai_01',
      title: "Riya's 20th Birthday",
      description: 'Celebrated in Guwahati with whole family',
      photoPath: AssetPaths.riyaBirthdayMemory,
      dateDescription: 'Last Winter, Guwahati',
      createdAt: DateTime.now(),
    ),
    Memory(
      id: 'mem_2',
      patientId: 'patient_aai_01',
      title: 'Rongali Bihu Festival',
      description: 'Dancing and making pitha with granddaughter Riya',
      photoPath: AssetPaths.bihuCelebrationMemory,
      dateDescription: 'April Bohag Bihu',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final family = await _familyRepository.getAllFamilyMembers();
      final mems = await _memoryRepository.getAllMemories();
      if (mounted) {
        setState(() {
          if (family.isNotEmpty) _familyMembers = family;
          if (mems.isNotEmpty) _memories = mems;
        });
      }
    } catch (_) {
      // Keep default memory data
    }
  }

  Future<void> _addNewMemoryPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final newMemory = Memory(
        id: const Uuid().v4(),
        patientId: 'patient_aai_01',
        title: 'New Family Photo',
        description: 'Cherished family moment saved today',
        photoPath: picked.path,
        dateDescription: 'Today',
        createdAt: DateTime.now(),
      );
      try {
        await _memoryRepository.insertMemory(newMemory);
      } catch (_) {}
      setState(() {
        _memories.insert(0, newMemory);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    textToSpeak:
                        'My Memories. Look at familiar family photos.',
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
                      return FamilyMemberTile(member: _familyMembers[index]);
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
              ..._memories.map((m) => MemoryCard(memory: m)),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
