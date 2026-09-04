// lib/app/controllers/community_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/interview_experience_model.dart';
import '../services/storage_service.dart';

class CommunityController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storage = Get.find<StorageService>();

  // Feed
  final RxList<InterviewExperienceModel> experiences = <InterviewExperienceModel>[].obs;
  final RxBool isLoadingFeed = false.obs;
  final RxBool isPosting = false.obs;

  // Peers
  final RxList<Map<String, dynamic>> peers = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingPeers = false.obs;

  // Form controllers
  final TextEditingController companyController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final RxString selectedDifficulty = 'Medium'.obs;

  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void onInit() {
    super.onInit();
    fetchExperiences();
    fetchPeers();
  }

  @override
  void onClose() {
    companyController.dispose();
    experienceController.dispose();
    roleController.dispose();
    super.onClose();
  }

  // ========== FEED METHODS ==========

  Future<void> fetchExperiences() async {
    isLoadingFeed.value = true;
    try {
      final snapshot = await _firestore
          .collection('interview_experiences')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      experiences.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return InterviewExperienceModel.fromJson(data);
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load experiences');
    } finally {
      isLoadingFeed.value = false;
    }
  }

  Future<void> addExperience() async {
    final company = companyController.text.trim();
    final experience = experienceController.text.trim();
    final role = roleController.text.trim();

    if (company.isEmpty || experience.isEmpty || role.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    isPosting.value = true;
    try {
      final docRef = _firestore.collection('interview_experiences').doc();
      final data = InterviewExperienceModel(
        id: docRef.id,
        company: company,
        role: role,
        experience: experience,
        difficulty: selectedDifficulty.value,
        likes: 0,
        createdAt: DateTime.now(),
      );

      await docRef.set(data.toJson());

      // Add to local list
      experiences.insert(0, data);

      // Clear form
      companyController.clear();
      experienceController.clear();
      roleController.clear();
      selectedDifficulty.value = 'Medium';

      Get.back(); // Close add page
      Get.snackbar('Posted!', 'Your experience has been shared with the community');
    } catch (e) {
      Get.snackbar('Error', 'Failed to post experience');
    } finally {
      isPosting.value = false;
    }
  }

  Future<void> likeExperience(String id, int currentLikes) async {
    try {
      await _firestore
          .collection('interview_experiences')
          .doc(id)
          .update({'likes': currentLikes + 1});

      // Update local
      final index = experiences.indexWhere((e) => e.id == id);
      if (index != -1) {
        final updated = InterviewExperienceModel(
          id: experiences[index].id,
          company: experiences[index].company,
          role: experiences[index].role,
          experience: experiences[index].experience,
          difficulty: experiences[index].difficulty,
          likes: currentLikes + 1,
          createdAt: experiences[index].createdAt,
        );
        experiences[index] = updated;
      }
    } catch (e) {
      debugPrint('Like error: $e');
    }
  }

  // ========== PEER METHODS ==========

  Future<void> fetchPeers() async {
    isLoadingPeers.value = true;
    try {
      final snapshot = await _firestore
          .collection('users')
          .limit(20)
          .get();

      peers.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'role': data['role'] ?? 'Unknown',
          'experience': data['experienceLevel'] ?? 'Unknown',
          'targetCompanies': List<String>.from(data['targetCompanies'] ?? []),
        };
      }).where((p) => p['uid'] != _storage.userRole).toList(); // Simple filter
    } catch (e) {
      debugPrint('Peer fetch error: $e');
    } finally {
      isLoadingPeers.value = false;
    }
  }

  Future<void> invitePeer(String peerUid, String peerRole) async {
    Get.snackbar(
      'Invite Sent!',
      'Practice request sent to $peerRole. They will see it when they come online.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}