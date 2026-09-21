import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/family_member.dart';
import '../../../models/memory.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../widgets/app_avatar.dart';
import '../widgets/memory_card.dart';

class MemberMemoriesScreen extends StatefulWidget {
  final FamilyMember member;

  const MemberMemoriesScreen({super.key, required this.member});

  @override
  State<MemberMemoriesScreen> createState() => _MemberMemoriesScreenState();
}

class _MemberMemoriesScreenState extends State<MemberMemoriesScreen> {
  final MemoryRepository _memoryRepo = MemoryRepository();
  List<Memory> _relatedMemories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    try {
      final allMemories = await _memoryRepo.getAllMemories(widget.member.patientId);
      final memberNameLower = widget.member.name.toLowerCase();
      
      final related = allMemories.where((m) {
        return m.title.toLowerCase().contains(memberNameLower) || 
               m.description.toLowerCase().contains(memberNameLower);
      }).toList();

      if (mounted) {
        setState(() {
          _relatedMemories = related;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text('About ${widget.member.name}', style: AppTypography.headingMedium()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.coral))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppAvatar(
                    imagePath: widget.member.photoPath,
                    size: 120,
                    borderColor: AppColors.coral,
                    borderWidth: 4,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    widget.member.name,
                    style: AppTypography.headingLarge(color: AppColors.coral),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.member.relationship,
                    style: AppTypography.headingSmall(),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.member.story != null && widget.member.story!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.borderSoft),
                      ),
                      child: Text(
                        widget.member.story!,
                        style: AppTypography.bodyLarge(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Related Memories', style: AppTypography.headingSmall()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_relatedMemories.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.borderSoft),
                      ),
                      child: Center(
                        child: Text(
                          'No specific memories found mentioning ${widget.member.name}.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ..._relatedMemories.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: MemoryCard(memory: m),
                    )),
                ],
              ),
            ),
    );
  }
}
