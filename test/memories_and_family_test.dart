import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mvp_new/data/database/app_database.dart';
import 'package:smriti_mvp_new/data/repositories/family_repository.dart';
import 'package:smriti_mvp_new/data/repositories/memory_repository.dart';
import 'package:smriti_mvp_new/models/family_member.dart';
import 'package:smriti_mvp_new/models/memory.dart';
import 'package:smriti_mvp_new/services/auth/auth_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class MockAuthServiceForHome extends AuthService {
  MockAuthServiceForHome() : super.test();

  @override
  User? get currentUser => const User(
        id: 'mock_user_123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2024-01-01T00:00:00.000Z',
      );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AuthService.instance = MockAuthServiceForHome(); // mock user session
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Memories and Family Member DB Persistence and Isolation', () {
    late FamilyRepository familyRepo;
    late MemoryRepository memoryRepo;

    setUp(() async {
      familyRepo = FamilyRepository();
      memoryRepo = MemoryRepository();
      final db = await AppDatabase.instance.database;
      await db.delete('family_members');
      await db.delete('memories');
    });

    test('FamilyMember serialization preserves story', () {
      final sampleMember = FamilyMember(
        id: 'fam_001',
        patientId: 'patient_aai_01',
        name: 'Riya',
        relationship: 'Granddaughter',
        photoPath: 'assets/images/family/riya.png',
        story: 'Likes to play hide and seek.',
        createdAt: DateTime.now(),
      );

      final map = sampleMember.toMap();
      final reconstructed = FamilyMember.fromMap(map);
      expect(reconstructed.story, 'Likes to play hide and seek.');
    });

    test('Insert and delete memory', () async {
      final memory = Memory(
        id: 'mem_001',
        patientId: 'mock_user_123',
        title: "Test Memory",
        description: 'Test description',
        photoPath: 'assets/test.png',
        dateDescription: 'Today',
        createdAt: DateTime.now(),
      );
      
      await memoryRepo.insertMemory(memory);
      var mems = await memoryRepo.getAllMemories('mock_user_123');
      expect(mems.length, 1);
      
      await memoryRepo.deleteMemory('mem_001');
      mems = await memoryRepo.getAllMemories('mock_user_123');
      expect(mems.length, 0);
    });

    test('Memory user isolation', () async {
      final memory1 = Memory(
        id: 'mem_001',
        patientId: 'user_1',
        title: "User 1 Memory",
        description: 'desc',
        photoPath: 'path',
        dateDescription: 'Today',
        createdAt: DateTime.now(),
      );
      final memory2 = Memory(
        id: 'mem_002',
        patientId: 'user_2',
        title: "User 2 Memory",
        description: 'desc',
        photoPath: 'path',
        dateDescription: 'Today',
        createdAt: DateTime.now(),
      );

      await memoryRepo.insertMemory(memory1);
      await memoryRepo.insertMemory(memory2);

      final user1Mems = await memoryRepo.getAllMemories('user_1');
      expect(user1Mems.length, 1);
      expect(user1Mems.first.title, "User 1 Memory");
    });
    
    test('Family user isolation', () async {
      final fam1 = FamilyMember(
        id: 'fam_1',
        patientId: 'user_1',
        name: 'User 1 Son',
        relationship: 'Son',
        photoPath: 'path',
        createdAt: DateTime.now(),
      );
      final fam2 = FamilyMember(
        id: 'fam_2',
        patientId: 'user_2',
        name: 'User 2 Son',
        relationship: 'Son',
        photoPath: 'path',
        createdAt: DateTime.now(),
      );

      await familyRepo.insertFamilyMember(fam1);
      await familyRepo.insertFamilyMember(fam2);

      final user1Fams = await familyRepo.getAllFamilyMembers('user_1');
      expect(user1Fams.length, 1);
      expect(user1Fams.first.name, "User 1 Son");
    });
    test('MemberMemoriesScreen filters related memories logic (memory lookup)', () async {
      final riya = FamilyMember(
        id: 'fam_riya_01',
        patientId: 'mock_user_123',
        name: 'Riya',
        relationship: 'Granddaughter',
        photoPath: 'assets/images/family/riya.png',
        story: 'She loves painting.',
        createdAt: DateTime.now(),
      );

      final matchingMemory = Memory(
        id: 'mem_01',
        patientId: 'mock_user_123',
        title: 'Trip with Riya',
        description: 'We went to the park.',
        photoPath: 'assets/test.png',
        dateDescription: 'Last summer',
        createdAt: DateTime.now(),
      );
      
      final otherMemory = Memory(
        id: 'mem_02',
        patientId: 'mock_user_123',
        title: 'Trip with Dejit',
        description: 'We went to the zoo.',
        photoPath: 'assets/test.png',
        dateDescription: 'Last week',
        createdAt: DateTime.now(),
      );

      final allMemories = [matchingMemory, otherMemory];
      final memberNameLower = riya.name.toLowerCase();
      
      final related = allMemories.where((m) {
        return m.title.toLowerCase().contains(memberNameLower) || 
               m.description.toLowerCase().contains(memberNameLower);
      }).toList();

      expect(related.length, 1);
      expect(related.first.title, 'Trip with Riya');
    });
  });

}
